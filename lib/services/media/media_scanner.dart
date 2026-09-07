import 'dart:async';
import 'package:photo_manager/photo_manager.dart';
import '../../core/utils/logger.dart';
import '../../features/onboarding/domain/models/scan_models.dart';

export '../../features/onboarding/domain/models/scan_models.dart';

/// Service abstraction for scanning on-device media without external cloud dependencies.
abstract class MediaScanner {
  Stream<ScanProgressUpdate> scanLibrary({ScanCancellationToken? cancellationToken});
}

/// Native PhotoManager implementation executing genuine on-device media inspection.
class LocalMediaScanner implements MediaScanner {
  @override
  Stream<ScanProgressUpdate> scanLibrary({ScanCancellationToken? cancellationToken}) async* {
    AppLogger.info('Starting local on-device media scan...');
    final token = cancellationToken ?? ScanCancellationToken();

    var videoCount = 0;
    var screenshotCount = 0;
    var totalBytes = 0;
    var recoverableBytes = 0;

    // Stage 1: Initializing
    yield ScanProgressUpdate(
      progress: 0.1,
      currentTaskKey: 'scanningLibrary',
      partialResult: const ScanResultData(),
    );

    if (token.isCancelled) return;

    try {
      // Stage 2: Querying videos locally
      yield ScanProgressUpdate(
        progress: 0.25,
        currentTaskKey: 'taskVideos',
        partialResult: ScanResultData(videoCount: videoCount),
      );

      final videoAlbums = await PhotoManager.getAssetPathList(type: RequestType.video);
      if (token.isCancelled) return;

      for (final album in videoAlbums) {
        if (token.isCancelled) return;
        final count = await album.assetCountAsync;
        videoCount += count;

        // Sample up to 20 recent videos to estimate average file size without whole-library memory spikes
        final sampleVideos = await album.getAssetListRange(start: 0, end: count.clamp(0, 20));
        for (final asset in sampleVideos) {
          if (token.isCancelled) return;
          try {
            final file = await asset.file;
            if (file != null && await file.exists()) {
              final size = await file.length();
              totalBytes += size;
              // Videos can typically be reduced by ~65% using modern target bitrate compression
              recoverableBytes += (size * 0.65).round();
            }
          } catch (_) {
            // Safe fallback if asset file is not physically present on device
          }
        }
      }

      yield ScanProgressUpdate(
        progress: 0.65,
        currentTaskKey: 'taskScreenshots',
        partialResult: ScanResultData(
          videoCount: videoCount,
          totalScannedBytes: totalBytes,
          estimatedRecoverableBytes: recoverableBytes,
        ),
      );

      if (token.isCancelled) return;

      // Stage 3: Querying screenshots locally
      final imageAlbums = await PhotoManager.getAssetPathList(type: RequestType.image);
      for (final album in imageAlbums) {
        if (token.isCancelled) return;
        final name = album.name.toLowerCase();
        if (name.contains('screenshot') || name.contains('لقطات الشاشة')) {
          final count = await album.assetCountAsync;
          screenshotCount += count;

          final sampleScreenshots = await album.getAssetListRange(start: 0, end: count.clamp(0, 30));
          for (final asset in sampleScreenshots) {
            if (token.isCancelled) return;
            try {
              final file = await asset.file;
              if (file != null && await file.exists()) {
                final size = await file.length();
                totalBytes += size;
                // Unreviewed screenshots marked for deletion can be 100% recovered
                recoverableBytes += size;
              }
            } catch (_) {}
          }
        }
      }

      // Stage 4: Calculating final recoverable space
      yield ScanProgressUpdate(
        progress: 0.9,
        currentTaskKey: 'taskCalculating',
        partialResult: ScanResultData(
          videoCount: videoCount,
          screenshotCount: screenshotCount,
          totalScannedBytes: totalBytes,
          estimatedRecoverableBytes: recoverableBytes,
        ),
      );

      // Final complete state
      yield ScanProgressUpdate(
        progress: 1.0,
        currentTaskKey: 'scanResultHeader',
        partialResult: ScanResultData(
          videoCount: videoCount,
          screenshotCount: screenshotCount,
          totalScannedBytes: totalBytes,
          estimatedRecoverableBytes: recoverableBytes,
          isCompleted: true,
        ),
      );

      AppLogger.info(
        'Media scan finished. Videos: $videoCount, Screenshots: $screenshotCount, Recoverable: $recoverableBytes bytes',
      );
    } catch (e, stack) {
      AppLogger.error('Media scan encountered error', e, stack);
      // Emit completed with whatever was safely gathered
      yield ScanProgressUpdate(
        progress: 1.0,
        currentTaskKey: 'scanResultHeader',
        partialResult: ScanResultData(
          videoCount: videoCount,
          screenshotCount: screenshotCount,
          totalScannedBytes: totalBytes,
          estimatedRecoverableBytes: recoverableBytes,
          isCompleted: true,
        ),
      );
    }
  }
}
