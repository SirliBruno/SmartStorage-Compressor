import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photo_manager/photo_manager.dart';
import '../../core/utils/logger.dart';
import '../analytics/analytics_service.dart';

/// Outcome of a media save/replace operation.
enum SaveOutcome {
  success,
  failed,
  permissionDenied,
}

/// Result object describing the output of a gallery save operation.
class MediaSaveResult {
  final SaveOutcome outcome;
  final String? savedAssetId;
  final String? errorMessage;
  final bool originalDeleted;

  const MediaSaveResult({
    required this.outcome,
    this.savedAssetId,
    this.errorMessage,
    this.originalDeleted = false,
  });

  bool get isSuccess => outcome == SaveOutcome.success;
  bool get isPermissionDenied => outcome == SaveOutcome.permissionDenied;
}

/// Contract for saving and atomically replacing videos in the native device library.
abstract class MediaSaveService {
  /// Saves compressed video file as a new copy into system gallery (MediaStore / PhotoKit).
  Future<MediaSaveResult> saveAsCopy({
    required String compressedPath,
    required String title,
  });

  /// Atomically replaces the original video asset with the compressed copy.
  /// Guarantees that the original is NEVER deleted if saving or validating the compressed version fails.
  Future<MediaSaveResult> replaceOriginal({
    required String originalAssetId,
    required String compressedPath,
    required String title,
  });

  /// Verifies that a saved asset physically exists and has valid non-zero size.
  Future<bool> verifySavedAsset(String assetId);
}

/// Production implementation of [MediaSaveService] utilizing PhotoManager and atomic file checks.
class PhotoManagerMediaSaveService implements MediaSaveService {
  final AnalyticsService _analytics;

  PhotoManagerMediaSaveService({AnalyticsService? analytics})
      : _analytics = analytics ?? LocalPrivacyAnalyticsService();

