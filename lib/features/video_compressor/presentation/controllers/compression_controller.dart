import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/models/compression_preset.dart';
import '../../domain/models/compression_result.dart';
import '../../domain/models/compression_status.dart';
import '../../domain/models/video_asset.dart';
import '../../domain/repositories/compression_repository.dart';
import '../../data/repositories/compression_repository_impl.dart';

/// Immutable UI state for the video compression process.
class CompressionState {
  final CompressionStatus status;
  final double progress; // 0.0 to 1.0
  final Duration? estimatedRemaining;
  final CompressionResult? result;
  final VideoAsset? currentVideo;
  final CompressionPreset selectedPreset;
  final String? errorMessage;
  final String? currentJobId;

  const CompressionState({
    this.status = CompressionStatus.idle,
    this.progress = 0.0,
    this.estimatedRemaining,
    this.result,
    this.currentVideo,
    this.selectedPreset = CompressionPreset.whatsappFast,
    this.errorMessage,
    this.currentJobId,
  });

  CompressionState copyWith({
    CompressionStatus? status,
    double? progress,
    Duration? estimatedRemaining,
    CompressionResult? result,
    VideoAsset? currentVideo,
    CompressionPreset? selectedPreset,
    String? errorMessage,
    String? currentJobId,
  }) {
    return CompressionState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      estimatedRemaining: estimatedRemaining ?? this.estimatedRemaining,
      result: result ?? this.result,
      currentVideo: currentVideo ?? this.currentVideo,
      selectedPreset: selectedPreset ?? this.selectedPreset,
      errorMessage: errorMessage ?? this.errorMessage,
      currentJobId: currentJobId ?? this.currentJobId,
    );
  }

  bool get isCompressing => status.isCompressing;
  bool get isCompleted => status.isCompleted;
  bool get isCancelled => status.isCancelled;
  bool get isFailed => status.isFailed;
  double get percentage => (progress * 100.0).clamp(0.0, 100.0);
}

/// StateNotifier managing hardware compression lifecycle and event stream.
class CompressionNotifier extends StateNotifier<CompressionState> {
  final CompressionRepository _repository;
  StreamSubscription<CompressionProgress>? _progressSubscription;

  CompressionNotifier(this._repository) : super(const CompressionState()) {
    _listenToProgress();
  }

  void _listenToProgress() {
    _progressSubscription = _repository.progressStream.listen(
      (update) {
        if (state.status.isActive) {
          state = state.copyWith(
            progress: update.progress,
            estimatedRemaining: update.estimatedRemaining,
            status: update.isCancelled ? CompressionStatus.cancelled : update.status,
          );
        }
      },
      onError: (Object err) {
        AppLogger.error('Error in compression progress stream', err);
      },
    );
  }

  /// Starts compression for a selected video and preset.
  Future<void> startCompression({
    required VideoAsset video,
    required CompressionPreset preset,
    int? customTargetSizeBytes,
  }) async {
    state = state.copyWith(
      status: CompressionStatus.preparing,
      progress: 0.0,
      estimatedRemaining: null,
      currentVideo: video,
      selectedPreset: preset,
      errorMessage: null,
      result: null,
    );

    // Transition to compressing
    state = state.copyWith(status: CompressionStatus.compressing);

    final result = await _repository.compressVideo(
      video: video,
      preset: preset,
      customTargetSizeBytes: customTargetSizeBytes,
    );

    if (result.success) {
      state = state.copyWith(
        status: CompressionStatus.completed,
        progress: 1.0,
        result: result,
      );
    } else if (result.errorCode == 'CANCELLED') {
      state = state.copyWith(
        status: CompressionStatus.cancelled,
        result: result,
      );
    } else {
      state = state.copyWith(
        status: CompressionStatus.failed,
        errorMessage: result.errorMessage ?? 'Compression failed.',
        result: result,
      );
    }
  }

  /// Immediately cancels the running native compression job.
  Future<void> cancelCompression() async {
    final jobId = state.currentJobId ?? '';
    state = state.copyWith(status: CompressionStatus.cancelled);
    await _repository.cancelCompression(jobId);
  }

  /// Resets state back to idle for next video compression.
  void reset() {
    state = const CompressionState();
  }

  @override
  void dispose() {
    _progressSubscription?.cancel();
    super.dispose();
  }
}

/// Global provider for CompressionNotifier
final compressionProvider = StateNotifierProvider<CompressionNotifier, CompressionState>((ref) {
  final repository = ref.watch(compressionRepositoryProvider);
  return CompressionNotifier(repository);
});
