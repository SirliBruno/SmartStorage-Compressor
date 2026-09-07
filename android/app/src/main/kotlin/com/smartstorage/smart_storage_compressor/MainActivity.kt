package com.smartstorage.smart_storage_compressor

import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.Executors

class MainActivity : FlutterActivity() {
    companion object {
        private const val METHOD_CHANNEL = "com.smartstorage.compressor/video_compression"
        private const val EVENT_CHANNEL = "com.smartstorage.compressor/compression_progress"
    }

    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())
    private val executor = Executors.newSingleThreadExecutor()
    private val compressor = MediaCodecVideoCompressor()

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. EventChannel for real-time progress streaming
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    eventSink = events
                }

                override fun onCancel(arguments: Any?) {
                    eventSink = null
                }
            }
        )

        // 2. MethodChannel for compression lifecycle control
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, METHOD_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startCompression" -> {
                    val inputPath = call.argument<String>("inputPath")
                    val outputPath = call.argument<String>("outputPath")
                    val targetWidth = call.argument<Int>("targetWidth") ?: 1280
                    val targetHeight = call.argument<Int>("targetHeight") ?: 720
                    val targetBitrate = call.argument<Int>("targetBitrate") ?: 2000000
                    val codec = call.argument<String>("codec") ?: "h264"
                    val jobId = call.argument<String>("jobId") ?: "unknown"

                    if (inputPath.isNullOrEmpty() || outputPath.isNullOrEmpty()) {
                        result.error("INVALID_ARGS", "inputPath and outputPath must not be null or empty", null)
                        return@setMethodCallHandler
                    }

                    // Execute asynchronously on background worker thread (Zero UI freezing)
                    executor.execute {
                        val progressListener = object : MediaCodecVideoCompressor.ProgressListener {
                            override fun onProgress(progress: Double, estimatedRemainingMs: Long?, bytesProcessed: Long) {
                                mainHandler.post {
                                    eventSink?.success(
                                        mapOf(
                                            "jobId" to jobId,
                                            "progress" to progress,
                                            "estimatedRemainingMs" to estimatedRemainingMs,
                                            "bytesProcessed" to bytesProcessed,
                                            "status" to if (progress >= 1.0) "completed" else "compressing"
                                        )
                                    )
                                }
                            }
                        }

                        val resultMap = compressor.compress(
                            inputPath = inputPath,
                            outputPath = outputPath,
                            targetWidth = targetWidth,
                            targetHeight = targetHeight,
                            targetBitrate = targetBitrate,
                            codec = codec,
                            listener = progressListener
                        )

                        mainHandler.post {
                            result.success(resultMap)
                        }
                    }
                }

                "cancelCompression" -> {
                    compressor.cancel()
                    mainHandler.post {
                        eventSink?.success(
                            mapOf(
                                "progress" to 0.0,
                                "isCancelled" to true,
                                "status" to "cancelled"
                            )
                        )
                    }
                    result.success(true)
                }

                "isCodecSupported" -> {
                    val codec = call.argument<String>("codec") ?: "h264"
                    val mime = if (codec.equals("hevc", ignoreCase = true)) "video/hevc" else "video/avc"
                    val supported = compressor.isCodecSupported(mime)
                    result.success(supported)
                }

                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
