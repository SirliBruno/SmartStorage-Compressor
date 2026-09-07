import 'package:flutter_test/flutter_test.dart';
import 'package:smart_storage_compressor/features/video_compressor/domain/models/compression_preset.dart';
import 'package:smart_storage_compressor/features/video_compressor/domain/models/compression_result.dart';
import 'package:smart_storage_compressor/features/video_compressor/domain/models/compression_status.dart';
import 'package:smart_storage_compressor/features/video_compressor/domain/models/video_asset.dart';
import 'package:smart_storage_compressor/features/video_compressor/domain/strategies/compression_strategy.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Helper factory for creating test VideoAsset instances
  VideoAsset createTestVideo({
    String id = 'test-vid-1',
    int width = 1920,
    int height = 1080,
    Duration duration = const Duration(seconds: 60),
    int fileSizeBytes = 100 * 1024 * 1024, // 100 MB
    double fps = 30.0,
  }) {
    return VideoAsset(
      id: id,
      path: '/data/storage/emulated/0/DCIM/Camera/test.mp4',
      title: 'test.mp4',
      fileSizeBytes: fileSizeBytes,
      duration: duration,
      width: width,
      height: height,
      fps: fps,
      creationDate: DateTime(2026, 1, 1),
    );
  }

  group('CompressionMath Tests', () {
    test('calculateDynamicBitrate subtracts 128 kbps audio and accounts for 2% container overhead', () {
      const duration = Duration(seconds: 60);
      const targetBytes = 16 * 1024 * 1024; // 16 MB = 134,217,728 bits
      final bitrateWithOverhead = CompressionMath.calculateDynamicBitrate(
        duration: duration,
        targetBytes: targetBytes,
      );
      // With 2% safety container overhead: 2,064,223 bps
      expect(bitrateWithOverhead, equals(2064223));

      // Without container overhead (0.0): 2,108,962 bps
      final bitrateZeroOverhead = CompressionMath.calculateDynamicBitrate(
        duration: duration,
        targetBytes: targetBytes,
        containerOverheadRatio: 0.0,
      );
      expect(bitrateZeroOverhead, equals(2108962));
    });

    test('calculateDynamicBitrate clamps to minimum bitrate floor for very long videos', () {
      const duration = Duration(hours: 2);
      const targetBytes = 10 * 1024 * 1024; // 10 MB over 2 hours
      final bitrate = CompressionMath.calculateDynamicBitrate(
        duration: duration,
        targetBytes: targetBytes,
        minVideoBitrateBps: 300000,
      );

      expect(bitrate, equals(300000));
    });

    test('calculateDynamicBitrate clamps to maximum bitrate ceiling for short videos', () {
      const duration = Duration(seconds: 2);
      const targetBytes = 100 * 1024 * 1024; // 100 MB over 2 seconds
      final bitrate = CompressionMath.calculateDynamicBitrate(
        duration: duration,
        targetBytes: targetBytes,
        maxVideoBitrateBps: 15000000,
      );

      expect(bitrate, equals(15000000));
    });

    test('getTargetDimensions downscales 1080p landscape to 720p with even dimensions', () {
      final (w, h) = CompressionMath.getTargetDimensions(
        sourceWidth: 1920,
        sourceHeight: 1080,
        targetShortEdge: 720,
      );

      expect(w, equals(1280));
      expect(h, equals(720));
      expect(w % 2, equals(0));
      expect(h % 2, equals(0));
    });

    test('getTargetDimensions downscales 1080p portrait to 720p with even dimensions', () {
      final (w, h) = CompressionMath.getTargetDimensions(
        sourceWidth: 1080,
        sourceHeight: 1920,
        targetShortEdge: 720,
      );

      expect(w, equals(720));
      expect(h, equals(1280));
      expect(w % 2, equals(0));
      expect(h % 2, equals(0));
    });

    test('getTargetDimensions downscales 4K (3840x2160) to 1080p', () {
      final (w, h) = CompressionMath.getTargetDimensions(
        sourceWidth: 3840,
        sourceHeight: 2160,
        targetShortEdge: 1080,
      );

      expect(w, equals(1920));
      expect(h, equals(1080));
    });

    test('getTargetDimensions preserves lower resolution without upscaling', () {
      final (w, h) = CompressionMath.getTargetDimensions(
        sourceWidth: 640,
        sourceHeight: 360,
        targetShortEdge: 720,
      );

      expect(w, equals(640));
      expect(h, equals(360));
    });
  });

  group('WhatsAppStrategy Tests (PRD Section 5.1)', () {
    const strategy = WhatsAppStrategy();

    test('Enforces 720p max resolution and H.264 codec', () {
      final video = createTestVideo(width: 1920, height: 1080);
      final config = strategy.resolveConfig(video);

      expect(config.targetResolutionWidth, equals(1280));
      expect(config.targetResolutionHeight, equals(720));
      expect(config.useHevc, isFalse); // H.264 mandatory for WhatsApp compatibility
      expect(config.isProOnly, isFalse);
    });

    test('Targets 16MB ceiling for moderate file sizes', () {
      final video = createTestVideo(fileSizeBytes: 50 * 1024 * 1024, duration: const Duration(seconds: 60));
      final config = strategy.resolveConfig(video);

      expect(config.customTargetSizeBytes, equals(16 * 1024 * 1024));
      // Bitrate should match 16MB equation with 2% overhead: 2,064,223 bps
      expect(config.targetBitrateBps, equals(2064223));
    });

    test('Allows 64MB ceiling for very large videos exceeding 100MB', () {
      final video = createTestVideo(fileSizeBytes: 200 * 1024 * 1024, duration: const Duration(seconds: 120));
      final config = strategy.resolveConfig(video);

      expect(config.customTargetSizeBytes, equals(64 * 1024 * 1024));
    });
  });

  group('EmailStrategy Tests (PRD Section 5.1)', () {
    const strategy = EmailStrategy();

    test('Uses 720p for videos under 3 minutes with 24.5 MB ceiling', () {
      final video = createTestVideo(duration: const Duration(seconds: 120));
      final config = strategy.resolveConfig(video);

      expect(config.targetResolutionWidth, equals(1280));
      expect(config.targetResolutionHeight, equals(720));
      expect(config.customTargetSizeBytes, equals((24.5 * 1024 * 1024).toInt()));
      expect(config.useHevc, isFalse);
      expect(config.isProOnly, isFalse);
    });

    test('Scales down to 540p for videos over 3 minutes for superior visual bitrate density', () {
      final video = createTestVideo(duration: const Duration(seconds: 240));
      final config = strategy.resolveConfig(video);

      expect(config.targetResolutionWidth, equals(960));
      expect(config.targetResolutionHeight, equals(540));
      expect(config.useHevc, isFalse);
    });
  });

  group('MaximumSpaceSaverStrategy Tests (PRD Section 5.1)', () {
    const strategy = MaximumSpaceSaverStrategy();

    test('Targets ~70% reduction and uses HEVC when supported', () {
      const originalBytes = 100 * 1024 * 1024; // 100 MB
      final video = createTestVideo(fileSizeBytes: originalBytes, width: 3840, height: 2160);
      final config = strategy.resolveConfig(video, isHevcSupported: true);

      expect(config.targetResolutionWidth, equals(1920));
      expect(config.targetResolutionHeight, equals(1080));
      expect(config.useHevc, isTrue);
      expect(config.isProOnly, isTrue);
      expect(config.customTargetSizeBytes, equals((originalBytes * 0.30).round()));
    });

    test('Falls back gracefully to H.264 when HEVC is not supported by device', () {
      final video = createTestVideo();
      final config = strategy.resolveConfig(video, isHevcSupported: false);

      expect(config.useHevc, isFalse);
      expect(config.isProOnly, isTrue);
    });
  });

  group('CustomTargetStrategy Tests', () {
    const strategy = CustomTargetStrategy();

    test('Respects user-defined target bytes', () {
      final video = createTestVideo(fileSizeBytes: 200 * 1024 * 1024, duration: const Duration(seconds: 60));
      const customBytes = 30 * 1024 * 1024; // 30 MB
      final config = strategy.resolveConfig(video, customTargetSizeBytes: customBytes);

      expect(config.customTargetSizeBytes, equals(customBytes));
      expect(config.isProOnly, isTrue);
    });

    test('Defaults to 50% of original size if target bytes not specified', () {
      const originalBytes = 80 * 1024 * 1024;
      final video = createTestVideo(fileSizeBytes: originalBytes);
      final config = strategy.resolveConfig(video);

      expect(config.customTargetSizeBytes, equals(40 * 1024 * 1024));
    });
  });

  group('StrategyResolver Tests', () {
    test('Resolves correct strategy instance for each preset type', () {
      expect(StrategyResolver.getStrategy(CompressionPreset.whatsappFast), isA<WhatsAppStrategy>());
      expect(StrategyResolver.getStrategy(CompressionPreset.emailReady), isA<EmailStrategy>());
      expect(StrategyResolver.getStrategy(CompressionPreset.maximumSpaceSaver), isA<MaximumSpaceSaverStrategy>());
      expect(StrategyResolver.getStrategy(CompressionPreset.customTargetSize), isA<CustomTargetStrategy>());
    });
  });

  group('CompressionResult Tests', () {
    test('Calculates savedBytes and savedPercentage accurately', () {
      final result = CompressionResult.success(
        outputPath: '/tmp/output.mp4',
        originalBytes: 100 * 1024 * 1024,
        compressedBytes: 25 * 1024 * 1024, // 75% savings
        duration: const Duration(seconds: 15),
      );

      expect(result.isSuccess, isTrue);
      expect(result.savedBytes, equals(75 * 1024 * 1024));
      expect(result.savedPercentage, equals(75.0));
      expect(result.savedFormatted, contains('75'));
    });

    test('Handles non-saving or edge cases gracefully without negative values', () {
      final result = CompressionResult.success(
        outputPath: '/tmp/output.mp4',
        originalBytes: 10 * 1024 * 1024,
        compressedBytes: 12 * 1024 * 1024, // somehow larger
        duration: const Duration(seconds: 5),
      );

      expect(result.savedBytes, equals(0));
      expect(result.savedPercentage, equals(0.0));
    });

    test('Failure and Cancelled factories produce appropriate flags', () {
      final failed = CompressionResult.failure(error: 'Hardware encoder error');
      expect(failed.isSuccess, isFalse);
      expect(failed.errorMessage, equals('Hardware encoder error'));

      final cancelled = CompressionResult.cancelled();
      expect(cancelled.isSuccess, isFalse);
      expect(cancelled.isCancelled, isTrue);
    });
  });

  group('CompressionStatus Tests', () {
    test('isActive and isFinished return correct boolean state', () {
      expect(CompressionStatus.idle.isActive, isFalse);
      expect(CompressionStatus.preparing.isActive, isTrue);
      expect(CompressionStatus.compressing.isActive, isTrue);
      expect(CompressionStatus.completed.isActive, isFalse);
      expect(CompressionStatus.cancelled.isActive, isFalse);
      expect(CompressionStatus.failed.isActive, isFalse);

      expect(CompressionStatus.completed.isFinished, isTrue);
      expect(CompressionStatus.cancelled.isFinished, isTrue);
      expect(CompressionStatus.failed.isFinished, isTrue);
      expect(CompressionStatus.compressing.isFinished, isFalse);
    });
  });
}
