/// Data model representing the calculated insights from a local media scan.
class ScanResultData {
  final int videoCount;
  final int screenshotCount;
  final int totalScannedBytes;
  final int estimatedRecoverableBytes;
  final bool isCompleted;

  const ScanResultData({
    this.videoCount = 0,
    this.screenshotCount = 0,
    this.totalScannedBytes = 0,
    this.estimatedRecoverableBytes = 0,
    this.isCompleted = false,
  });

  bool get hasMedia => videoCount > 0 || screenshotCount > 0;

  static const empty = ScanResultData();
}

/// Real-time progress update emitted during local media scanning.
class ScanProgressUpdate {
  final double progress; // 0.0 to 1.0
  final String currentTaskKey; // Localization key for task description
  final ScanResultData partialResult;

  const ScanProgressUpdate({
    required this.progress,
    required this.currentTaskKey,
    required this.partialResult,
  });
}

/// Token to signal cancellation of an in-progress scan.
class ScanCancellationToken {
  bool isCancelled = false;
  void cancel() {
    isCancelled = true;
  }
}
