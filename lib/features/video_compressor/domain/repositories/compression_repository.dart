import '../models/compression_preset.dart';
import '../models/compression_result.dart';
import '../models/video_asset.dart';

/// Repository contract managing video compression operations, strategies, and output verification.
abstract class CompressionRepository {
  /// Prepares and executes video compression with dynamic bitrate resolution.
  Future<CompressionResult> compressVideo({
    required VideoAsset video,
    required CompressionPreset preset,
    int? customTargetSizeBytes,
  });

  /// Aborts an ongoing compression job and cleans up partial disk files.
  Future<bool> cancelCompression(String jobId);

  /// Real-time stream of hardware progress updates.
  Stream<CompressionProgress> get progressStream;

  /// Verifies generated output integrity.
  Future<bool> validateOutput(String outputPath, int originalSizeBytes);
}
