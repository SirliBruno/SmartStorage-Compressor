import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/progress_indicator_bar.dart';
import '../controllers/scan_controller.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';

/// Quick Scan Screen displaying real on-device inspection progress.
class QuickScanScreen extends ConsumerStatefulWidget {
  const QuickScanScreen({super.key});

  @override
  ConsumerState<QuickScanScreen> createState() => _QuickScanScreenState();
}

class _QuickScanScreenState extends ConsumerState<QuickScanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(scanProvider.notifier).startScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scanState = ref.watch(scanProvider);

    // When scan succeeds, update dashboard metrics and transition to scan-result
    ref.listen<QuickScanState>(scanProvider, (previous, next) {
      if (next.status == ScanStatus.success && previous?.status != ScanStatus.success) {
        ref.read(dashboardProvider.notifier).updateMetrics(
          totalStorageBytes: next.result.totalScannedBytes,
          usedStorageBytes: next.result.totalScannedBytes,
          freeStorageBytes: 0,
          recoverableBytes: next.result.estimatedRecoverableBytes,
          videoCount: next.result.videoCount,
          screenshotCount: next.result.screenshotCount,
        );
        context.go('/scan-result');
      }
    });

    String resolveTaskTitle(String key) {
      switch (key) {
        case 'taskVideos':
          return l10n.taskVideos;
        case 'taskScreenshots':
          return l10n.taskScreenshots;
        case 'taskCalculating':
          return l10n.taskCalculating;
        case 'scanCancelledTitle':
          return l10n.scanCancelledTitle;
        default:
          return l10n.scanningLibrary;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated Scanning Icon Container
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: AppColors.surfaceElevated,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: scanState.isCancelled ? AppColors.error : AppColors.primary,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    scanState.isCancelled
                        ? Icons.cancel_outlined
                        : Icons.radar_rounded,
                    size: 52,
                    color: scanState.isCancelled ? AppColors.error : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 36),

              Text(
                scanState.isCancelled ? l10n.scanCancelledTitle : l10n.quickScanTitle,
                textAlign: TextAlign.center,
                style: context.textTheme.headlineLarge,
              ),
              const SizedBox(height: 12),
              Text(
                scanState.isCancelled ? l10n.scanCancelledDesc : resolveTaskTitle(scanState.currentTaskKey),
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 36),

              // Real Progress Indicator Bar
              if (!scanState.isCancelled) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ProgressIndicatorBar(
                    progress: scanState.progress,
                    barColor: AppColors.primary,
                  ),
                ),
              ],

              const Spacer(),

              // Action Buttons
              if (scanState.isCancelled) ...[
                AppButton(
                  text: l10n.retryPermission,
                  onPressed: () => ref.read(scanProvider.notifier).startScan(),
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: l10n.cancel,
                  variant: AppButtonVariant.ghost,
                  onPressed: () => context.go('/permissions'),
                ),
              ] else ...[
                AppButton(
                  text: l10n.cancelScan,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => ref.read(scanProvider.notifier).cancelScan(),
                ),
              ],
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
