import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/file_size_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/models/compression_preset.dart';
import '../../domain/models/compression_status.dart';
import '../../domain/models/video_asset.dart';
import '../controllers/compression_controller.dart';
import '../controllers/video_library_controller.dart';

/// Screen executing the real-time hardware compression lifecycle with live progress and cancel capability.
class CompressionScreen extends ConsumerStatefulWidget {
  final VideoAsset video;
  final CompressionPreset preset;
  final int? customTargetSizeBytes;

  const CompressionScreen({
    super.key,
    required this.video,
    required this.preset,
    this.customTargetSizeBytes,
  });

  @override
  ConsumerState<CompressionScreen> createState() => _CompressionScreenState();
}

class _CompressionScreenState extends ConsumerState<CompressionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(compressionProvider.notifier).startCompression(
        video: widget.video,
        preset: widget.preset,
        customTargetSizeBytes: widget.customTargetSizeBytes,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(compressionProvider);
    final l10n = context.l10n;

    return PopScope(
      canPop: !state.status.isActive,
      onPopInvoked: (didPop) {
        if (!didPop && state.status.isActive) {
          _showCancelConfirmationDialog(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            state.isCompleted
                ? l10n.compressionCompleted
                : (state.isCancelled
                    ? l10n.compressionCancelled
                    : (state.isFailed ? l10n.compressionFailed : l10n.compressingVideo)),
            style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
          ),
          leading: state.status.isActive
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => _showCancelConfirmationDialog(context),
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary),
                  onPressed: () => context.pop(),
                ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: switch (state.status) {
              CompressionStatus.idle || CompressionStatus.preparing => _buildPreparingView(context),
              CompressionStatus.compressing => _buildCompressingView(context, state),
              CompressionStatus.completed => _buildCompletedView(context, state),
              CompressionStatus.cancelled => _buildCancelledView(context),
              CompressionStatus.failed => _buildFailedView(context, state),
            },
          ),
        ),
      ),
    );
  }

  // 1. Preparing State View
  Widget _buildPreparingView(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.accentCyan),
          const SizedBox(height: 24),
          Text(
            l10n.preparingCompression,
            style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }

  // 2. Active Compressing View with Real Progress
  Widget _buildCompressingView(BuildContext context, CompressionState state) {
    final l10n = context.l10n;
    final remainingText = state.estimatedRemaining != null
        ? '${state.estimatedRemaining!.inSeconds}s remaining'
        : l10n.calculating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Spacer(),

        // Circular progress indicator with percentage in center
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 180,
              height: 180,
              child: CircularProgressIndicator(
                value: state.progress > 0 ? state.progress : null,
                strokeWidth: 10,
                backgroundColor: AppColors.surfaceElevated,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentCyan),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(state.progress * 100).toInt()}%',
                  style: AppTypography.displayLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.processing,
                  style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Video and Preset details card
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.video.title,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Original: ${widget.video.fileSizeBytes.formatFileSize()}',
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
                  ),
                  Text(
                    remainingText,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.accentCyan,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Spacer(),

        // Cancel Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border, width: 1.2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => _showCancelConfirmationDialog(context),
            child: Text(
              l10n.cancel,
              style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  // 3. Completed View with Before/After Stats
  Widget _buildCompletedView(BuildContext context, CompressionState state) {
    final l10n = context.l10n;
    final result = state.result;
    final originalSize = result?.originalSizeBytes ?? widget.video.fileSizeBytes;
    final compressedSize = result?.compressedSizeBytes ?? 0;
    final savedBytes = result?.savedBytes ?? 0;
    final savedPercent = result?.savedPercentage ?? 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 24),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 48),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.compressionCompleted,
          style: AppTypography.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Saved ${savedPercent.toStringAsFixed(1)}% (${savedBytes.formatFileSize()})',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Before & After comparison card
        AppCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(l10n.original, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                  const SizedBox(height: 6),
                  Text(
                    originalSize.formatFileSize(),
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.arrow_forward_rounded, color: AppColors.accentCyan),
              Column(
                children: [
                  Text(l10n.compressed, style: AppTypography.caption.copyWith(color: AppColors.accentCyan)),
                  const SizedBox(height: 6),
                  Text(
                    compressedSize.formatFileSize(),
                    style: AppTypography.titleMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const Spacer(),

        // Continue Button
        AppButton(
          text: l10n.continueButton,
          onPressed: () {
            ref.read(videoLibraryProvider.notifier).loadVideos(forceRefresh: true);
            context.pop();
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // 4. Cancelled View
  Widget _buildCancelledView(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.cancel_outlined, color: AppColors.textSecondary, size: 64),
        const SizedBox(height: 16),
        Text(
          l10n.compressionCancelled,
          style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.compressionCancelledDesc,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        AppButton(
          text: l10n.tryAgain,
          onPressed: () {
            ref.read(compressionProvider.notifier).startCompression(
              video: widget.video,
              preset: widget.preset,
              customTargetSizeBytes: widget.customTargetSizeBytes,
            );
          },
        ),
      ],
    );
  }

  // 5. Failed View
  Widget _buildFailedView(BuildContext context, CompressionState state) {
    final l10n = context.l10n;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 64),
        const SizedBox(height: 16),
        Text(
          l10n.compressionFailed,
          style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Text(
          state.errorMessage ?? l10n.compressionFailed,
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 32),
        AppButton(
          text: l10n.tryAgain,
          onPressed: () {
            ref.read(compressionProvider.notifier).startCompression(
              video: widget.video,
              preset: widget.preset,
              customTargetSizeBytes: widget.customTargetSizeBytes,
            );
          },
        ),
      ],
    );
  }

  void _showCancelConfirmationDialog(BuildContext context) {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Text(l10n.cancel, style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary)),
        content: Text(
          l10n.isArabic
              ? 'هل أنت متأكد من رغبتك في إلغاء ضغط الفيديو؟ سيتم حذف الملفات المؤقتة فوراً.'
              : 'Are you sure you want to cancel video compression? Temporary files will be deleted immediately.',
          style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: Text(l10n.isArabic ? 'استمرار الضغط' : 'Keep Compressing'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              ref.read(compressionProvider.notifier).cancelCompression();
            },
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }
}
