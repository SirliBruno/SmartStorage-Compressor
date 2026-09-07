/// Real-time lifecycle status of a video compression job.
enum CompressionStatus {
  idle,
  preparing,
  compressing,
  completed,
  cancelled,
  failed,
}

extension CompressionStatusX on CompressionStatus {
  bool get isIdle => this == CompressionStatus.idle;
  bool get isPreparing => this == CompressionStatus.preparing;
  bool get isCompressing => this == CompressionStatus.compressing;
  bool get isCompleted => this == CompressionStatus.completed;
  bool get isCancelled => this == CompressionStatus.cancelled;
  bool get isFailed => this == CompressionStatus.failed;
  bool get isActive => isPreparing || isCompressing;
  bool get isFinished => isCompleted || isCancelled || isFailed;
}
