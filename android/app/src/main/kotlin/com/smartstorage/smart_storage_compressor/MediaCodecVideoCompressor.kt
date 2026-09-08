package com.smartstorage.smart_storage_compressor

import android.content.Context
import android.media.MediaCodecList
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.util.Log
import androidx.annotation.OptIn
import androidx.media3.common.MediaItem
import androidx.media3.common.MimeTypes
import androidx.media3.common.util.UnstableApi
import androidx.media3.effect.Presentation
import androidx.media3.transformer.Composition
import androidx.media3.transformer.DefaultEncoderFactory
import androidx.media3.transformer.EditedMediaItem
import androidx.media3.transformer.Effects
import androidx.media3.transformer.ExportException
import androidx.media3.transformer.ExportResult
import androidx.media3.transformer.ProgressHolder
import androidx.media3.transformer.Transformer
import androidx.media3.transformer.VideoEncoderSettings
import java.io.File
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit
import java.util.concurrent.atomic.AtomicBoolean
import kotlin.math.max

@OptIn(UnstableApi::class)
class MediaCodecVideoCompressor(private val context: Context) {
    companion object {
        private const val TAG = "MediaCodecCompressor"
    }

    interface ProgressListener {
        fun onProgress(progress: Double, estimatedRemainingMs: Long?, bytesProcessed: Long)
    }

    @Volatile
    private var isCancelled = false
    private val mainHandler = Handler(Looper.getMainLooper())
    private var activeTransformer: Transformer? = null

    fun cancel() {
        isCancelled = true
        Log.i(TAG, "Cancellation requested for compression operation.")
        mainHandler.post {
            try {
                activeTransformer?.cancel()
            } catch (e: Exception) {
                Log.w(TAG, "Error cancelling active transformer: ${e.message}")
            }
        }
    }

    fun isCodecSupported(mimeType: String): Boolean {
        return try {
            val codecList = MediaCodecList(MediaCodecList.REGULAR_CODECS)
            for (info in codecList.codecInfos) {
                if (!info.isEncoder) continue
                for (type in info.supportedTypes) {
                    if (type.equals(mimeType, ignoreCase = true)) {
                        return true
                    }
                }
            }
            false
        } catch (e: Exception) {
            false
        }
    }

