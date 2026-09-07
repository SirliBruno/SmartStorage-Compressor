import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/models/compression_preset.dart';
import '../../domain/models/video_asset.dart';
import '../controllers/video_library_controller.dart';

/// Screen displayed after a user selects a video from the library.
/// Displays exhaustive inspection metadata and preset selector in preparation for Sprint 04.
class CompressionPrepareScreen extends ConsumerStatefulWidget {
  final String assetId;
  final VideoAsset? initialVideo;

  const CompressionPrepareScreen({
    super.key,
    required this.assetId,
    this.initialVideo,
  });

  @override
  ConsumerState<CompressionPrepareScreen> createState() => _CompressionPrepareScreenState();
}

class _CompressionPrepareScreenState extends ConsumerState<CompressionPrepareScreen> {
  VideoAsset? _video;
  bool _isLoading = false;
  PresetType _selectedPreset = PresetType.whatsAppFast;

  @override
  void initState() {
    super.initState();
    _video = widget.initialVideo;
    if (_video == null) {
      _loadVideo();
    }
  }

  Future<void> _loadVideo() async {
    setState(() => _isLoading = true);
    final video = await ref.read(videoLibraryProvider.notifier).findVideoById(widget.assetId);
    if (mounted) {
      setState(() {
        _video = video;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final mediaRepo = ref.watch(mediaRepositoryProvider);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(l10n.placeholderCompressorTitle)),
        body: const Center(
          child: CircularProgressIndicator(color: AppColors.accentCyan),
        ),
      );
    }

    final video = _video;
    if (video == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(l10n.placeholderCompressorTitle)),
        body: Center(
          child: Text(
            l10n.noVideosFound,
            style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.videoLibraryTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Preview Thumbnail Card
              Center(
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      FutureBuilder<Uint8List?>(
                        future: mediaRepo.getThumbnail(video.id, width: 640, height: 400),
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != null) {
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                            );
                          }
                          return const Center(
                            child: Icon(Icons.movie_filter_outlined, size: 48, color: AppColors.textTertiary),
                          );
                        },
                      ),
                      // Duration badge bottom right
                      Positioned(
                        bottom: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            video.formattedDuration,
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. Video Title & Quick Size
              Text(
                video.title,
                style: AppTypography.headlineSmall.copyWith(fontWeight: FontWeight.bold),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                'Original Size: ${video.formattedSize}',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.accentCyan,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 20),

              // 3. Metadata Inspection Grid
              Text(
                'Video Specifications',
                style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _buildMetaRow('Resolution', '${video.width} x ${video.height} (${video.resolutionLabel})'),
                    const Divider(color: AppColors.border, height: 20),
                    _buildMetaRow('Framerate', '${video.fps.round()} FPS'),
                    const Divider(color: AppColors.border, height: 20),
                    _buildMetaRow('Codec', video.codec),
                    const Divider(color: AppColors.border, height: 20),
                    _buildMetaRow('Duration', video.formattedDuration),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // 4. Preset Selection Preview
              Text(
                'Compression Presets',
                style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              _buildPresetCard(
                type: PresetType.whatsAppFast,
                title: l10n.presetWhatsApp,
                desc: l10n.presetWhatsAppDesc,
                isPro: false,
              ),
              const SizedBox(height: 10),
              _buildPresetCard(
                type: PresetType.emailReady,
                title: l10n.presetEmail,
                desc: l10n.presetEmailDesc,
                isPro: false,
              ),
              const SizedBox(height: 10),
              _buildPresetCard(
                type: PresetType.maxSpaceSaver,
                title: l10n.presetMaxSaver,
                desc: l10n.presetMaxSaverDesc,
                isPro: true,
              ),
              const SizedBox(height: 10),
              _buildPresetCard(
                type: PresetType.customSize,
                title: l10n.presetCustom,
                desc: l10n.presetCustomDesc,
                isPro: true,
              ),

              const SizedBox(height: 32),

              // 5. CTA Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Video inspected successfully! Compression engine executes in Sprint 04.',
                        ),
                        backgroundColor: AppColors.cardBackground,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Text(
                    l10n.startCompression,
                    style: AppTypography.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
        Text(value, style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildPresetCard({
    required PresetType type,
    required String title,
    required String desc,
    required bool isPro,
  }) {
    final isSelected = _selectedPreset == type;

    return GestureDetector(
      onTap: () => setState(() => _selectedPreset = type),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.12) : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_unchecked_rounded,
              color: isSelected ? AppColors.accentCyan : AppColors.textTertiary,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (isPro) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accentOrange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'PRO',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.accentOrange,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
