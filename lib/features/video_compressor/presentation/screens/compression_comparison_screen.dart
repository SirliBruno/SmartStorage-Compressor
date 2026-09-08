import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/file_size_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/models/compression_session.dart';
import '../controllers/comparison_controller.dart';
import '../widgets/video_comparison_slider.dart';

/// Screen presenting real-time side-by-side video comparison and persistent gallery save actions.
class CompressionComparisonScreen extends ConsumerWidget {
  final CompressionSession session;

  const CompressionComparisonScreen({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(comparisonControllerProvider(session));
    final notifier = ref.read(comparisonControllerProvider(session).notifier);
    final l10n = context.l10n;

    return PopScope(
      canPop: !state.isProcessing,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          notifier.cleanupSession();
        } else {
          _showExitWarning(context);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          title: Text(
            l10n.comparisonTitle,
            style: AppTypography.titleLarge.copyWith(color: AppColors.textPrimary),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textSecondary),
            onPressed: state.isProcessing
                ? () => _showExitWarning(context)
                : () {
                    notifier.cleanupSession();
                    context.pop();
                  },
          ),
        ),
        body: SafeArea(
          child: state.isSuccess
              ? _buildSuccessView(context, state, notifier)
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 1. Savings Highlight Badge
                      _buildSavingsBadge(context, state),

                      const SizedBox(height: 12),

                      // 2. Comparison Metadata Stats Card (Original vs Compressed)
                      _buildStatsCard(context, state),

                      const SizedBox(height: 16),

                      // 3. Interactive Split-Screen Video Slider
                      VideoComparisonSlider(
                        originalPath: session.originalAsset.path,
                        compressedPath: session.compressedPath,
                        originalAsset: session.originalAsset,
                      ),

                      const SizedBox(height: 16),

                      // 4. Error banner if save failed
                      if (state.errorMessage != null) ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.error.withOpacity(0.4)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  state.errorMessage!,
                                  style: AppTypography.caption.copyWith(color: AppColors.error),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // 5. Save as Copy Action (Primary)
                      AppButton(
                        text: l10n.saveAsCopy,
                        isLoading: state.saveStatus == SaveStatus.saving,
                        onPressed: state.isProcessing
                            ? null
                            : () => notifier.saveAsCopy(),
                      ),

                      const SizedBox(height: 10),

                      // 6. Replace Original Action (Secondary with Confirmation)
                      SizedBox(
                        height: 52,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border, width: 1.2),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: state.isProcessing
                              ? null
                              : () => _showReplaceConfirmationDialog(context, notifier),
                          child: state.saveStatus == SaveStatus.replacing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentCyan),
                                )
                              : Text(
                                  l10n.replaceOriginal,
                                  style: AppTypography.bodyLarge.copyWith(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSavingsBadge(BuildContext context, ComparisonState state) {
    final l10n = context.l10n;
    final savedPercent = state.savedPercentage.toStringAsFixed(1);
    final savedSize = state.savedBytes.formatFileSize();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.savings_rounded, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            l10n.spaceSaved(savedPercent),
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '($savedSize)',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, ComparisonState state) {
    final l10n = context.l10n;
    final origAsset = session.originalAsset;
    final result = session.result;

    final origSize = state.originalSizeBytes.formatFileSize();
    final compSize = state.compressedSizeBytes.formatFileSize();

    final origRes = '${origAsset.width}x${origAsset.height}';
    final compRes = result.compressedResolution ?? (result.targetResolutionWidth != null
        ? '${result.targetResolutionWidth}x${result.targetResolutionHeight}'
        : origRes);

    return AppCard(
      child: Row(
        children: [
          // Original Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.original, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 4),
                Text(
                  origSize,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  origRes,
                  style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),

          // Flow indicator arrow
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.arrow_back_rounded
                  : Icons.arrow_forward_rounded,
              color: AppColors.accentCyan,
              size: 24,
            ),
          ),

          // Compressed Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(l10n.compressed, style: AppTypography.caption.copyWith(color: AppColors.accentCyan)),
                const SizedBox(height: 4),
                Text(
                  compSize,
                  style: AppTypography.titleMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  compRes,
                  style: AppTypography.caption.copyWith(color: AppColors.accentCyan),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(
    BuildContext context,
    ComparisonState state,
    ComparisonNotifier notifier,
  ) {
    final l10n = context.l10n;
    final isReplaced = state.saveStatus == SaveStatus.replaced;
    final savedSize = state.savedBytes.formatFileSize();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 54),
          ),
          const SizedBox(height: 20),
          Text(
            isReplaced ? l10n.replaceSuccess : l10n.saveSuccess,
            textAlign: TextAlign.center,
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.freedSpaceSuccess(savedSize),
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.accentCyan,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          AppButton(
            text: l10n.done,
            onPressed: () {
              notifier.cleanupSession();
              context.go('/dashboard');
            },
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.border, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () {
                notifier.cleanupSession();
                context.go('/video-compressor');
              },
              child: Text(
                l10n.compressAnotherVideo,
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showReplaceConfirmationDialog(BuildContext context, ComparisonNotifier notifier) {
    final l10n = context.l10n;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          l10n.replaceConfirmTitle,
          style: AppTypography.titleMedium.copyWith(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.replaceConfirmBody,
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.replaceWarning,
              style: AppTypography.caption.copyWith(color: AppColors.error),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel, style: const TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              notifier.confirmReplaceOriginal();
            },
            child: Text(l10n.replaceOriginal),
          ),
        ],
      ),
    );
  }

  void _showExitWarning(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please wait until the save operation completes.'),
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }
}
