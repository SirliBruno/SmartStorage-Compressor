import 'dart:typed_data';
import '../../../../core/extensions/file_size_extensions.dart';
import '../../../../core/extensions/duration_extensions.dart';

/// Immutable domain entity representing a video file found in the media library.
class VideoAsset {
  final String id;
  final String? localIdentifier;
  final String path;
  final String title;
  final int fileSizeBytes;
  final Duration duration;
  final int width;
  final int height;
  final double fps;
  final String codec;
  final bool isAccessible;
  final String? mimeType;
  final DateTime creationDate;
  final Uint8List? thumbnailBytes;

  const VideoAsset({
    required this.id,
    this.localIdentifier,
    required this.path,
    required this.title,
    required this.fileSizeBytes,
    required this.duration,
    required this.width,
    required this.height,
    required this.fps,
    this.codec = 'H.264',
    this.isAccessible = true,
    this.mimeType,
    required this.creationDate,
    this.thumbnailBytes,
  });

  /// Guaranteed non-null persistent identifier across PhotoKit/MediaStore.
  String get effectiveId => localIdentifier ?? id;

  /// Compatibility aliases
  int get resolutionWidth => width;
  int get resolutionHeight => height;
  int get sizeInBytes => fileSizeBytes;

  /// Human-readable resolution label (e.g., "4K", "2K", "1080p", "720p", "480p").
  /// Orientation-agnostic: correctly labels vertical/portrait and horizontal/landscape videos.
  String get resolutionLabel {
    final maxDim = width > height ? width : height;
    final minDim = width > height ? height : width;

    if (maxDim >= 3840 || minDim >= 2160) return '4K';
    if (maxDim >= 2560 || minDim >= 1440) return '2K';
    if (maxDim >= 1920 || minDim >= 1080) return '1080p';
    if (maxDim >= 1280 || minDim >= 720) return '720p';
    if (maxDim >= 854 || minDim >= 480) return '480p';
    return '${width}x$height';
  }

  /// Compact spec string (e.g., "4K • 60 FPS", "1080p • 30 FPS").
  String get specLabel => '$resolutionLabel • ${fps.round()} FPS';

  /// Formatted duration string (e.g., "01:30" or "01:15:00").
  String get formattedDuration => duration.formatDuration();

  /// Formatted file size string (e.g., "1.2 GB" or "350.0 MB").
  String get formattedSize => fileSizeBytes.formatBytes();

  /// Aspect ratio calculation. Defaults to standard 16:9 if dimensions unavailable.
  double get aspectRatio => (width > 0 && height > 0) ? width / height : (16 / 9);

  /// Whether the video was shot in portrait/vertical orientation.
  bool get isPortrait => height > width;

  VideoAsset copyWith({
    String? id,
    String? localIdentifier,
    String? path,
    String? title,
    int? fileSizeBytes,
    Duration? duration,
    int? width,
    int? height,
    double? fps,
    String? codec,
    bool? isAccessible,
    String? mimeType,
    DateTime? creationDate,
    Uint8List? thumbnailBytes,
  }) {
    return VideoAsset(
      id: id ?? this.id,
      localIdentifier: localIdentifier ?? this.localIdentifier,
      path: path ?? this.path,
      title: title ?? this.title,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      duration: duration ?? this.duration,
      width: width ?? this.width,
      height: height ?? this.height,
      fps: fps ?? this.fps,
      codec: codec ?? this.codec,
      isAccessible: isAccessible ?? this.isAccessible,
      mimeType: mimeType ?? this.mimeType,
      creationDate: creationDate ?? this.creationDate,
      thumbnailBytes: thumbnailBytes ?? this.thumbnailBytes,
    );
  }
}

