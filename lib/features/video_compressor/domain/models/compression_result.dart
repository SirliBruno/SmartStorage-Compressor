/// Real-time compression progress update emitted by native engine.
class CompressionProgress {
  final double percentage; // 0.0 to 100.0
  final Duration? remainingTime;
  final int bytesProcessed;
  final bool isCancelled;

  const CompressionProgress({
    required this.percentage,
    this.remainingTime,
    this.bytesProcessed = 0,
    this.isCancelled = false,
  });

  static const initial = CompressionProgress(percentage: 0.0);
}

/// Final outcome of a successfully executed video compression.
class CompressionResult {
  final String originalPath;
  final String compressedPath;
  final int originalSizeBytes;
  final int compressedSizeBytes;
  final Duration duration;
  final Duration processingTime;

  const CompressionResult({
    required this.originalPath,
    required this.compressedPath,
    required this.originalSizeBytes,
    required this.compressedSizeBytes,
    required this.duration,
    required this.processingTime,
  });

  /// Computed percentage of storage space saved.
  /// Example: 320MB -> 28MB = 91.25%
  double get savedPercentage {
    if (originalSizeBytes <= 0 || compressedSizeBytes >= originalSizeBytes) {
      return 0.0;
    }
    return ((originalSizeBytes - compressedSizeBytes) / originalSizeBytes) * 100.0;
  }

  /// Absolute number of bytes recovered.
  int get savedBytes => originalSizeBytes > compressedSizeBytes
      ? originalSizeBytes - compressedSizeBytes
      : 0;
}
