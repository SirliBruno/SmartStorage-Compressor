import 'compression_preset.dart';

/// Immutable domain request specifying complete parameters for native video compression.
class CompressionRequest {
  final String jobId;
  final String assetId;
  final String inputPath;
  final String outputPath;
  final CompressionPreset preset;
  final int targetResolutionWidth;
  final int targetResolutionHeight;
  final int targetBitrateBps;
  final int audioBitrateBps;
  final bool useHevc;
  final int? targetSizeBytes;

  const CompressionRequest({
    required this.jobId,
    required this.assetId,
    required this.inputPath,
    required this.outputPath,
    required this.preset,
    required this.targetResolutionWidth,
    required this.targetResolutionHeight,
    required this.targetBitrateBps,
    this.audioBitrateBps = 128000,
    this.useHevc = false,
    this.targetSizeBytes,
  });

  Map<String, dynamic> toPlatformMap() {
    return {
      'jobId': jobId,
      'assetId': assetId,
      'inputPath': inputPath,
      'outputPath': outputPath,
      'targetWidth': targetResolutionWidth,
      'targetHeight': targetResolutionHeight,
      'targetBitrate': targetBitrateBps,
      'audioBitrate': audioBitrateBps,
      'codec': useHevc ? 'hevc' : 'h264',
      'targetSizeBytes': targetSizeBytes,
    };
  }
}
