import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'logger.dart';

/// Zero-Temp-Leak Temporary File Management Service.
/// Fulfills PRD Section 5.3:
/// - Temp video outputs saved in NSTemporaryDirectory() (iOS) or cacheDir (Android).
/// - Automatic cleanup on export success, user abort/cancellation, and app launch.
class TempFileManager {
  static final TempFileManager _instance = TempFileManager._internal();
  factory TempFileManager() => _instance;
  TempFileManager._internal();

  final Set<String> _activeTempFiles = {};

  /// Generates a unique temporary file path for a compression operation.
  Future<String> createTempVideoPath({String extension = 'mp4'}) async {
    final tempDir = await getTemporaryDirectory();
    final fileName = 'compressed_${DateTime.now().millisecondsSinceEpoch}_${_activeTempFiles.length}.$extension';
    final filePath = p.join(tempDir.path, fileName);
    _activeTempFiles.add(filePath);
    AppLogger.info('Created tracked temp path: $filePath');
    return filePath;
  }

  /// Deletes a specific temporary file immediately.
  Future<bool> deleteTempFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        AppLogger.info('Deleted temp file: $filePath');
      }
      _activeTempFiles.remove(filePath);
      return true;
    } catch (e, stack) {
      AppLogger.error('Failed to delete temp file: $filePath', e, stack);
      return false;
    }
  }

  /// Cleans up all tracked active temporary files (e.g. on cancel or export completion).
  Future<void> cleanupTrackedFiles() async {
    final pathsToDelete = List<String>.from(_activeTempFiles);
    for (final path in pathsToDelete) {
      await deleteTempFile(path);
    }
    _activeTempFiles.clear();
  }

  /// Complete sweep of all stale compression temp files in the cache directory.
  /// Fulfills PRD: Called on App Launch to prevent zombie storage bloating.
  Future<int> cleanupAllStaleTempFiles() async {
    var deletedCount = 0;
    try {
      final tempDir = await getTemporaryDirectory();
      if (!await tempDir.exists()) return 0;

      final entities = tempDir.listSync(followLinks: false);
      for (final entity in entities) {
        if (entity is File) {
          final fileName = p.basename(entity.path);
          // Target files created by the compression or video export engine
          if (fileName.startsWith('compressed_') ||
              fileName.endsWith('.tmp') ||
              fileName.contains('video_export_')) {
            try {
              entity.deleteSync();
              deletedCount++;
              _activeTempFiles.remove(entity.path);
            } catch (e) {
              AppLogger.warn('Could not delete stale temp file: ${entity.path}');
            }
          }
        }
      }
      AppLogger.info('Stale temp sweep completed. Deleted $deletedCount files.');
    } catch (e, stack) {
      AppLogger.error('Error during stale temp sweep', e, stack);
    }
    return deletedCount;
  }

  /// Returns current number of actively tracked files.
  int get trackedCount => _activeTempFiles.length;
}
