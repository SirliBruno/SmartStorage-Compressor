import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/extensions/file_size_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../controllers/dashboard_controller.dart';
import '../../../paywall/presentation/controllers/quota_controller.dart';

/// Central Dashboard Screen displaying real storage metrics and primary action triggers.
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final storageState = ref.watch(dashboardProvider);
    final quotaState = ref.watch(quotaProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          l10n.appName,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium_rounded, color: AppColors.goldPro),
            tooltip: l10n.paywallTitle,
            onPressed: () => context.push('/paywall'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pro / Free Quota Banner
              if (!quotaState.isProUser) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.bolt_rounded, size: 18, color: AppColors.goldPro),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.isArabic
                              ? 'النسخة المجانية: متبقي ${quotaState.remainingCompressions} من 3 عمليات ضغط'
                              : 'Free Plan: ${quotaState.remainingCompressions} of 3 compressions remaining',
                          style: context.textTheme.labelMedium?.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push('/paywall'),
                        child: Text(
                          l10n.isArabic ? 'ترقية' : 'Upgrade',
                          style: const TextStyle(
                            color: AppColors.goldPro,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Storage Overview Header
              Text(
                l10n.storageOverview,
                style: context.textTheme.headlineMedium?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),

              // Storage Overview Card (Zero fake data)
              AppCard(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.recoverableSpace,
                              style: context.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              storageState.recoverableBytes > 0
                                  ? storageState.recoverableBytes.formatBytes()
                                  : (storageState.hasScannedData
                                      ? '0 B'
                                      : (l10n.isArabic ? 'جاهز للفحص' : 'Ready to Scan')),
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _MetricTile(
                            label: l10n.largeVideos,
                            value: storageState.videoCount > 0
                                ? storageState.videoCount.toString()
                                : (storageState.hasScannedData ? '0' : '-'),
                            icon: Icons.video_library_rounded,
                          ),
                        ),
                        Container(width: 1, height: 40, color: AppColors.divider),
                        Expanded(
                          child: _MetricTile(
                            label: l10n.screenshots,
                            value: storageState.screenshotCount > 0
                                ? storageState.screenshotCount.toString()
                                : (storageState.hasScannedData ? '0' : '-'),
                            icon: Icons.screenshot_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Primary Actions
              Text(
                l10n.isArabic ? 'إجراءات إدارة المساحة' : 'Storage Actions',
                style: context.textTheme.headlineMedium?.copyWith(fontSize: 18),
              ),
              const SizedBox(height: 12),

              // Action 1: Compress Video
              AppCard(
                onTap: () => context.push('/video-compressor'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceHighlight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.video_collection_rounded, color: AppColors.primary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.compressVideoAction,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.isArabic
                                ? 'ضغط الفيديوهات الكبيرة واستعادة الجيجابايتات'
                                : 'Save space from bloated high-resolution videos',
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Action 2: Clean Screenshots
              AppCard(
                onTap: () => context.push('/screenshot-cleaner'),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceHighlight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.swipe_rounded, color: AppColors.secondary, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.cleanScreenshotsAction,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            l10n.isArabic
                                ? 'تنظيم ومسح لقطات الشاشة بنظام السحب السريع'
                                : 'Review and purge accumulated screenshots quickly',
                            style: context.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textTertiary)),
          ],
        ),
      ],
    );
  }
}
