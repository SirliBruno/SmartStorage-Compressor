import 'dart:async';
import 'dart:collection';
import 'dart:typed_data';
import 'package:photo_manager/photo_manager.dart';
import '../../core/utils/logger.dart';

/// Memory-conscious thumbnail cache and extraction service.
/// Uses an LRU cache with strict bounds to guarantee zero memory leaks or spikes.
class ThumbnailService {
  static final ThumbnailService _instance = ThumbnailService._internal();
  factory ThumbnailService() => _instance;
  ThumbnailService._internal();

  /// Maximum thumbnails kept simultaneously in memory (~10-15 MB RAM maximum).
  static const int maxCacheEntries = 120;

  final LinkedHashMap<String, Uint8List> _cache = LinkedHashMap<String, Uint8List>();
  final Map<String, Future<Uint8List?>> _inFlight = {};

  /// Retrieves thumbnail bytes for an [AssetEntity], using LRU memory cache if available.
  /// Falls back gracefully to null if thumbnail extraction encounters corrupt or missing files.
  Future<Uint8List?> getThumbnail(
    AssetEntity asset, {
    int width = 256,
    int height = 256,
    int quality = 80,
  }) async {
    final key = '${asset.id}_${width}x$height';

    // 1. Cache hit: Move to most-recently used
    if (_cache.containsKey(key)) {
      final data = _cache.remove(key)!;
      _cache[key] = data;
      return data;
    }

    // 2. In-flight request de-duplication
    if (_inFlight.containsKey(key)) {
      return _inFlight[key]!;
    }

    // 3. Perform asynchronous extraction
    final completer = Completer<Uint8List?>();
    _inFlight[key] = completer.future;

    try {
      final bytes = await asset.thumbnailDataWithSize(
        ThumbnailSize(width, height),
        quality: quality,
      );

      if (bytes != null && bytes.isNotEmpty) {
        _put(key, bytes);
      }
      completer.complete(bytes);
      return bytes;
    } catch (e, stack) {
      AppLogger.warning(
        'Thumbnail extraction failed for asset ${asset.id}: $e',
        error: e,
        stackTrace: stack,
      );
      completer.complete(null);
      return null;
    } finally {
      _inFlight.remove(key);
    }
  }

  /// Inserts a thumbnail into the LRU cache, evicting the oldest if capacity is exceeded.
  void _put(String key, Uint8List data) {
    if (_cache.length >= maxCacheEntries) {
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }
    _cache[key] = data;
  }

  /// Evicts a specific asset thumbnail from memory.
  void evict(String assetId) {
    _cache.removeWhere((key, _) => key.startsWith(assetId));
  }

  /// Clears all thumbnails from memory (e.g., on low memory or leaving screen).
  void clear() {
    _cache.clear();
    _inFlight.clear();
  }

  /// Number of currently cached thumbnails.
  int get cachedCount => _cache.length;
}
