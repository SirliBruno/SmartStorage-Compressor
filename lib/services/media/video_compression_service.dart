import '../../features/video_compressor/domain/models/compression_preset.dart';
import '../../features/video_compressor/domain/models/compression_result.dart';

/// Clean abstraction for the Hardware Video Compression Engine.
/// Decouples Flutter Presentation/Domain layers completely from native AVFoundation/MediaCodec.
abstract class VideoCompressionService {
  /// Initiates hardware video compression asynchronously.
  Future<CompressionResult> compressVideo({
    required String inputPath,
    required String outputPath,
    required CompressionConfig config,
  });

  /// Immediately aborts any ongoing compression and cleans up temporary resources.
  Future<void> cancelCompression();

  /// Real-time progress stream (0.0 to 100.0, ETA, bytes processed).
  Stream<CompressionProgress> get progressStream;

  /// Checks if hardware HEVC / H.265 is supported on the current device.
  Future<bool> isHevcSupported();
}
