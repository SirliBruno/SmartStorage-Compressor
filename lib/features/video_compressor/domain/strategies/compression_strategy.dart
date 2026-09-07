import 'dart:math';
import '../models/compression_preset.dart';
import '../models/video_asset.dart';

/// Base strategy resolving encoding parameters (resolution, bitrate, codec) from video inspection.
abstract class CompressionStrategy {
  CompressionConfig resolveConfig(VideoAsset video, {int? customTargetSizeBytes, bool isHevcSupported = true});
}

/// Helper utility for orientation-aware dimensions and dynamic bitrate calculations.
class CompressionMath {
  /// Computes safe target dimensions maintaining aspect ratio and portrait/landscape orientation.
  static (int width, int height) getTargetDimensions({
    required int sourceWidth,
    required int sourceHeight,
    required int targetShortEdge,
  }) {
    if (sourceWidth <= 0 || sourceHeight <= 0) {
      return (targetShortEdge, (targetShortEdge * 16 / 9).round());
    }

    final isPortrait = sourceHeight > sourceWidth;
    final shortEdge = min(sourceWidth, sourceHeight);
    final longEdge = max(sourceWidth, sourceHeight);

    // If source is already smaller than target short edge, do not upscale!
    final effectiveShortEdge = min(shortEdge, targetShortEdge);
    final aspectRatio = longEdge / shortEdge;
    var effectiveLongEdge = (effectiveShortEdge * aspectRatio).round();

    // Ensure even dimensions required by H.264/HEVC hardware encoders
    effectiveLongEdge = (effectiveLongEdge ~/ 2) * 2;
    final finalShort = (effectiveShortEdge ~/ 2) * 2;

    return isPortrait ? (finalShort, effectiveLongEdge) : (effectiveLongEdge, finalShort);
  }

  /// Calculates dynamic video bitrate in bits-per-second:
  /// videoBitrate = (targetBits / durationSec) - audioBitrate - containerOverhead
  static int calculateDynamicBitrate({
    required Duration duration,
    required int targetBytes,
    int audioBitrateBps = 128000,
    double containerOverheadRatio = 0.02,
    int minVideoBitrateBps = 350000,
    int maxVideoBitrateBps = 12000000,
  }) {
    final seconds = max(1, duration.inSeconds);
    final totalBits = targetBytes * 8.0;
    final overheadBits = totalBits * containerOverheadRatio;
    final availableBits = totalBits - overheadBits;
    final totalBitrate = (availableBits / seconds).round();
    final videoBitrate = totalBitrate - audioBitrateBps;

    return videoBitrate.clamp(minVideoBitrateBps, maxVideoBitrateBps);
  }
}

/// Strategy for WhatsApp Fast: 720p, dynamic bitrate targeting 16MB or 64MB ceiling.
class WhatsAppStrategy implements CompressionStrategy {
  final int targetBytes;

  const WhatsAppStrategy({this.targetBytes = 16 * 1024 * 1024});

  @override
  CompressionConfig resolveConfig(VideoAsset video, {int? customTargetSizeBytes, bool isHevcSupported = true}) {
    final defaultCeiling = video.fileSizeBytes > 100 * 1024 * 1024
        ? 64 * 1024 * 1024
        : 16 * 1024 * 1024;
    final effectiveTarget = customTargetSizeBytes ??
        (targetBytes != 16 * 1024 * 1024 ? targetBytes : defaultCeiling);

    final (width, height) = CompressionMath.getTargetDimensions(
      sourceWidth: video.resolutionWidth,
      sourceHeight: video.resolutionHeight,
      targetShortEdge: 720,
    );

    final bitrate = CompressionMath.calculateDynamicBitrate(
      duration: video.duration,
      targetBytes: effectiveTarget,
      minVideoBitrateBps: 350000,
      maxVideoBitrateBps: 6000000,
    );

    return CompressionConfig(
      presetType: CompressionPreset.whatsappFast,
      targetResolutionWidth: width,
      targetResolutionHeight: height,
      targetBitrateBps: bitrate,
      useHevc: false, // H.264 for universal WhatsApp compatibility
      customTargetSizeBytes: effectiveTarget,
      isProOnly: false,
    );
  }
}

/// Strategy for Email Ready: 24.5MB ceiling.
/// Automatically drops to 540p for videos > 3 minutes to avoid macroblocking.
class EmailStrategy implements CompressionStrategy {
  static const int emailCeilingBytes = 25690112; // 24.5 MB

  const EmailStrategy();

