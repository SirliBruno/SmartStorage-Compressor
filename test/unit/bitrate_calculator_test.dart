import 'package:smart_storage_compressor/core/constants/app_constants.dart';
import 'package:smart_storage_compressor/core/utils/bitrate_calculator.dart';
import 'package:test/test.dart';

void main() {
  group('BitrateCalculator Tests (PRD Equation Verification)', () {
    test('Calculates correct video bitrate for 16 MB WhatsApp target over 60 seconds', () {
      const targetBytes = 16 * 1024 * 1024; // 16 MB = 16,777,216 bytes
      const duration = Duration(seconds: 60);

      // Formula: (targetBytes * 8 / 60) - 128,000
      // Bits = 134,217,728 / 60 = 2,236,962.13 bps
      // Minus 128,000 = 2,108,962 bps (~2.1 Mbps)
      final videoBitrate = BitrateCalculator.calculateTargetVideoBitrate(
        targetSizeBytes: targetBytes,
        duration: duration,
      );

      expect(videoBitrate, equals(2108962));
    });

    test('Calculates correct video bitrate for 24.5 MB Email target over 120 seconds', () {
      final targetBytes = (24.5 * 1024 * 1024).toInt(); // 25,690,112 bytes
      const duration = Duration(seconds: 120);

      final videoBitrate = BitrateCalculator.calculateTargetVideoBitrate(
        targetSizeBytes: targetBytes,
        duration: duration,
      );

      // (25,690,112 * 8 / 120) - 128,000 = 1,712,674 - 128,000 = 1,584,674 bps
      expect(videoBitrate, equals(1584674));
    });

    test('Enforces minimum floor of 250 kbps when video duration is extremely long', () {
      // 1 MB over 1 hour -> calculated bitrate would be negative or tiny without clamp
      const targetBytes = 1 * 1024 * 1024;
      const duration = Duration(hours: 1);

      final videoBitrate = BitrateCalculator.calculateTargetVideoBitrate(
        targetSizeBytes: targetBytes,
        duration: duration,
      );

      expect(videoBitrate, equals(AppConstants.minVideoBitrateBps));
      expect(videoBitrate, equals(250000));
    });

    test('Clamps to original bitrate if calculated target exceeds original', () {
      const targetBytes = 100 * 1024 * 1024; // 100 MB target
      const duration = Duration(seconds: 10);
      const originalBitrate = 5000000; // 5 Mbps original

      final videoBitrate = BitrateCalculator.calculateTargetVideoBitrate(
        targetSizeBytes: targetBytes,
        duration: duration,
        originalBitrateBps: originalBitrate,
      );

      expect(videoBitrate, equals(originalBitrate));
    });

    test('Estimates output size accurately from bitrate and duration', () {
      const videoBitrate = 2000000; // 2 Mbps
      const audioBitrate = 128000;  // 128 kbps
      const duration = Duration(seconds: 10);

      final estimatedBytes = BitrateCalculator.estimateOutputSizeBytes(
        videoBitrateBps: videoBitrate,
        duration: duration,
        audioBitrateBps: audioBitrate,
      );

      // (2,128,000 * 10) / 8 = 2,660,000 bytes
      expect(estimatedBytes, equals(2660000));
    });

    test('Recommends 540p for email videos longer than 3 minutes', () {
      final resShort = BitrateCalculator.recommendEmailResolution(const Duration(minutes: 2));
      expect(resShort.width, equals(1280));
      expect(resShort.height, equals(720));

      final resLong = BitrateCalculator.recommendEmailResolution(const Duration(minutes: 4));
      expect(resLong.width, equals(960));
      expect(resLong.height, equals(540));
    });
  });
}
