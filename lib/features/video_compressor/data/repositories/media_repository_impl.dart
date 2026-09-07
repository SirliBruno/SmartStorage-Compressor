import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';
import '../../../../core/utils/logger.dart';
import '../../../../services/media/thumbnail_service.dart';
import '../../../../services/media/video_metadata_service.dart';
import '../../domain/models/video_asset.dart';
import '../../domain/repositories/media_repository.dart';

/// Native implementation of [MediaRepository] interacting directly with PhotoManager
/// on iOS (PhotoKit) and Android (MediaStore/Scoped Storage).
/// 100% on-device, offline, and memory bounded.
class MediaRepositoryImpl implements MediaRepository {
  final ThumbnailService _thumbnailService;
  final Map<String, AssetEntity> _entityCache = {};

  MediaRepositoryImpl({ThumbnailService? thumbnailService})
      : _thumbnailService = thumbnailService ?? ThumbnailService();

  @override
  Future<List<VideoAsset>> getVideos({
    bool sortByLargest = true,
    int page = 0,
    int pageSize = 100,
  }) async {
    try {
      AppLogger.info('Querying device video albums...');
      final albums = await PhotoManager.getAssetPathList(type: RequestType.video);
      if (albums.isEmpty) {
        AppLogger.info('No video albums found on device.');
        return [];
      }

      // The primary album (index 0) is usually the Camera Roll / All Videos album
      final primaryAlbum = albums.first;
      final totalAssets = await primaryAlbum.assetCountAsync;

      if (totalAssets == 0) {
        return [];
      }

      // Cap batch size to keep RAM overhead well under 50 MB
      final fetchLimit = totalAssets.clamp(0, 150);
      AppLogger.info('Fetching $fetchLimit video entities from primary album...');

      final assetEntities = await primaryAlbum.getAssetListRange(
        start: 0,
        end: fetchLimit,
      );

      final List<VideoAsset> videos = [];

      for (final entity in assetEntities) {
        _entityCache[entity.id] = entity;

        final inspected = await VideoMetadataService.inspectAsset(entity);
        if (inspected != null) {
          videos.add(inspected);
        }
      }

      // Sort by file size descending (Largest First)
      if (sortByLargest) {
        videos.sort((a, b) => b.fileSizeBytes.compareTo(a.fileSizeBytes));
      }

      AppLogger.info('Successfully parsed ${videos.length} videos. Largest: ${videos.isNotEmpty ? videos.first.formattedSize : "0 B"}');
      return videos;
    } catch (e, stack) {
      AppLogger.error('Error fetching videos from media repository: $e', e, stack);
      return [];
    }
  }

  @override
  Future<Uint8List?> getThumbnail(
    String assetId, {
    int width = 256,
    int height = 256,
    int quality = 80,
  }) async {
    try {
      var entity = _entityCache[assetId];
      if (entity == null) {
        entity = await AssetEntity.fromId(assetId);
        if (entity != null) {
          _entityCache[assetId] = entity;
        }
      }

      if (entity == null) {
        AppLogger.warning('Cannot load thumbnail: asset $assetId not found');
        return null;
      }

      return await _thumbnailService.getThumbnail(
        entity,
        width: width,
        height: height,
        quality: quality,
      );
    } catch (e, stack) {
      AppLogger.warning('Failed loading thumbnail for $assetId: $e', e, stack);
      return null;
    }
  }

  @override
  Future<VideoAsset?> getVideoById(String assetId) async {
    try {
      var entity = _entityCache[assetId];
      entity ??= await AssetEntity.fromId(assetId);
      if (entity == null) return null;

      _entityCache[assetId] = entity;
      return await VideoMetadataService.inspectAsset(entity);
    } catch (e, stack) {
      AppLogger.warning('Failed to get video by ID $assetId: $e', e, stack);
      return null;
    }
  }

  @override
  Future<String?> getOriginFilePath(String assetId) async {
    try {
      var entity = _entityCache[assetId];
      entity ??= await AssetEntity.fromId(assetId);
      if (entity == null) return null;

      final file = await entity.file;
      return file?.path;
    } catch (e, stack) {
      AppLogger.warning('Failed to resolve file path for $assetId: $e', e, stack);
      return null;
    }
  }
}
