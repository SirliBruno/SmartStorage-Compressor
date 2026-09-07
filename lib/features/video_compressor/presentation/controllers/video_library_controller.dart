import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../../../services/permissions/permission_service.dart';
import '../../data/repositories/media_repository_impl.dart';
import '../../domain/models/video_asset.dart';
import '../../domain/repositories/media_repository.dart';

/// Status of the video library loading lifecycle.
enum VideoLibraryStatus {
  initial,
  loading,
  loaded,
  empty,
  permissionDenied,
  permissionLimited,
  permissionRestricted,
  error,
}

/// Immutable state for the video library screen.
class VideoLibraryState {
  final VideoLibraryStatus status;
  final List<VideoAsset> videos;
  final VideoAsset? selectedVideo;
  final String? errorMessage;
  final bool isLimitedAccess;

  const VideoLibraryState({
    this.status = VideoLibraryStatus.initial,
    this.videos = const [],
    this.selectedVideo,
    this.errorMessage,
    this.isLimitedAccess = false,
  });

  bool get isLoading => status == VideoLibraryStatus.loading;
  bool get isEmpty => status == VideoLibraryStatus.empty;
  bool get isLoaded => status == VideoLibraryStatus.loaded;
  bool get hasPermissionError =>
      status == VideoLibraryStatus.permissionDenied ||
      status == VideoLibraryStatus.permissionRestricted;

  VideoLibraryState copyWith({
    VideoLibraryStatus? status,
    List<VideoAsset>? videos,
    VideoAsset? selectedVideo,
    String? errorMessage,
    bool? isLimitedAccess,
    bool clearSelectedVideo = false,
  }) {
    return VideoLibraryState(
      status: status ?? this.status,
      videos: videos ?? this.videos,
      selectedVideo: clearSelectedVideo ? null : (selectedVideo ?? this.selectedVideo),
      errorMessage: errorMessage ?? this.errorMessage,
      isLimitedAccess: isLimitedAccess ?? this.isLimitedAccess,
    );
  }
}

/// Riverpod provider for MediaRepository.
final mediaRepositoryProvider = Provider<MediaRepository>((ref) {
  return MediaRepositoryImpl();
});

/// Riverpod provider for VideoLibraryNotifier.
final videoLibraryProvider =
    StateNotifierProvider<VideoLibraryNotifier, VideoLibraryState>((ref) {
  final repository = ref.watch(mediaRepositoryProvider);
  final permissionService = ref.watch(permissionServiceProvider);
  return VideoLibraryNotifier(repository, permissionService);
});

/// Controller orchestrating local video inspection and sorting largest first.
class VideoLibraryNotifier extends StateNotifier<VideoLibraryState> {
  final MediaRepository _mediaRepository;
  final PermissionService _permissionService;

  VideoLibraryNotifier(this._mediaRepository, this._permissionService)
      : super(const VideoLibraryState());

  /// Loads videos from device storage, checking permissions and sorting largest first.
  Future<void> loadVideos({bool forceRefresh = false}) async {
    if (state.isLoading && !forceRefresh) return;

    state = state.copyWith(status: VideoLibraryStatus.loading);

    try {
      // 1. Verify media library permissions
      final permission = await _permissionService.checkMediaPermission();
      if (permission == MediaPermissionState.denied) {
        state = state.copyWith(status: VideoLibraryStatus.permissionDenied);
        return;
      } else if (permission == MediaPermissionState.restricted) {
        state = state.copyWith(status: VideoLibraryStatus.permissionRestricted);
        return;
      }

      final isLimited = permission == MediaPermissionState.limited;

      // 2. Fetch videos from local storage, sorted by file size descending
      final videos = await _mediaRepository.getVideos(sortByLargest: true);

      if (videos.isEmpty) {
        state = state.copyWith(
          status: VideoLibraryStatus.empty,
          videos: const [],
          isLimitedAccess: isLimited,
        );
      } else {
        state = state.copyWith(
          status: VideoLibraryStatus.loaded,
          videos: videos,
          isLimitedAccess: isLimited,
        );
      }
    } catch (e, stack) {
      AppLogger.error('Failed to load video library: $e', e, stack);
      state = state.copyWith(
        status: VideoLibraryStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Selects a video for compression preparation.
  void selectVideo(VideoAsset video) {
    state = state.copyWith(selectedVideo: video);
  }

  /// Clears the currently selected video.
  void clearSelection() {
    state = state.copyWith(clearSelectedVideo: true);
  }

  /// Finds a video by ID from loaded videos or repository.
  Future<VideoAsset?> findVideoById(String id) async {
    final cached = state.videos.where((v) => v.id == id || v.localIdentifier == id).firstOrNull;
    if (cached != null) return cached;
    return await _mediaRepository.getVideoById(id);
  }
}
