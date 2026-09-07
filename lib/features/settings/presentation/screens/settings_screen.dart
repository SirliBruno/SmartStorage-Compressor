import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/utils/temp_file_manager.dart';
import '../../paywall/presentation/controllers/quota_controller.dart';

/// Settings Screen for App Preferences, Language, Cache, and Subscription.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final quota = ref.watch(quotaProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.isArabic ? 'الإعدادات' : 'Settings'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Status Card
            AppCard(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceHighlight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      quota.isProUser ? Icons.star_rounded : Icons.person_outline_rounded,
                      color: quota.isProUser ? AppColors.goldPro : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quota.isProUser ? 'Pro Member' : 'Free Tier',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          quota.isProUser
                              ? (l10n.isArabic ? 'جميع الميزات مفعلة مدى الحياة' : 'All features unlocked')
                              : (l10n.isArabic
                                  ? '${quota.remainingCompressions} ضغطات متبقية'
                                  : '${quota.remainingCompressions} compressions left'),
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Cache Cleanup Section
            AppCard(
              onTap: () async {
                final count = await TempFileManager().cleanupAllStaleTempFiles();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.isArabic
                            ? 'تم تنظيف الكاش وحذف $count ملفات مؤقتة'
                            : 'Cache cleaned ($count files removed)',
                      ),
                    ),
                  );
                }
              },
              child: Row(
                children: [
                  const Icon(Icons.cleaning_services_rounded, color: AppColors.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.isArabic ? 'تنظيف الملفات المؤقتة' : 'Clean Temporary Cache',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        Text(
                          l10n.isArabic ? 'حذف أي بقايا معالجة سابقة فوراً' : 'Purge stale temporary video buffers',
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Privacy Guarantee
            AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.security_rounded, color: AppColors.primary),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.isArabic ? 'ضمان الخصوصية 100%' : '100% Privacy Guarantee',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.isArabic
                              ? 'جميع العمليات تجري محلياً عبر معالج وعتاد هاتفك، ولا يتم رفع أي وسائط أو صور إطلاقاً.'
                              : 'All compression and scanning runs strictly on-device using local hardware encoders. Zero data upload.',
                          style: context.textTheme.bodySmall,
                        ),
                      ],
                    ),
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
