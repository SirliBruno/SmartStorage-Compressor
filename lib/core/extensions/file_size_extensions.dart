import 'dart:math';

/// Extension on integer byte values to format human-readable file sizes and compute reductions.
extension FileSizeExtensions on int {
  /// Formats byte count to human-readable format (e.g., "12.4 MB", "1.8 GB").
  String formatBytes({int decimals = 1}) {
    if (this <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    final i = (log(this) / log(1024)).floor().clamp(0, suffixes.length - 1);
    final size = this / pow(1024, i);
    return '${size.toStringAsFixed(i == 0 ? 0 : decimals)} ${suffixes[i]}';
  }

  /// Backward-compatibility alias for formatBytes
  String formatFileSize({int decimals = 1}) => formatBytes(decimals: decimals);

  /// Calculates percentage saved compared to a smaller/compressed byte size.
  /// Example: 1000.calculateSavedPercentage(200) -> 80.0
  double calculateSavedPercentage(int compressedBytes) {
    if (this <= 0 || compressedBytes >= this) return 0.0;
    final savedBytes = this - compressedBytes;
    return (savedBytes / this) * 100.0;
  }
}
