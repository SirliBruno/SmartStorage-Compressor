import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/storage_summary.dart';

/// Riverpod StateNotifier managing Dashboard metrics and storage scanning state.
class DashboardNotifier extends StateNotifier<StorageSummary> {
  DashboardNotifier() : super(const StorageSummary());

  /// Sets scan in progress.
  void startScanning() {
    state = state.copyWith(isScanning: true);
  }

  /// Updates real storage metrics discovered locally without fake data.
  void updateMetrics({
    required int totalStorageBytes,
    required int usedStorageBytes,
    required int freeStorageBytes,
    required int recoverableBytes,
    required int videoCount,
    required int screenshotCount,
  }) {
    state = StorageSummary(
      totalStorageBytes: totalStorageBytes,
      usedStorageBytes: usedStorageBytes,
      freeStorageBytes: freeStorageBytes,
      recoverableBytes: recoverableBytes,
      videoCount: videoCount,
      screenshotCount: screenshotCount,
      isScanning: false,
    );
  }

  /// Subtracts recovered bytes and decrements items after a clean/compression action.
  void recordSavings({required int bytesFreed, bool isVideo = false}) {
    final newRecoverable = (state.recoverableBytes - bytesFreed).clamp(0, state.totalStorageBytes);
    final newUsed = (state.usedStorageBytes - bytesFreed).clamp(0, state.totalStorageBytes);
    final newFree = state.freeStorageBytes + bytesFreed;

    state = state.copyWith(
      recoverableBytes: newRecoverable,
      usedStorageBytes: newUsed,
      freeStorageBytes: newFree,
      videoCount: isVideo ? (state.videoCount - 1).clamp(0, 99999) : state.videoCount,
      screenshotCount: !isVideo ? (state.screenshotCount - 1).clamp(0, 99999) : state.screenshotCount,
    );
  }
}

/// Global provider for dashboard metrics.
final dashboardProvider = StateNotifierProvider<DashboardNotifier, StorageSummary>((ref) {
  return DashboardNotifier();
});