  @override
  CompressionConfig resolveConfig(VideoAsset video, {int? customTargetSizeBytes, bool isHevcSupported = true}) {
    // If video is longer than 3 minutes, 540p yields significantly better visual quality
    final targetShort = video.duration.inSeconds > 180 ? 540 : 720;
    final (width, height) = CompressionMath.getTargetDimensions(
      sourceWidth: video.resolutionWidth,
      sourceHeight: video.resolutionHeight,
      targetShortEdge: targetShort,
    );

    final bitrate = CompressionMath.calculateDynamicBitrate(
      duration: video.duration,
      targetBytes: emailCeilingBytes,
      minVideoBitrateBps: 300000,
      maxVideoBitrateBps: 5000000,
    );

    return CompressionConfig(
      presetType: CompressionPreset.emailReady,
      targetResolutionWidth: width,
      targetResolutionHeight: height,
      targetBitrateBps: bitrate,
      useHevc: false, // H.264 for email client compatibility
      customTargetSizeBytes: emailCeilingBytes,
      isProOnly: false,
    );
  }
}

/// Strategy for Maximum Space Saver: 60–80% size reduction using HEVC / H.265 (with H.264 fallback).
class MaximumSpaceSaverStrategy implements CompressionStrategy {
  const MaximumSpaceSaverStrategy();

  @override
  CompressionConfig resolveConfig(VideoAsset video, {int? customTargetSizeBytes, bool isHevcSupported = true}) {
    // Target 1080p or preserve smaller source
    final (width, height) = CompressionMath.getTargetDimensions(
      sourceWidth: video.resolutionWidth,
      sourceHeight: video.resolutionHeight,
      targetShortEdge: 1080,
    );

    // Target ~30% of original file size (70% reduction)
    final targetBytes = (video.sizeInBytes * 0.30).round();
    final bitrate = CompressionMath.calculateDynamicBitrate(
      duration: video.duration,
      targetBytes: targetBytes,
      minVideoBitrateBps: 400000,
      maxVideoBitrateBps: 8000000,
    );

    return CompressionConfig(
      presetType: CompressionPreset.maximumSpaceSaver,
      targetResolutionWidth: width,
      targetResolutionHeight: height,
      targetBitrateBps: bitrate,
      useHevc: isHevcSupported, // HEVC when supported, H.264 safe fallback
      customTargetSizeBytes: targetBytes,
      isProOnly: true,
    );
  }
}

/// Strategy for Custom Target Size: Computes bitrate from user-defined MB target.
class CustomTargetStrategy implements CompressionStrategy {
  const CustomTargetStrategy();

  @override
  CompressionConfig resolveConfig(VideoAsset video, {int? customTargetSizeBytes, bool isHevcSupported = true}) {
    final targetBytes = customTargetSizeBytes ?? (video.sizeInBytes ~/ 2);
    
    // Scale resolution dynamically based on target density
    final seconds = max(1, video.duration.inSeconds);
    final approxBitrate = (targetBytes * 8) ~/ seconds;
    
    int targetShort = 1080;
    if (approxBitrate < 800000) {
      targetShort = 540;
    } else if (approxBitrate < 2000000) {
      targetShort = 720;
    }

    final (width, height) = CompressionMath.getTargetDimensions(
      sourceWidth: video.resolutionWidth,
      sourceHeight: video.resolutionHeight,
      targetShortEdge: targetShort,
    );

    final bitrate = CompressionMath.calculateDynamicBitrate(
      duration: video.duration,
      targetBytes: targetBytes,
      minVideoBitrateBps: 250000,
      maxVideoBitrateBps: 15000000,
    );

    return CompressionConfig(
      presetType: CompressionPreset.customTargetSize,
      targetResolutionWidth: width,
      targetResolutionHeight: height,
      targetBitrateBps: bitrate,
      useHevc: isHevcSupported,
      customTargetSizeBytes: targetBytes,
      isProOnly: true,
    );
  }
}

/// Factory resolving appropriate strategy for any preset.
class StrategyResolver {
  static CompressionStrategy getStrategy(CompressionPreset preset) {
    switch (preset) {
      case CompressionPreset.whatsappFast:
        return const WhatsAppStrategy();
      case CompressionPreset.emailReady:
        return const EmailStrategy();
      case CompressionPreset.maximumSpaceSaver:
        return const MaximumSpaceSaverStrategy();
      case CompressionPreset.customTargetSize:
        return const CustomTargetStrategy();
    }
  }
}
