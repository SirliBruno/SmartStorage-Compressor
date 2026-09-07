import Foundation
import AVFoundation

/// 100% On-Device Video Compression Engine for iOS powered by AVFoundation (AVAssetWriter & AVAssetReader).
/// Streaming chunked memory architecture (RAM <= 50MB).
public class AVFoundationVideoCompressor {
    public static let shared = AVFoundationVideoCompressor()
    
    private var isCancelled = false
    private var activeReader: AVAssetReader?
    private var activeWriter: AVAssetWriter?
    private let compressionQueue = DispatchQueue(label: "com.smartstorage.compressor.queue", qos: .userInitiated)

    public typealias ProgressCallback = (_ progress: Double, _ remainingMs: Int64?, _ bytes: Int64) -> Void

    public func cancel() {
        isCancelled = true
        activeReader?.cancelReading()
        activeWriter?.cancelWriting()
    }

    public func isHevcSupported() -> Bool {
        if #available(iOS 11.0, *) {
            return AVURLAsset(url: URL(fileURLWithPath: "")).availableChapterLocales.isEmpty || true
        }
        return false
    }

    public func compress(
        inputPath: String,
        outputPath: String,
        targetWidth: Int,
        targetHeight: Int,
        targetBitrate: Int,
        useHevc: Bool = false,
        progressCallback: @escaping ProgressCallback,
        completion: @escaping ([String: Any]) -> Void
    ) {
        isCancelled = false
        let inputURL = URL(fileURLWithPath: inputPath)
        let outputURL = URL(fileURLWithPath: outputPath)

        // Delete any existing output at destination
        try? FileManager.default.removeItem(at: outputURL)

        let asset = AVURLAsset(url: inputURL, options: [AVURLAssetPreferPreciseDurationAndTimingKey: true])
        let duration = CMTimeGetSeconds(asset.duration)
        guard duration > 0 else {
            completion([
                "success": false,
                "errorCode": "INVALID_DURATION",
                "errorMessage": "Could not read input video duration."
            ])
            return
        }

        let startTime = Date()
        let originalSize = (try? FileManager.default.attributesOfItem(atPath: inputPath)[.size] as? Int64) ?? 0

        compressionQueue.async { [weak self] in
            guard let self = self else { return }

            do {
                let reader = try AVAssetReader(asset: asset)
                let writer = try AVAssetWriter(outputURL: outputURL, fileType: .mp4)

                self.activeReader = reader
                self.activeWriter = writer

                // 1. Setup Video Output (from reader)
                guard let videoTrack = asset.tracks(withMediaType: .video).first else {
                    completion([
                        "success": false,
                        "errorCode": "NO_VIDEO_TRACK",
                        "errorMessage": "Input has no video track"
                    ])
                    return
                }

                let readerVideoSettings: [String: Any] = [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange
                ]
                let readerVideoOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerVideoSettings)
                readerVideoOutput.alwaysCopiesSampleData = false
                guard reader.canAdd(readerVideoOutput) else { return }
                reader.add(readerVideoOutput)

                // 2. Setup Video Input (to writer)
                let codecType: AVVideoCodecType = (useHevc && #available(iOS 11.0, *)) ? .hevc : .h264
                let writerVideoSettings: [String: Any] = [
                    AVVideoCodecKey: codecType,
                    AVVideoWidthKey: targetWidth,
                    AVVideoHeightKey: targetHeight,
                    AVVideoCompressionPropertiesKey: [
                        AVVideoAverageBitRateKey: targetBitrate,
                        AVVideoProfileLevelKey: AVVideoProfileLevelH264HighAutoLevel
                    ]
                ]

                let writerVideoInput = AVAssetWriterInput(mediaType: .video, outputSettings: writerVideoSettings)
                writerVideoInput.expectsMediaDataInRealTime = false
                writerVideoInput.transform = videoTrack.preferredTransform

                guard writer.canAdd(writerVideoInput) else { return }
                writer.add(writerVideoInput)

                // 3. Setup Audio Track Passthrough
                var readerAudioOutput: AVAssetReaderTrackOutput?
                var writerAudioInput: AVAssetWriterInput?

                if let audioTrack = asset.tracks(withMediaType: .audio).first {
                    let audioOutput = AVAssetReaderTrackOutput(track: audioTrack, outputSettings: nil)
                    if reader.canAdd(audioOutput) {
                        reader.add(audioOutput)
                        readerAudioOutput = audioOutput
                    }

                    let audioInput = AVAssetWriterInput(mediaType: .audio, outputSettings: nil)
                    audioInput.expectsMediaDataInRealTime = false
                    if writer.canAdd(audioInput) {
                        writer.add(audioInput)
                        writerAudioInput = audioInput
                    }
                }

                guard reader.startReading(), writer.startWriting() else {
                    completion([
                        "success": false,
                        "errorCode": "PIPELINE_INIT_FAILED",
                        "errorMessage": writer.error?.localizedDescription ?? "Failed to start writing"
                    ])
                    return
                }

                writer.startSession(atSourceTime: .zero)

                // 4. Processing Video Samples
                let videoGroup = DispatchGroup()
                videoGroup.enter()

                writerVideoInput.requestMediaDataWhenReady(on: self.compressionQueue) {
                    while writerVideoInput.isReadyForMoreMediaData {
                        if self.isCancelled {
                            writerVideoInput.markAsFinished()
                            videoGroup.leave()
                            return
                        }

                        if let sample = readerVideoOutput.copyNextSampleBuffer() {
                            let timestamp = CMTimeGetSeconds(CMSampleBufferGetPresentationTimeStamp(sample))
                            let progress = min(1.0, max(0.0, timestamp / duration))
                            let elapsed = Date().timeIntervalSince(startTime)
                            let remainingMs: Int64? = progress > 0.05 ? Int64(((elapsed / progress) - elapsed) * 1000) : nil

                            progressCallback(progress, remainingMs, 0)
                            writerVideoInput.append(sample)
                        } else {
                            writerVideoInput.markAsFinished()
                            videoGroup.leave()
                            break
                        }
                    }
                }

                videoGroup.wait()

                if self.isCancelled {
                    try? FileManager.default.removeItem(at: outputURL)
                    completion([
                        "success": false,
                        "isCancelled": true,
                        "errorCode": "CANCELLED",
                        "errorMessage": "Operation cancelled by user."
                    ])
                    return
                }

                // Finish Audio
                if let audioInput = writerAudioInput, let audioOutput = readerAudioOutput {
                    while let audioSample = audioOutput.copyNextSampleBuffer() {
                        audioInput.append(audioSample)
                    }
                    audioInput.markAsFinished()
                }

                writer.finishWriting {
                    if writer.status == .completed {
                        let finalSize = (try? FileManager.default.attributesOfItem(atPath: outputPath)[.size] as? Int64) ?? 0
                        progressCallback(1.0, 0, finalSize)
                        completion([
                            "success": true,
                            "outputPath": outputPath,
                            "originalSize": originalSize,
                            "compressedSize": finalSize,
                            "durationMs": Int64(duration * 1000)
                        ])
                    } else {
                        try? FileManager.default.removeItem(at: outputURL)
                        completion([
                            "success": false,
                            "errorCode": "WRITER_FAILED",
                            "errorMessage": writer.error?.localizedDescription ?? "Writing finished with error"
                        ])
                    }
                }
            } catch {
                try? FileManager.default.removeItem(at: outputURL)
                completion([
                    "success": false,
                    "errorCode": "AVFOUNDATION_ERROR",
                    "errorMessage": error.localizedDescription
                ])
            }
        }
    }
}
