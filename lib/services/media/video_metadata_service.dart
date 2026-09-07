import 'package:photo_manager/photo_manager.dart';
import '../../core/utils/logger.dart';
import '../../features/video_compressor/domain/models/video_asset.dart';

/// Service responsible for extracting and enriching video metadata
/// from native AssetEntities without loading full video bytes into memory.
class VideoMetadataService {
  /// Converts a photo_manager [AssetEntity] into our domain [VideoAsset].
  /// Accurately checks file size on disk and extracts resolution, duration, and codec hints.
  static Future<VideoAsset?> inspectAsset(AssetEntity asset) async {
    try {
      final durationSecs = asset.duration;
      final duration = Duration(seconds: durationSecs);
      final width = asset.width;
      final height = asset.height;

      // Extract accurate file size on device storage
      int fileSizeBytes = 0;
      String filePath = '';
      bool isAccessible = true;

      try {
        final file = await asset.file;
        if (file != null && await file.exists()) {
          fileSizeBytes = await file.length();
          filePath = file.path;
        } else {
          // Asset might be in iCloud or deleted from local disk
          isAccessible = false;
        }
      } catch (e) {
        AppLogger.warning('Could not query physical file size for asset ${asset.id}: $e');
        isAccessible = false;
      }

      // Codec inference based on mimeType, file extension, and platform traits
      final mimeType = asset.mimeType;
      String codec = _inferCodec(mimeType, filePath);

      // Default FPS estimation: Standard mobile recordings are 30.0 or 60.0 FPS
      double fps = 30.0;
      if (mimeType != null && mimeType.contains('60')) {
        fps = 60.0;
      }

      final title = asset.title?.isNotEmpty == true
          ? asset.title!
          : 'Video_${asset.createDateTime.millisecondsSinceEpoch}';

      return VideoAsset(
        id: asset.id,
        localIdentifier: asset.id,
        path: filePath,
        title: title,
        fileSizeBytes: fileSizeBytes,
        duration: duration,
        width: width,
        height: height,
        fps: fps,
        codec: codec,
        isAccessible: isAccessible,
        mimeType: mimeType,
        creationDate: asset.createDateTime,
      );
    } catch (e, stack) {
      AppLogger.error('Failed inspecting asset metadata ${asset.id}: $e', e, stack);
      return null;
    }
  }

  /// Infers video codec from mimeType, file extension, and platform characteristics.
  static String _inferCodec(String? mimeType, String path) {
    final lowerMime = mimeType?.toLowerCase() ?? '';
    final lowerPath = path.toLowerCase();

    if (lowerMime.contains('hevc') || lowerMime.contains('h265') || lowerPath.endsWith('.hevc')) {
      return 'HEVC (H.265)';
    }
    if (lowerMime.contains('vp9')) {
      return 'VP9';
    }
    if (lowerMime.contains('av1')) {
      return 'AV1';
    }
    if (lowerMime.contains('prores') || lowerPath.contains('prores')) {
      return 'Apple ProRes';
    }
    if (lowerMime.contains('mp4') || lowerMime.contains('avc') || lowerMime.contains('h264')) {
      return 'H.264 (AVC)';
    }
    if (lowerPath.endsWith('.mov')) {
      return 'H.264 / HEVC';
    }
    return 'H.264';
  }
}
