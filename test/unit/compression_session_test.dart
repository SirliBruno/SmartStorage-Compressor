import 'package:flutter_test/flutter_test.dart';
import 'package:smart_storage_compressor/features/video_compressor/domain/models/compression_result.dart';
import 'package:smart_storage_compressor/features/video_compressor/domain/models/compression_session.dart';
import 'package:smart_storage_compressor/features/video_compressor/domain/models/video_asset.dart';

void main() {
  group('CompressionSession Domain Tests (PRD Section 5.3 & Sprint 05)', () {
    late VideoAsset sampleAsset;
    late CompressionResult sampleResult;

    setUp(() {
      sampleAsset = VideoAsset(
        id: 'asset_123',
        localIdentifier: 'asset_123',
        path: '/storage/emulated/0/DCIM/Camera/VID_2026.mp4',
        title: 'VID_2026',
        fileSizeBytes: 185 * 1024 * 1024, // 185 MB
        duration: const Duration(seconds: 45),
        width: 1920,
        height: 1080,
        fps: 30.0,
        codec: 'H.264',
        isAccessible: true,
        mimeType: 'video/mp4',
        creationDate: DateTime(2026, 1, 1),
      );

      sampleResult = CompressionResult.successResult(
        originalPath: sampleAsset.path,
        outputPath: '/data/user/0/cache/compressed_123.mp4',
        originalSize: 185 * 1024 * 1024,
        compressedSize: 32 * 1024 * 1024, // 32 MB
        duration: const Duration(seconds: 45),
        processingTime: const Duration(seconds: 8),
        targetResolutionWidth: 1280,
        targetResolutionHeight: 720,
        targetCodec: 'H.264 (AVC)',
      );
    });

    test('CompressionSession.fromResult instantiates correctly with zero fake data', () {
      final session = CompressionSession.fromResult(
        originalAsset: sampleAsset,
        result: sampleResult,
      );

      expect(session.originalAsset.id, 'asset_123');
      expect(session.compressedPath, '/data/user/0/cache/compressed_123.mp4');
      expect(session.status, CompressionSessionStatus.comparing);
      expect(session.originalSizeBytes, 185 * 1024 * 1024);
      expect(session.compressedSizeBytes, 32 * 1024 * 1024);
      expect(session.savedBytes, (185 - 32) * 1024 * 1024);
      expect(session.savedPercentage, closeTo(82.7, 0.1));
      expect(session.originalResolution, '1920x1080');
      expect(session.originalCodec, 'H.264');
      expect(session.isProcessingSave, isFalse);
      expect(session.isFinalized, isFalse);
    });

    test('CompressionSession status flags reflect lifecycle states', () {
      var session = CompressionSession.fromResult(
        originalAsset: sampleAsset,
        result: sampleResult,
      );

      expect(session.isProcessingSave, isFalse);
      expect(session.isFinalized, isFalse);

      session = session.copyWith(status: CompressionSessionStatus.saving);
      expect(session.isProcessingSave, isTrue);
      expect(session.isFinalized, isFalse);

      session = session.copyWith(status: CompressionSessionStatus.saved);
      expect(session.isProcessingSave, isFalse);
      expect(session.isFinalized, isTrue);

      session = session.copyWith(status: CompressionSessionStatus.replacing);
      expect(session.isProcessingSave, isTrue);
      expect(session.isFinalized, isFalse);

      session = session.copyWith(status: CompressionSessionStatus.replaced);
      expect(session.isProcessingSave, isFalse);
      expect(session.isFinalized, isTrue);
    });

    test('Zero savings or negative edge case handled safely', () {
      final bloatedResult = CompressionResult.successResult(
        originalPath: sampleAsset.path,
        outputPath: '/data/user/0/cache/compressed_bloated.mp4',
        originalSize: 50 * 1024 * 1024,
        compressedSize: 60 * 1024 * 1024, // Bloated
        duration: const Duration(seconds: 10),
        processingTime: const Duration(seconds: 2),
      );

      final session = CompressionSession.fromResult(
        originalAsset: sampleAsset,
        result: bloatedResult,
      );

      expect(session.savedBytes, 0);
      expect(session.savedPercentage, 0.0);
    });
  });
}
