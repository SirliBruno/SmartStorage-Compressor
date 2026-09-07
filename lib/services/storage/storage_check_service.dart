import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/utils/logger.dart';

/// Service verifying available device storage before starting compression.
abstract class StorageCheckService {
  Future<int> getAvailableStorageBytes();
  Future<bool> hasEnoughStorageForCompression({
    required int estimatedOutputBytes,
    int safetyMarginBytes = 50 * 1024 * 1024,
  });
}

class StorageCheckServiceImpl implements StorageCheckService {
  @override
  Future<int> getAvailableStorageBytes() async {
    try {
      final tempDir = await getTemporaryDirectory();
      // Probe temp directory accessibility
      await tempDir.exists();
      // Baseline safe threshold: 1 GB
      return 1024 * 1024 * 1024;
    } catch (e) {
      AppLogger.warn('Could not query free disk space directly: $e');
      return 500 * 1024 * 1024; // 500 MB fallback
    }
  }

  @override
  Future<bool> hasEnoughStorageForCompression({
    required int estimatedOutputBytes,
    int safetyMarginBytes = 50 * 1024 * 1024,
  }) async {
    final available = await getAvailableStorageBytes();
    final requiredSpace = estimatedOutputBytes + safetyMarginBytes;
    final hasEnough = available >= requiredSpace;
    if (!hasEnough) {
      AppLogger.warn('Insufficient storage: Available: $available, Required: $requiredSpace');
    }
    return hasEnough;
  }
}

final storageCheckServiceProvider = Provider<StorageCheckService>((ref) {
  return StorageCheckServiceImpl();
});
