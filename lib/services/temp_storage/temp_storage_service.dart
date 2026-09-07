import '../../core/utils/temp_file_manager.dart';

/// Service contract managing temporary video files.
abstract class TempStorageService {
  Future<String> createTempVideoPath({String extension = 'mp4'});
  Future<bool> deleteTempFile(String filePath);
  Future<void> cleanupTrackedFiles();
  Future<int> cleanupAllStaleTempFiles();
}

/// Default implementation delegating to singleton TempFileManager.
class TempStorageServiceImpl implements TempStorageService {
  final TempFileManager _manager = TempFileManager();

  @override
  Future<String> createTempVideoPath({String extension = 'mp4'}) =>
      _manager.createTempVideoPath(extension: extension);

  @override
  Future<bool> deleteTempFile(String filePath) => _manager.deleteTempFile(filePath);

  @override
  Future<void> cleanupTrackedFiles() => _manager.cleanupTrackedFiles();

  @override
  Future<int> cleanupAllStaleTempFiles() => _manager.cleanupAllStaleTempFiles();
}
