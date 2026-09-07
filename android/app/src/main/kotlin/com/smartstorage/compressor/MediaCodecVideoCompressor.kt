package com.smartstorage.compressor

import android.media.MediaCodec
import android.media.MediaCodecInfo
import android.media.MediaCodecList
import android.media.MediaExtractor
import android.media.MediaFormat
import android.media.MediaMuxer
import android.util.Log
import java.io.File
import java.nio.ByteBuffer
import kotlin.math.max

class MediaCodecVideoCompressor {
    companion object {
        private const val TAG = "MediaCodecCompressor"
        private const val TIMEOUT_USEC = 10000L
    }

    @Volatile
    private var isCancelled = false

    fun cancel() {
        isCancelled = true
        Log.i(TAG, "Cancellation requested for compression operation.")
    }

    interface ProgressListener {
        fun onProgress(progress: Double, estimatedRemainingMs: Long?, bytesProcessed: Long)
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
        codec: String = "h264",
        listener: ProgressListener? = null
    ): Map<String, Any> {
        isCancelled = false
        val startTime = System.currentTimeMillis()
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
        val extractor = MediaExtractor()
        var muxer: MediaMuxer? = null
        var decoder: MediaCodec? = null
        var encoder: MediaCodec? = null

        val targetMime = if (codec.equals("hevc", ignoreCase = true) && isCodecSupported("video/hevc")) {
            "video/hevc"
        } else {
            "video/avc"
        }

        try {
            extractor.setDataSource(inputPath)

            var videoTrackIndex = -1
            var audioTrackIndex = -1
            var videoFormat: MediaFormat? = null
            var audioFormat: MediaFormat? = null

            for (i in 0 until extractor.trackCount) {
                val format = extractor.getTrackFormat(i)
                val mime = format.getString(MediaFormat.KEY_MIME) ?: continue
                if (mime.startsWith("video/") && videoTrackIndex == -1) {
                    videoTrackIndex = i
                    videoFormat = format
                } else if (mime.startsWith("audio/") && audioTrackIndex == -1) {
                    audioTrackIndex = i
                    audioFormat = format
                }
            }

            if (videoTrackIndex == -1 || videoFormat == null) {
                return mapOf(
                    "success" to false,
                    "errorCode" to "UNSUPPORTED_FORMAT",
                    "errorMessage" to "No video track found in input file."
                )
            }

            val durationUs = if (videoFormat.containsKey(MediaFormat.KEY_DURATION)) {
                videoFormat.getLong(MediaFormat.KEY_DURATION)
            } else {
                1000000L
            }

            val rotation = if (videoFormat.containsKey(MediaFormat.KEY_ROTATION)) {
                videoFormat.getInteger(MediaFormat.KEY_ROTATION)
            } else {
                0
            }

            outputFile.parentFile?.mkdirs()
            muxer = MediaMuxer(outputPath, MediaMuxer.OutputFormat.MUXER_OUTPUT_MPEG_4)
            if (rotation != 0) {
                muxer.setOrientationHint(rotation)
            }

            // Configure Encoder Format
            val outFormat = MediaFormat.createVideoFormat(targetMime, targetWidth, targetHeight).apply {
                setInteger(MediaFormat.KEY_COLOR_FORMAT, MediaCodecInfo.CodecCapabilities.COLOR_FormatYUV420Flexible)
                setInteger(MediaFormat.KEY_BIT_RATE, targetBitrate)
                setInteger(MediaFormat.KEY_FRAME_RATE, 30)
                setInteger(MediaFormat.KEY_I_FRAME_INTERVAL, 1)
            }

            encoder = MediaCodec.createEncoderByType(targetMime).apply {
                configure(outFormat, null, null, MediaCodec.CONFIGURE_FLAG_ENCODE)
                start()
            }

            val inputMime = videoFormat.getString(MediaFormat.KEY_MIME) ?: "video/avc"
            decoder = MediaCodec.createDecoderByType(inputMime).apply {
                configure(videoFormat, null, null, 0)
                start()
            }

            extractor.selectTrack(videoTrackIndex)

            var muxerVideoTrackIndex = -1
            var muxerAudioTrackIndex = -1
            var muxerStarted = false

            if (audioTrackIndex != -1 && audioFormat != null) {
                muxerAudioTrackIndex = muxer.addTrack(audioFormat)
            }

            val bufferInfo = MediaCodec.BufferInfo()
            var sawInputEOS = false
            var sawDecoderOutputEOS = false
            var sawEncoderOutputEOS = false
            var totalBytesProcessed = 0L

            while (!sawEncoderOutputEOS && !isCancelled) {
                if (!sawInputEOS) {
                    val inputBufIndex = decoder.dequeueInputBuffer(TIMEOUT_USEC)
                    if (inputBufIndex >= 0) {
                        val inputBuf = decoder.getInputBuffer(inputBufIndex)
                        if (inputBuf != null) {
                            val sampleSize = extractor.readSampleData(inputBuf, 0)
                            if (sampleSize < 0) {
                                decoder.queueInputBuffer(inputBufIndex, 0, 0, 0L, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                                sawInputEOS = true
                            } else {
                                val presentationTimeUs = extractor.sampleTime
                                decoder.queueInputBuffer(inputBufIndex, 0, sampleSize, presentationTimeUs, 0)
                                extractor.advance()
                                totalBytesProcessed += sampleSize
                            }
                        }
                    }
                }

                if (!sawDecoderOutputEOS) {
                    val decOutIndex = decoder.dequeueOutputBuffer(bufferInfo, TIMEOUT_USEC)
                    if (decOutIndex >= 0) {
                        if ((bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0) {
                            sawDecoderOutputEOS = true
                        }

                        val encInIndex = encoder.dequeueInputBuffer(TIMEOUT_USEC)
                        if (encInIndex >= 0) {
                            val encInBuf = encoder.getInputBuffer(encInIndex)
                            val decOutBuf = decoder.getOutputBuffer(decOutIndex)

                            if (encInBuf != null && decOutBuf != null && bufferInfo.size > 0) {
                                decOutBuf.position(bufferInfo.offset)
                                decOutBuf.limit(bufferInfo.offset + bufferInfo.size)
                                val copySize = Math.min(bufferInfo.size, encInBuf.capacity())
                                encInBuf.put(decOutBuf)

                                val flags = if (sawDecoderOutputEOS) MediaCodec.BUFFER_FLAG_END_OF_STREAM else 0
                                encoder.queueInputBuffer(encInIndex, 0, copySize, bufferInfo.presentationTimeUs, flags)
                            } else if (sawDecoderOutputEOS) {
                                encoder.queueInputBuffer(encInIndex, 0, 0, 0L, MediaCodec.BUFFER_FLAG_END_OF_STREAM)
                            }
                        }
                        decoder.releaseOutputBuffer(decOutIndex, false)
                    }
                }

                val encOutIndex = encoder.dequeueOutputBuffer(bufferInfo, TIMEOUT_USEC)
                if (encOutIndex == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED) {
                    val newFormat = encoder.outputFormat
                    muxerVideoTrackIndex = muxer.addTrack(newFormat)
                    muxer.start()
                    muxerStarted = true
                } else if (encOutIndex >= 0) {
                    val encOutBuf = encoder.getOutputBuffer(encOutIndex)
                    if (encOutBuf != null && muxerStarted) {
                        if ((bufferInfo.flags and MediaCodec.BUFFER_FLAG_CODEC_CONFIG) != 0) {
                            bufferInfo.size = 0
                        }

                        if (bufferInfo.size > 0) {
                            encOutBuf.position(bufferInfo.offset)
                            encOutBuf.limit(bufferInfo.offset + bufferInfo.size)
                            muxer.writeSampleData(muxerVideoTrackIndex, encOutBuf, bufferInfo)

                            val currentUs = bufferInfo.presentationTimeUs
                            val progress = if (durationUs > 0) {
                                (currentUs.toDouble() / durationUs.toDouble()).coerceIn(0.0, 1.0)
                            } else {
                                0.0
                            }

                            val elapsed = System.currentTimeMillis() - startTime
                            val estimatedRemainingMs = if (progress > 0.05) {
                                val totalEst = (elapsed / progress).toLong()
                                max(0L, totalEst - elapsed)
                            } else {
                                null
                            }

                            listener?.onProgress(progress, estimatedRemainingMs, totalBytesProcessed)
                        }

                        if ((bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM) != 0) {
                            sawEncoderOutputEOS = true
                        }
                    }
                    encoder.releaseOutputBuffer(encOutIndex, false)
                }
            }

            if (!isCancelled && audioTrackIndex != -1 && muxerStarted && muxerAudioTrackIndex != -1) {
                extractor.unselectTrack(videoTrackIndex)
                extractor.selectTrack(audioTrackIndex)
                extractor.seekTo(0, MediaExtractor.SEEK_TO_CLOSEST_SYNC)

                val audioBufferInfo = MediaCodec.BufferInfo()
                val audioBuffer = ByteBuffer.allocateDirect(128 * 1024)

                while (!isCancelled) {
                    val sampleSize = extractor.readSampleData(audioBuffer, 0)
                    if (sampleSize < 0) break

                    audioBufferInfo.offset = 0
                    audioBufferInfo.size = sampleSize
                    audioBufferInfo.presentationTimeUs = extractor.sampleTime
                    audioBufferInfo.flags = extractor.sampleFlags

                    muxer.writeSampleData(muxerAudioTrackIndex, audioBuffer, audioBufferInfo)
                    extractor.advance()
                }
            }

            if (isCancelled) {
                Log.w(TAG, "Compression aborted by user. Cleaning up output.")
                outputFile.delete()
                return mapOf(
                    "success" to false,
                    "isCancelled" to true,
                    "errorCode" to "CANCELLED",
                    "errorMessage" to "Operation cancelled by user."
                )
            }

            val compressedSize = outputFile.length()
            val durationMs = durationUs / 1000L

            listener?.onProgress(1.0, 0L, totalBytesProcessed)

            return mapOf(
                "success" to true,
                "outputPath" to outputPath,
                "originalSize" to originalSize,
                "compressedSize" to compressedSize,
                "durationMs" to durationMs
            )
        } catch (e: Exception) {
            Log.e(TAG, "Hardware video compression exception: ${e.message}", e)
            if (outputFile.exists()) {
                outputFile.delete()
            }
            return mapOf(
                "success" to false,
                "errorCode" to "COMPRESSION_FAILED",
                "errorMessage" to (e.message ?: "Native MediaCodec compression failed")
            )
        } finally {
            try {
                decoder?.stop()
                decoder?.release()
            } catch (_: Exception) {}

            try {
                encoder?.stop()
                encoder?.release()
            } catch (_: Exception) {}

            try {
                muxer?.stop()
                muxer?.release()
            } catch (_: Exception) {}

            try {
                extractor.release()
            } catch (_: Exception) {}
        }
    }
}