    fun compress(
        inputPath: String,
        outputPath: String,
        targetWidth: Int,
        targetHeight: Int,
        targetBitrate: Int,
        codec: String,
        listener: ProgressListener?
    ): Map<String, Any> {
        isCancelled = false
        val inputFile = File(inputPath)
        val outputFile = File(outputPath)

        if (!inputFile.exists()) {
            return mapOf(
                "success" to false,
                "errorCode" to "SOURCE_NOT_FOUND",
                "errorMessage" to "Input video file does not exist: $inputPath"
            )
        }

        val originalSize = inputFile.length()
        outputFile.parentFile?.mkdirs()
        if (outputFile.exists()) {
            outputFile.delete()
        }

        // Query source duration
        val retriever = MediaMetadataRetriever()
        var durationMs = 0L
        try {
            retriever.setDataSource(inputPath)
            val durStr = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
            durationMs = durStr?.toLongOrNull() ?: 0L
        } catch (e: Exception) {
            Log.w(TAG, "Could not extract video duration: ${e.message}")
        } finally {
            try { retriever.release() } catch (_: Exception) {}
        }

        val targetMime = if (codec.equals("hevc", ignoreCase = true)) {
            if (isCodecSupported(MimeTypes.VIDEO_H265)) {
                MimeTypes.VIDEO_H265
            } else {
                Log.w(TAG, "Device lacks hardware HEVC encoder, falling back to H.264")
                MimeTypes.VIDEO_H264
            }
        } else {
            MimeTypes.VIDEO_H264
        }

        val startTimeMs = System.currentTimeMillis()
        val latch = CountDownLatch(1)
        val isCompleted = AtomicBoolean(false)
        val isFailed = AtomicBoolean(false)
        var failureMessage: String? = null

        val videoEncoderSettings = VideoEncoderSettings.Builder()
            .setBitrate(targetBitrate)
            .build()

        val encoderFactory = DefaultEncoderFactory.Builder(context)
            .setRequestedVideoEncoderSettings(videoEncoderSettings)
            .setEnableFallback(true)
            .build()

        val transformerListener = object : Transformer.Listener {
            override fun onCompleted(composition: Composition, exportResult: ExportResult) {
                Log.i(TAG, "Transformer compression completed successfully.")
                isCompleted.set(true)
                latch.countDown()
            }

            override fun onError(
                composition: Composition,
                exportResult: ExportResult,
                exportException: ExportException
            ) {
                Log.e(TAG, "Transformer compression failed: ${exportException.message}", exportException)
                failureMessage = exportException.message
                isFailed.set(true)
                latch.countDown()
            }
        }

        val transformer = Transformer.Builder(context)
            .setVideoMimeType(targetMime)
            .setAudioMimeType(MimeTypes.AUDIO_AAC)
            .setEncoderFactory(encoderFactory)
            .addListener(transformerListener)
            .build()

        val mediaItem = MediaItem.fromUri(Uri.fromFile(inputFile))
        val presentation = Presentation.createForWidthAndHeight(
            targetWidth,
            targetHeight,
            Presentation.LAYOUT_SCALE_TO_FIT
        )
        val editedMediaItem = EditedMediaItem.Builder(mediaItem)
            .setEffects(Effects(emptyList(), listOf(presentation)))
            .build()

        mainHandler.post {
            if (!isCancelled) {
                activeTransformer = transformer
                try {
                    transformer.start(editedMediaItem, outputPath)
                } catch (e: Exception) {
                    Log.e(TAG, "Failed to start transformer: ${e.message}", e)
                    failureMessage = e.message
                    isFailed.set(true)
                    latch.countDown()
                }
            } else {
                latch.countDown()
            }
        }

        val progressHolder = ProgressHolder()

        while (!latch.await(150, TimeUnit.MILLISECONDS)) {
            if (isCancelled) {
                mainHandler.post {
                    try { transformer.cancel() } catch (_: Exception) {}
                }
                if (outputFile.exists()) {
                    outputFile.delete()
                }
                return mapOf(
                    "success" to false,
                    "isCancelled" to true,
                    "errorCode" to "CANCELLED",
                    "errorMessage" to "Operation cancelled by user."
                )
            }

            mainHandler.post {
                if (!isCompleted.get() && !isFailed.get() && !isCancelled) {
                    val progressState = transformer.getProgress(progressHolder)
                    if (progressState == Transformer.PROGRESS_STATE_AVAILABLE) {
                        val progress = (progressHolder.progress / 100.0).coerceIn(0.0, 0.99)
                        val elapsed = System.currentTimeMillis() - startTimeMs
                        val estimatedRemainingMs = if (progress > 0.05 && elapsed > 500) {
                            val totalEst = (elapsed / progress).toLong()
                            max(0L, totalEst - elapsed)
                        } else {
                            null
                        }
                        listener?.onProgress(progress, estimatedRemainingMs, (originalSize * progress).toLong())
                    }
                }
            }
        }

        mainHandler.post {
            activeTransformer = null
        }

        if (isCancelled) {
            if (outputFile.exists()) {
                outputFile.delete()
            }
            return mapOf(
                "success" to false,
                "isCancelled" to true,
                "errorCode" to "CANCELLED",
                "errorMessage" to "Operation cancelled by user."
            )
        }

        if (isFailed.get() || !outputFile.exists() || outputFile.length() == 0L) {
            if (outputFile.exists()) {
                outputFile.delete()
            }
            return mapOf(
                "success" to false,
                "errorCode" to "COMPRESSION_FAILED",
                "errorMessage" to (failureMessage ?: "Native MediaCodec compression failed")
            )
        }

        val compressedSize = outputFile.length()
        listener?.onProgress(1.0, 0L, compressedSize)

        return mapOf(
            "success" to true,
            "outputPath" to outputPath,
            "originalSize" to originalSize,
            "compressedSize" to compressedSize,
            "durationMs" to durationMs
        )
    }
}