  @override
  Future<MediaSaveResult> saveAsCopy({
    required String compressedPath,
    required String title,
  }) async {
    try {
      AppLogger.info('Initiating save as copy: path=$compressedPath, title=$title');

      // 1. Physical file validation
      final file = File(compressedPath);
      if (!await file.exists()) {
        AppLogger.error('Cannot save: compressed file does not exist at $compressedPath');
        return const MediaSaveResult(
          outcome: SaveOutcome.failed,
          errorMessage: 'Compressed file not found on disk.',
        );
      }

      final fileLength = await file.length();
      if (fileLength <= 0) {
        AppLogger.error('Cannot save: compressed file is 0 bytes');
        return const MediaSaveResult(
          outcome: SaveOutcome.failed,
          errorMessage: 'Compressed file is empty.',
        );
      }

      // 2. Check PhotoManager permissions
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.hasAccess) {
        AppLogger.warn('Cannot save: Media access permission denied');
        return const MediaSaveResult(
          outcome: SaveOutcome.permissionDenied,
          errorMessage: 'Gallery write permission denied.',
        );
      }

      // 3. Save to native gallery (MediaStore on Android, PhotoKit on iOS)
      final cleanTitle = title.endsWith('.mp4') ? title : '$title.mp4';
      final AssetEntity savedEntity = await PhotoManager.editor.saveVideo(
        file,
        title: cleanTitle,
      );

      // 4. Verification of saved asset
      final isVerified = await verifySavedAsset(savedEntity.id);
      if (!isVerified) {
        AppLogger.warn('Asset saved but post-save verification failed for ${savedEntity.id}');
      }

      _analytics.track('video_saved_to_gallery', {
        'action': 'save_as_copy',
        'asset_id': savedEntity.id,
        'bytes': fileLength,
      });

      AppLogger.info('Successfully saved copy to gallery: assetId=${savedEntity.id}');
      return MediaSaveResult(
        outcome: SaveOutcome.success,
        savedAssetId: savedEntity.id,
      );
    } catch (e, stack) {
      AppLogger.error('Exception during saveAsCopy: $e', e, stack);
      return MediaSaveResult(
        outcome: SaveOutcome.failed,
        errorMessage: e.toString(),
      );
    }
  }

  @override
  Future<MediaSaveResult> replaceOriginal({
    required String originalAssetId,
    required String compressedPath,
    required String title,
  }) async {
    try {
      AppLogger.info('Initiating atomic replace: origId=$originalAssetId, path=$compressedPath');

      // Step 1: Pre-validation of compressed file
      final file = File(compressedPath);
      if (!await file.exists() || await file.length() <= 0) {
        AppLogger.error('Atomic replace aborted: compressed file invalid or empty');
        return const MediaSaveResult(
          outcome: SaveOutcome.failed,
          errorMessage: 'Compressed file is missing or empty. Original file preserved.',
        );
      }

      // Step 2: Save compressed copy into gallery first
      final saveResult = await saveAsCopy(
        compressedPath: compressedPath,
        title: title,
      );

      if (!saveResult.isSuccess || saveResult.savedAssetId == null) {
        AppLogger.error('Atomic replace aborted: Failed to save compressed copy. Original preserved.');
        return MediaSaveResult(
          outcome: saveResult.outcome,
          errorMessage: saveResult.errorMessage ?? 'Failed to save compressed copy. Original preserved.',
        );
      }

      // Step 3: Verify the newly saved copy is valid and readable in the gallery
      final newAssetId = saveResult.savedAssetId!;
      final verified = await verifySavedAsset(newAssetId);
      if (!verified) {
        AppLogger.error('Atomic replace aborted: Saved asset failed verification. Original preserved.');
        return const MediaSaveResult(
          outcome: SaveOutcome.failed,
          errorMessage: 'Saved video failed integrity check. Original preserved.',
        );
      }

      // Step 4: ONLY NOW delete the bloated original asset
      bool originalDeleted = false;
      try {
        AppLogger.info('Deleting original asset $originalAssetId from gallery...');
        final deletedIds = await PhotoManager.editor.deleteWithIds([originalAssetId]);
        originalDeleted = deletedIds.contains(originalAssetId);
        AppLogger.info('Deletion result for $originalAssetId: $originalDeleted (deletedIds: $deletedIds)');
      } catch (e, stack) {
        AppLogger.warning('Exception while deleting original asset $originalAssetId: $e', e, stack);
        // Note: New copy is preserved, original may still exist (e.g. user denied delete dialog on Android 11+ or iOS)
      }

      _analytics.track('video_saved_to_gallery', {
        'action': 'replace_original',
        'new_asset_id': newAssetId,
        'original_asset_id': originalAssetId,
        'original_deleted': originalDeleted,
      });

      return MediaSaveResult(
        outcome: SaveOutcome.success,
        savedAssetId: newAssetId,
        originalDeleted: originalDeleted,
      );
    } catch (e, stack) {
      AppLogger.error('Exception during replaceOriginal: $e', e, stack);
      return MediaSaveResult(
        outcome: SaveOutcome.failed,
        errorMessage: 'Replace failed: $e. Original file preserved.',
      );
    }
  }

  @override
  Future<bool> verifySavedAsset(String assetId) async {
    try {
      final entity = await AssetEntity.fromId(assetId);
      if (entity == null) {
        AppLogger.warn('Verification: AssetEntity.fromId returned null for $assetId');
        return false;
      }

      final file = await entity.file;
      if (file == null || !await file.exists()) {
        AppLogger.warn('Verification: Entity physical file does not exist for $assetId');
        return false;
      }

      final length = await file.length();
      AppLogger.info('Verified saved asset $assetId: exists=true, bytes=$length');
      return length > 0;
    } catch (e) {
      AppLogger.warn('Verification error for asset $assetId: $e');
      return false;
    }
  }
}

/// Global Riverpod provider for MediaSaveService.
final mediaSaveServiceProvider = Provider<MediaSaveService>((ref) {
  return PhotoManagerMediaSaveService();
});
