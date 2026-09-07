import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/temp_file_manager.dart';
import '../../../../services/analytics/analytics_service.dart';
import '../../../../services/media/video_compression_service.dart';
import '../../../../services/storage/storage_check_service.dart';
import '../../domain/models/compression_preset.dart';
import '../../domain/models/compression_request.dart';
import '../../domain/models/compression_result.dart';
import '../../domain/models/video_asset.dart';
import '../../domain/repositories/compression_repository.dart';
import '../../domain/repositories/media_repository.dart';
import '../../domain/strategies/compression_strategy.dart';
import 'media_repository_impl.dart';

/// Production implementation of CompressionRepository orchestrating native encoding.
class CompressionRepositoryImpl implements CompressionRepository {
  final VideoCompressionService _compressionService;
  final StorageCheckService _storageService;
  final MediaRepository _mediaRepository;
  final TempFileManager _tempFileManager;
  final AnalyticsService _analytics;

  CompressionRepositoryImpl({
    required VideoCompressionService compressionService,
    required StorageCheckService storageService,
    required MediaRepository mediaRepository,
    required TempFileManager tempFileManager,
    required AnalyticsService analytics,
  })  : _compressionService = compressionService,
        _storageService = storageService,
        _mediaRepository = mediaRepository,
        _tempFileManager = tempFileManager,
        _analytics = analytics;

  @override
  Stream<CompressionProgress> get progressStream => _compressionService.progressStream;

  @override
  Future<CompressionResult> compressVideo({
    required VideoAsset video,
    required CompressionPreset preset,
    int? customTargetSizeBytes,
  }) async {
    final jobId = 'job_${DateTime.now().millisecondsSinceEpoch}_${video.id}';
    String? tempOutputPath;

    try {
      // 1. Resolve source filesystem path
      String? inputPath = video.path;
      if (inputPath.isEmpty || !await File(inputPath).exists()) {
        inputPath = await _mediaRepository.getOriginFilePath(video.id);
      }

      if (inputPath == null || !await File(inputPath).exists()) {
        AppLogger.error('Source video not found: assetId=, path=');
        return CompressionResult.failure(
          errorCode: 'SOURCE_NOT_FOUND',
          errorMessage: 'Original video file could not be located on device.',
        );
      }

      // 2. Resolve compression strategy & parameters
      final isHevcSupported = await _compressionService.isHevcSupported();
      final strategy = StrategyResolver.getStrategy(preset);
      final config = strategy.resolveConfig(
        video,
        customTargetSizeBytes: customTargetSizeBytes,
        isHevcSupported: isHevcSupported,
      );

      // 3. Storage Safety Check
      final estimatedBytes = config.customTargetSizeBytes ?? (video.fileSizeBytes ~/ 2);
      final hasSpace = await _storageService.hasEnoughStorageForCompression(
        estimatedOutputBytes: estimatedBytes,
      );

      if (!hasSpace) {
        return CompressionResult.failure(
          errorCode: 'INSUFFICIENT_STORAGE',
          errorMessage: 'Device storage is insufficient to store the compressed video safely.',
          originalPath: inputPath,
        );
      }

      // 4. Create Tracked Temporary Output File
      tempOutputPath = await _tempFileManager.createTempVideoPath();

      // 5. Build native request
      final request = CompressionRequest(
        jobId: jobId,
        assetId: video.id,
        inputPath: inputPath,
        outputPath: tempOutputPath,
        preset: preset,
        targetResolutionWidth: config.targetResolutionWidth,
        targetResolutionHeight: config.targetResolutionHeight,
        targetBitrateBps: config.targetBitrateBps,
        useHevc: config.useHevc,
        targetSizeBytes: config.customTargetSizeBytes,
      );

      _analytics.track('video_compress_started', {
        'preset': preset.name,
        'source_size': video.fileSizeBytes,
        'target_bitrate': config.targetBitrateBps,
        'use_hevc': config.useHevc,
      });

      // 6. Execute Native Hardware Compression
      final result = await _compressionService.compressVideo(request);

      if (!result.success) {
        if (result.errorCode != 'CANCELLED') {
          await _tempFileManager.deleteTempFile(tempOutputPath);
        }
        _analytics.track('video_compress_failed', {
          'preset': preset.name,
          'error': result.errorCode,
        });
        return result;
      }

      // 7. Output Validation (Integrity, size > 0, existence)
      final isValid = await validateOutput(tempOutputPath, video.fileSizeBytes);
      if (!isValid) {
        await _tempFileManager.deleteTempFile(tempOutputPath);
        return CompressionResult.failure(
          errorCode: 'OUTPUT_VALIDATION_FAILED',
          errorMessage: 'Compressed output file was empty or corrupted.',
          originalPath: inputPath,
        );
      }

      _analytics.track('video_compress_success', {
        'preset': preset.name,
        'original_size': video.fileSizeBytes,
        'compressed_size': result.compressedSizeBytes,
        'saved_percentage': result.savedPercentage,
      });

      return result;
    } catch (e, stack) {
      AppLogger.error('Exception during compression repository flow', e, stack);
      if (tempOutputPath != null) {
        await _tempFileManager.deleteTempFile(tempOutputPath);
      }
      return CompressionResult.failure(
        errorCode: 'COMPRESSION_FAILED',
        errorMessage: e.toString(),
      );
    }
  }

  @override
  Future<bool> cancelCompression(String jobId) async {
    try {
      AppLogger.info('CompressionRepository: cancelling job $jobId');
      final cancelled = await _compressionService.cancelCompression(jobId);
      await _tempFileManager.cleanupTrackedFiles();
      _analytics.track('video_compress_cancelled', {'jobId': jobId});
      return cancelled;
    } catch (e, stack) {
      AppLogger.error('Error during cancellation flow', e, stack);
      return false;
    }
  }

  @override
  Future<bool> validateOutput(String outputPath, int originalSizeBytes) async {
    try {
      final file = File(outputPath);
      if (!await file.exists()) {
        AppLogger.warn('Validation failed: output file does not exist: ');
        return false;
      }

      final length = await file.length();
      if (length <= 0) {
        AppLogger.warn('Validation failed: output file has 0 bytes');
        return false;
      }

      // Output should be a valid MP4 header (starts with ftyp)
      final raf = await file.open();
      final header = await raf.read(12);
      await raf.close();

      if (header.length < 8) return false;
      // Byte 4..7 in MP4 is 'ftyp'
      final isFtyp = header[4] == 0x66 && header[5] == 0x74 && header[6] == 0x79 && header[7] == 0x70;
      if (!isFtyp) {
        AppLogger.warn('Validation warning: output container does not start with ftyp, size: ');
      }

      return length > 0;
    } catch (e) {
      AppLogger.error('Error validating output file: ');
      return false;
    }
  }
}

/// Global provider for CompressionRepository
final compressionRepositoryProvider = Provider<CompressionRepository>((ref) {
  return CompressionRepositoryImpl(
    compressionService: ref.watch(videoCompressionServiceProvider),
    storageService: ref.watch(storageCheckServiceProvider),
    mediaRepository: ref.watch(mediaRepositoryProvider),
    tempFileManager: TempFileManager(),
    analytics: ref.watch(analyticsServiceProvider),
  );
});
