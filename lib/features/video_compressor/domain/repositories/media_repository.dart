import 'dart:typed_data';
import '../models/video_asset.dart';

/// Domain contract for inspecting local device media library videos and thumbnails.
/// Designed for 100% on-device operations with zero whole-file RAM caching.
abstract class MediaRepository {
  /// Fetches video assets from device storage, sorted by size descending (largest first) by default.
  Future<List<VideoAsset>> getVideos({
    bool sortByLargest = true,
    int page = 0,
    int pageSize = 50,
  });

  /// Fetches thumbnail bytes for a video asset with memory-constrained dimensions.
  Future<Uint8List?> getThumbnail(
    String assetId, {
    int width = 256,
    int height = 256,
    int quality = 80,
  });

  /// Fetches detailed metadata for a single video asset by its persistent identifier.
  Future<VideoAsset?> getVideoById(String assetId);

  /// Resolves the filesystem file path for an asset when required for local processing.
  Future<String?> getOriginFilePath(String assetId);
}
