import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../../../../services/permissions/permission_service.dart';
import '../controllers/video_library_controller.dart';
import '../widgets/video_card.dart';

/// Video Picker & Library Inspection Screen.
/// Displays on-device videos sorted largest first, with metadata badges and pull-to-refresh.
class VideoPickerScreen extends ConsumerStatefulWidget {
  const VideoPickerScreen({super.key});

  @override
  ConsumerState<VideoPickerScreen> createState() => _VideoPickerScreenState();
}

class _VideoPickerScreenState extends ConsumerState<VideoPickerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videoLibraryProvider.notifier).loadVideos();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = ref.watch(videoLibraryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.videoLibraryTitle),
            Text(
              l10n.sortByLargest,
              style: AppTypography.caption.copyWith(
                color: AppColors.accentCyan,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Refresh',
            onPressed: () => ref.read(videoLibraryProvider.notifier).loadVideos(forceRefresh: true),
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(context, state),
      ),
    );
  }

  Widget _buildBody(BuildContext context, VideoLibraryState state) {
    final l10n = context.l10n;

    // 1. Loading State
    if (state.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.accentCyan),
            const SizedBox(height: 20),
            Text(
              'Scanning your videos...',
              style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              'Finding your largest files',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    // 2. Permission Denied / Restricted State
    if (state.hasPermissionError) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline_rounded, size: 64, color: AppColors.accentOrange),
              const SizedBox(height: 20),
              Text(
                l10n.permissionDenied,
                style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                l10n.permissionSettingsHint,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.settings_outlined, color: Colors.white),
                label: Text(
                  l10n.openSettings,
                  style: AppTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () => ref.read(permissionServiceProvider).openAppSettings(),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Empty State (No videos on device)
    if (state.isEmpty || state.videos.isEmpty) {
      return RefreshIndicator(
        color: AppColors.accentCyan,
        backgroundColor: AppColors.cardBackground,
        onRefresh: () => ref.read(videoLibraryProvider.notifier).loadVideos(forceRefresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            EmptyStateView(
              icon: Icons.video_collection_outlined,
              title: l10n.noVideosFound,
              subtitle: 'There are no videos available to analyze on this device.',
            ),
          ],
        ),
      );
    }

    // 4. Loaded State: List of largest videos
    return RefreshIndicator(
      color: AppColors.accentCyan,
      backgroundColor: AppColors.cardBackground,
      onRefresh: () => ref.read(videoLibraryProvider.notifier).loadVideos(forceRefresh: true),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // Limited access alert banner if applicable
          if (state.isLimitedAccess)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.accentOrange.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accentOrange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.accentOrange, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l10n.permissionLimitedDesc,
                        style: AppTypography.caption.copyWith(color: AppColors.textPrimary),
                      ),
                    ),
                    TextButton(
                      onPressed: () => ref.read(permissionServiceProvider).openAppSettings(),
                      child: Text(
                        l10n.openSettings,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.accentCyan,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // Video Card List
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final video = state.videos[index];
                return VideoCard(
                  video: video,
                  onTap: () {
                    ref.read(videoLibraryProvider.notifier).selectVideo(video);
                    context.push('/compressor/prepare', extra: video);
                  },
                );
              },
              childCount: state.videos.length,
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
