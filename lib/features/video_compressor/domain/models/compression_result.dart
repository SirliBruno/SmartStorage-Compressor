import 'compression_status.dart';

/// Real-time compression progress update emitted by native engine.
class CompressionProgress {
  /// Normalized progress from 0.0 to 1.0
  final double progress;

  /// Estimated time remaining based on elapsed time and throughput
  final Duration? estimatedRemaining;

  /// Processed bytes so far (chunked stream measurement)
  final int bytesProcessed;

  /// Current lifecycle status
  final CompressionStatus status;

  /// Whether the job was requested to abort
  final bool isCancelled;

  const CompressionProgress({
    required this.progress,
    this.estimatedRemaining,
    this.bytesProcessed = 0,
    this.status = CompressionStatus.compressing,
    this.isCancelled = false,
  });

  /// Human-readable percentage: 0.0% to 100.0%
  double get percentage => (progress * 100.0).clamp(0.0, 100.0);

  /// Formatted percentage string (e.g. 42.5%)
  String get formattedPercentage => '%';

  /// Initial idle state
  static const initial = CompressionProgress(
    progress: 0.0,
    status: CompressionStatus.idle,
  );
}

/// Final outcome of a video compression job execution.
class CompressionResult {
  final bool success;
  final String? originalPath;
  final String? outputPath;
  final int? originalSize;
  final int? compressedSize;
  final Duration? duration;
  final Duration? processingTime;
  final String? errorCode;
  final String? errorMessage;

  const CompressionResult({
    required this.success,
    this.originalPath,
    this.outputPath,
    this.originalSize,
    this.compressedSize,
    this.duration,
    this.processingTime,
    this.errorCode,
    this.errorMessage,
  });

  /// Factory helper for successful outcome
  factory CompressionResult.successResult({
    required String originalPath,
    required String outputPath,
    required int originalSize,
    required int compressedSize,
    required Duration duration,
    required Duration processingTime,
  }) {
    return CompressionResult(
      success: true,
      originalPath: originalPath,
      outputPath: outputPath,
      originalSize: originalSize,
      compressedSize: compressedSize,
      duration: duration,
      processingTime: processingTime,
    );
  }

  /// Factory helper for successful outcome (compact alias)
  factory CompressionResult.success({
    required String outputPath,
    required int originalBytes,
    required int compressedBytes,
    Duration duration = Duration.zero,
    Duration processingTime = Duration.zero,
    String originalPath = '',
  }) {
    return CompressionResult(
      success: true,
      originalPath: originalPath,
      outputPath: outputPath,
      originalSize: originalBytes,
      compressedSize: compressedBytes,
      duration: duration,
      processingTime: processingTime,
    );
  }

  /// Factory helper for failure outcome
  factory CompressionResult.failure({
    String errorCode = 'COMPRESSION_FAILED',
    String? errorMessage,
    String? error,
    String? originalPath,
  }) {
    return CompressionResult(
      success: false,
      originalPath: originalPath,
      errorCode: errorCode,
      errorMessage: errorMessage ?? error ?? 'Compression failed',
    );
  }

  /// Factory helper for user cancellation outcome
  factory CompressionResult.cancelled({String? originalPath}) {
    return CompressionResult(
      success: false,
      originalPath: originalPath,
      errorCode: 'CANCELLED',
      errorMessage: 'Compression was cancelled by user.',
    );
  }

  /// Convenience getters
  bool get isSuccess => success;
  bool get isCancelled => errorCode == 'CANCELLED';

  /// Backward compatibility aliases
  String get compressedPath => outputPath ?? '';
  int get originalSizeBytes => originalSize ?? 0;
  int get compressedSizeBytes => compressedSize ?? 0;

  /// Computed percentage of storage space saved.
  /// Example: 185MB -> 32MB = 82.7%
  double get savedPercentage {
    final orig = originalSize ?? 0;
    final comp = compressedSize ?? 0;
    if (orig <= 0 || comp >= orig) return 0.0;
    return ((orig - comp) / orig) * 100.0;
  }

  /// Absolute number of bytes saved.
  int get savedBytes {
    final orig = originalSize ?? 0;
    final comp = compressedSize ?? 0;
    return orig > comp ? orig - comp : 0;
  }

  /// Formatted string of percentage saved (e.g. "75.0%").
  String get savedFormatted => '${savedPercentage.toStringAsFixed(1)}%';
}
