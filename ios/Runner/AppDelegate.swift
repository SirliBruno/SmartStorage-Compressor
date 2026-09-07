import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate, FlutterStreamHandler {
    private var eventSink: FlutterEventSink?

    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController

        // 1. EventChannel for Progress Streaming
        let eventChannel = FlutterEventChannel(name: "com.smartstorage.compressor/compression_progress", binaryMessenger: controller.binaryMessenger)
        eventChannel.setStreamHandler(self)

        // 2. MethodChannel for Compression Commands
        let methodChannel = FlutterMethodChannel(name: "com.smartstorage.compressor/video_compression", binaryMessenger: controller.binaryMessenger)
        methodChannel.setMethodCallHandler({ [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
            guard let self = self else { return }

            switch call.method {
            case "startCompression":
                guard let args = call.arguments as? [String: Any],
                      let inputPath = args["inputPath"] as? String,
                      let outputPath = args["outputPath"] as? String else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Invalid parameters", details: nil))
                    return
                }

                let targetWidth = args["targetWidth"] as? Int ?? 1280
                let targetHeight = args["targetHeight"] as? Int ?? 720
                let targetBitrate = args["targetBitrate"] as? Int ?? 2000000
                let codec = args["codec"] as? String ?? "h264"
                let useHevc = codec.lowercased() == "hevc"
                let jobId = args["jobId"] as? String ?? "job"

                AVFoundationVideoCompressor.shared.compress(
                    inputPath: inputPath,
                    outputPath: outputPath,
                    targetWidth: targetWidth,
                    targetHeight: targetHeight,
                    targetBitrate: targetBitrate,
                    useHevc: useHevc,
                    progressCallback: { progress, remainingMs, bytes in
                        DispatchQueue.main.async {
                            self.eventSink?([
                                "jobId": jobId,
                                "progress": progress,
                                "estimatedRemainingMs": remainingMs as Any,
                                "bytesProcessed": bytes,
                                "status": progress >= 1.0 ? "completed" : "compressing"
                            ])
                        }
                    },
                    completion: { res in
                        DispatchQueue.main.async {
                            result(res)
                        }
                    }
                )

            case "cancelCompression":
                AVFoundationVideoCompressor.shared.cancel()
                DispatchQueue.main.async {
                    self.eventSink?([
                        "progress": 0.0,
                        "isCancelled": true,
                        "status": "cancelled"
                    ])
                    result(true)
                }

            case "isCodecSupported":
                let args = call.arguments as? [String: Any]
                let codec = args?["codec"] as? String ?? "h264"
                if codec.lowercased() == "hevc" {
                    result(AVFoundationVideoCompressor.shared.isHevcSupported())
                } else {
                    result(true)
                }

            default:
                result(FlutterMethodNotImplemented)
            }
        })

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = events
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        self.eventSink = nil
        return nil
    }
}
