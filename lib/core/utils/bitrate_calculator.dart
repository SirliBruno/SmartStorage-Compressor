import '../constants/app_constants.dart';

/// Pure mathematical calculation engine for dynamic video compression bitrates.
/// Implements the exact formula from PRD Section 1.2:
/// Bitrate (bps) = (Target Size (bits) / Duration (seconds)) - Audio Bitrate (128 kbps)
abstract class BitrateCalculator {
  /// Computes target video bitrate in bits per second (bps) for a given target file size and duration.
  ///
  /// [targetSizeBytes]: Target output size in bytes (e.g., 16 * 1024 * 1024 for 16 MB).
  /// [duration]: Video duration.
  /// [audioBitrateBps]: Audio track bitrate, defaults to 128 kbps (128,000 bps).
  /// [originalBitrateBps]: Optional original bitrate to prevent inflating bitrate.
  static int calculateTargetVideoBitrate({
    required int targetSizeBytes,
    required Duration duration,
    int audioBitrateBps = AppConstants.defaultAudioBitrateBps,
    int? originalBitrateBps,
  }) {
    final durationSeconds = duration.inMilliseconds / 1000.0;
    if (durationSeconds <= 0.0) {
      return AppConstants.minVideoBitrateBps;
    }

    // Convert target size from bytes to bits
    final targetBits = targetSizeBytes * 8.0;

    // Total bits per second = targetBits / durationSeconds
    final totalBitrateBps = (targetBits / durationSeconds).round();

    // Subtract audio bitrate
    final calculatedVideoBitrateBps = totalBitrateBps - audioBitrateBps;

    // Clamp between minimum floor (250 kbps) and optional original bitrate
    var finalBitrate = calculatedVideoBitrateBps < AppConstants.minVideoBitrateBps
        ? AppConstants.minVideoBitrateBps
        : calculatedVideoBitrateBps;

    if (originalBitrateBps != null && originalBitrateBps > 0 && finalBitrate > originalBitrateBps) {
      finalBitrate = originalBitrateBps;
    }

    return finalBitrate;
  }

  /// Calculates estimated output size in bytes from video bitrate, audio bitrate, and duration.
  static int estimateOutputSizeBytes({
    required int videoBitrateBps,
    required Duration duration,
    int audioBitrateBps = AppConstants.defaultAudioBitrateBps,
  }) {
    final durationSeconds = duration.inMilliseconds / 1000.0;
    if (durationSeconds <= 0.0) return 0;

    final totalBitrateBps = videoBitrateBps + audioBitrateBps;
    final totalBits = totalBitrateBps * durationSeconds;
    return (totalBits / 8.0).round();
  }

  /// Recommends target resolution based on preset and duration to preserve visual quality.
  /// E.g., for Email Ready (24.5 MB): if duration > 3 minutes, downscale to 540p; otherwise 720p.
  static ({int width, int height}) recommendEmailResolution(Duration duration) {
    if (duration.inMinutes >= 3) {
      return (width: 960, height: 540); // 540p
    }
    return (width: 1280, height: 720);   // 720p
  }
}
