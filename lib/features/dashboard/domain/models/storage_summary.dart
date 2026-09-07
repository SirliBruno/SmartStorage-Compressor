/// Domain entity for real-time device storage overview.
class StorageSummary {
  final int totalStorageBytes;
  final int usedStorageBytes;
  final int freeStorageBytes;
  final int recoverableBytes;
  final int videoCount;
  final int screenshotCount;
  final bool isScanning;

  const StorageSummary({
    this.totalStorageBytes = 0,
    this.usedStorageBytes = 0,
    this.freeStorageBytes = 0,
    this.recoverableBytes = 0,
    this.videoCount = 0,
    this.screenshotCount = 0,
    this.isScanning = false,
  });

  /// True if storage scan has finished and discovered videos or screenshots.
  bool get hasScannedData => videoCount > 0 || screenshotCount > 0;

  StorageSummary copyWith({
    int? totalStorageBytes,
    int? usedStorageBytes,
    int? freeStorageBytes,
    int? recoverableBytes,
    int? videoCount,
    int? screenshotCount,
    bool? isScanning,
  }) {
    return StorageSummary(
      totalStorageBytes: totalStorageBytes ?? this.totalStorageBytes,
      usedStorageBytes: usedStorageBytes ?? this.usedStorageBytes,
      freeStorageBytes: freeStorageBytes ?? this.freeStorageBytes,
      recoverableBytes: recoverableBytes ?? this.recoverableBytes,
      videoCount: videoCount ?? this.videoCount,
      screenshotCount: screenshotCount ?? this.screenshotCount,
      isScanning: isScanning ?? this.isScanning,
    );
  }
}
