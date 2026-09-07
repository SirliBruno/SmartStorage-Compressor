import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/file_size_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/empty_state_view.dart';
import '../controllers/scan_controller.dart';

/// Screen presenting real insights derived from the on-device media scan.
class ScanResultScreen extends ConsumerWidget {
  const ScanResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final scanState = ref.watch(scanProvider);
    final result = scanState.result;

    // Case 1: No media found / Clean storage (Empty State)
    if (!result.hasMedia) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const Spacer(),
                EmptyStateView(
                  icon: Icons.check_circle_outline_rounded,
                  title: l10n.scanResultEmptyTitle,
                  subtitle: l10n.scanResultEmptyDesc,
                ),
                const Spacer(),
                AppButton(
                  text: l10n.continueToPaywall,
                  onPressed: () => context.go('/paywall'),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      );
    }

    // Case 2: Media found -> Display real calculated insights
    final recoverableFormatted = result.estimatedRecoverableBytes.formatBytes();
    final detailsText = l10n.scanResultFoundDetails(result.videoCount, result.screenshotCount);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Header Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      l10n.scanResultHeader,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                l10n.scanResultRecoverable,
                style: context.textTheme.headlineMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),

              // Hero Recoverable Metric (Calculated from real assets)
              Text(
                recoverableFormatted,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                detailsText,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 32),

              // Breakdown Cards
              AppCard(
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceHighlight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.video_library_rounded, size: 20, color: AppColors.primary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.largeVideos,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                              Text(
                                '${result.videoCount} items detected',
                                style: context.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(color: AppColors.divider),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceHighlight,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.screenshot_rounded, size: 20, color: AppColors.secondary),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.screenshots,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                              ),
                              Text(
                                '${result.screenshotCount} items detected',
                                style: context.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              AppButton(
                text: l10n.continueToPaywall,
                onPressed: () => context.go('/paywall'),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
