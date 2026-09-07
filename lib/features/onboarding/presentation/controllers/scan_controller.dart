import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/media/media_scanner.dart';

enum ScanStatus { idle, scanning, success, error, cancelled }

/// Immutable state model for the Quick Scan experience.
class QuickScanState {
  final ScanStatus status;
  final double progress;
  final String currentTaskKey;
  final ScanResultData result;
  final String? errorMessage;

  const QuickScanState({
    this.status = ScanStatus.idle,
    this.progress = 0.0,
    this.currentTaskKey = 'scanningLibrary',
    this.result = const ScanResultData(),
    this.errorMessage,
  });

  bool get isScanning => status == ScanStatus.scanning;
  bool get isSuccess => status == ScanStatus.success;
  bool get isCancelled => status == ScanStatus.cancelled;

  QuickScanState copyWith({
    ScanStatus? status,
    double? progress,
    String? currentTaskKey,
    ScanResultData? result,
    String? errorMessage,
  }) {
    return QuickScanState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      currentTaskKey: currentTaskKey ?? this.currentTaskKey,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// StateNotifier driving real media scan progress and insights.
class ScanNotifier extends StateNotifier<QuickScanState> {
  final MediaScanner _scanner;
  StreamSubscription<ScanProgressUpdate>? _subscription;
  ScanCancellationToken? _cancellationToken;

  ScanNotifier(this._scanner) : super(const QuickScanState());

  /// Starts the genuine on-device scan.
  void startScan() {
    _subscription?.cancel();
    _cancellationToken = ScanCancellationToken();

    state = const QuickScanState(
      status: ScanStatus.scanning,
      progress: 0.05,
      currentTaskKey: 'scanningLibrary',
    );

    _subscription = _scanner.scanLibrary(cancellationToken: _cancellationToken).listen(
      (update) {
        if (_cancellationToken?.isCancelled == true) {
          state = state.copyWith(status: ScanStatus.cancelled);
          return;
        }

        if (update.progress >= 1.0 && update.partialResult.isCompleted) {
          state = QuickScanState(
            status: ScanStatus.success,
            progress: 1.0,
            currentTaskKey: 'scanResultHeader',
            result: update.partialResult,
          );
        } else {
          state = state.copyWith(
            progress: update.progress,
            currentTaskKey: update.currentTaskKey,
            result: update.partialResult,
          );
        }
      },
      onError: (Object error) {
        state = state.copyWith(
          status: ScanStatus.error,
          errorMessage: error.toString(),
        );
      },
    );
  }

  /// Cancels in-progress scanning without leaking resources.
  void cancelScan() {
    _cancellationToken?.cancel();
    _subscription?.cancel();
    state = state.copyWith(
      status: ScanStatus.cancelled,
      currentTaskKey: 'scanCancelledTitle',
    );
  }

  /// Sets scan state for unit tests.
  void setStateForTesting(QuickScanState newState) {
    state = newState;
  }

  @override
  void dispose() {
    _cancellationToken?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}

/// Global provider for MediaScanner.
final mediaScannerProvider = Provider<MediaScanner>((ref) {
  return LocalMediaScanner();
});

/// Global provider for QuickScanState.
final scanProvider = StateNotifierProvider<ScanNotifier, QuickScanState>((ref) {
  final scanner = ref.watch(mediaScannerProvider);
  return ScanNotifier(scanner);
});
