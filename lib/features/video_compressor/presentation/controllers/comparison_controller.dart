import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/temp_file_manager.dart';
import '../../../../services/media/media_save_service.dart';
import '../../domain/models/compression_session.dart';
import 'video_library_controller.dart';

/// State of the persistent save/replace operation in the comparison screen.
enum SaveStatus {
  idle,
  saving,
  saved,
  confirmingReplace,
  replacing,
  replaced,
  failed,
}

/// Immutable state for the video comparison and save lifecycle.
class ComparisonState {
  final CompressionSession session;
  final SaveStatus saveStatus;
  final String? errorMessage;
  final bool originalDeleted;

  const ComparisonState({
    required this.session,
    this.saveStatus = SaveStatus.idle,
    this.errorMessage,
    this.originalDeleted = false,
  });

  ComparisonState copyWith({
    CompressionSession? session,
    SaveStatus? saveStatus,
    String? errorMessage,
    bool? originalDeleted,
  }) {
    return ComparisonState(
      session: session ?? this.session,
      saveStatus: saveStatus ?? this.saveStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      originalDeleted: originalDeleted ?? this.originalDeleted,
    );
  }

  /// Whether a write operation is currently in progress
  bool get isProcessing =>
      saveStatus == SaveStatus.saving || saveStatus == SaveStatus.replacing;

  /// Whether the session has successfully saved or replaced
  bool get isSuccess =>
      saveStatus == SaveStatus.saved || saveStatus == SaveStatus.replaced;

  /// Convenience getters for presentation
  int get originalSizeBytes => session.originalSizeBytes;
  int get compressedSizeBytes => session.compressedSizeBytes;
  int get savedBytes => session.savedBytes;
  double get savedPercentage => session.savedPercentage;
}

/// Controller driving the video comparison screen, atomic save flows, and double-save prevention.
class ComparisonNotifier extends StateNotifier<ComparisonState> {
  final MediaSaveService _saveService;
  final TempFileManager _tempFileManager;
  final Ref _ref;

  ComparisonNotifier({
    required CompressionSession initialSession,
    required MediaSaveService saveService,
    required TempFileManager tempFileManager,
    required Ref ref,
  })  : _saveService = saveService,
        _tempFileManager = tempFileManager,
        _ref = ref,
        super(ComparisonState(session: initialSession));

  /// Saves the compressed video as a new file in the user's gallery.
  Future<bool> saveAsCopy() async {
    if (state.isProcessing || state.isSuccess) {
      AppLogger.warn('Save ignored: Operation already in progress or completed.');
      return false;
    }

    state = state.copyWith(saveStatus: SaveStatus.saving, errorMessage: null);

    try {
      final title = '${state.session.originalAsset.title}_compressed';
      final result = await _saveService.saveAsCopy(
        compressedPath: state.session.compressedPath,
        title: title,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          saveStatus: SaveStatus.saved,
          session: state.session.copyWith(status: CompressionSessionStatus.saved),
        );
        // Refresh device video library
        unawaited(_ref.read(videoLibraryProvider.notifier).loadVideos(forceRefresh: true));
        return true;
      } else {
        state = state.copyWith(
          saveStatus: SaveStatus.failed,
          errorMessage: result.errorMessage ?? 'Failed to save compressed video to gallery.',
        );
        return false;
      }
    } catch (e, stack) {
      AppLogger.error('Error during saveAsCopy: $e', e, stack);
      state = state.copyWith(
        saveStatus: SaveStatus.failed,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  /// Triggers confirmation state for Replace Original.
  void showReplaceConfirmation() {
    if (!state.isProcessing && !state.isSuccess) {
      state = state.copyWith(saveStatus: SaveStatus.confirmingReplace);
    }
  }

  /// Cancels replace confirmation dialog.
  void cancelReplaceConfirmation() {
    if (state.saveStatus == SaveStatus.confirmingReplace) {
      state = state.copyWith(saveStatus: SaveStatus.idle);
    }
  }

  /// Atomically replaces the original video with the compressed version.
  Future<bool> confirmReplaceOriginal() async {
    if (state.isProcessing || state.isSuccess) {
      AppLogger.warn('Replace ignored: Operation already in progress or completed.');
      return false;
    }

    state = state.copyWith(saveStatus: SaveStatus.replacing, errorMessage: null);

    try {
      final result = await _saveService.replaceOriginal(
        originalAssetId: state.session.originalAsset.id,
        compressedPath: state.session.compressedPath,
        title: state.session.originalAsset.title,
      );

      if (result.isSuccess) {
        state = state.copyWith(
          saveStatus: SaveStatus.replaced,
          originalDeleted: result.originalDeleted,
          session: state.session.copyWith(status: CompressionSessionStatus.replaced),
        );
        // Refresh device video library
        unawaited(_ref.read(videoLibraryProvider.notifier).loadVideos(forceRefresh: true));
        return true;
      } else {
        state = state.copyWith(
          saveStatus: SaveStatus.failed,
          errorMessage: result.errorMessage ?? 'Failed to replace original video. Original preserved.',
        );
        return false;
      }
    } catch (e, stack) {
      AppLogger.error('Error during confirmReplaceOriginal: $e', e, stack);
      state = state.copyWith(
        saveStatus: SaveStatus.failed,
        errorMessage: 'Replace failed: $e. Original preserved.',
      );
      return false;
    }
  }

  /// Cleans up temporary files when navigating away or exiting the session.
  Future<void> cleanupSession() async {
    try {
      AppLogger.info('Cleaning up temp output for session: ${state.session.sessionId}');
      await _tempFileManager.deleteTempFile(state.session.compressedPath);
    } catch (e) {
      AppLogger.warn('Failed cleaning session temp file: $e');
    }
  }
}

/// Family provider creating a ComparisonNotifier for a given CompressionSession.
final comparisonControllerProvider = StateNotifierProvider.autoDispose
    .family<ComparisonNotifier, ComparisonState, CompressionSession>((ref, session) {
  final saveService = ref.watch(mediaSaveServiceProvider);
  final tempFileManager = TempFileManager();
  return ComparisonNotifier(
    initialSession: session,
    saveService: saveService,
    tempFileManager: tempFileManager,
    ref: ref,
  );
});
