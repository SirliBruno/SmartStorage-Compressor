import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../services/permissions/permission_service.dart';
import '../controllers/permission_controller.dart';

/// Privacy Manifesto and System Permissions UX Screen.
class PermissionScreen extends ConsumerWidget {
  const PermissionScreen({super.key});

  Future<void> _handleRequestPermission(BuildContext context, WidgetRef ref) async {
    final state = await ref.read(permissionProvider.notifier).requestPermission();
    if (context.mounted) {
      if (state == MediaPermissionState.granted || state == MediaPermissionState.limited) {
        context.go('/scan');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final permState = ref.watch(permissionProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/onboarding'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Privacy Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      l10n.isArabic ? 'خصوصية كاملة 100%' : '100% Privacy Guarantee',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              Text(
                l10n.privacyManifestoTitle,
                style: context.textTheme.displayMedium?.copyWith(fontSize: 26),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.privacyManifestoBody,
                style: context.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Permission Rationale Bento Card
              AppCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceHighlight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.photo_library_rounded,
                        color: AppColors.secondary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.prePermissionTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.prePermissionSubtitle,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Feedback states (Denied, Limited, Restricted)
              if (permState == MediaPermissionState.denied) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.error.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: AppColors.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.permissionDenied,
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.error),
                            ),
                            Text(
                              l10n.permissionSettingsHint,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (permState == MediaPermissionState.limited) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.secondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.permissionLimitedTitle,
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.secondary),
                            ),
                            Text(
                              l10n.permissionLimitedDesc,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (permState == MediaPermissionState.restricted) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.borderMedium),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.block_rounded, color: AppColors.textDisabled),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.permissionRestrictedTitle,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            Text(
                              l10n.permissionRestrictedDesc,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Primary Action Buttons
              if (permState == MediaPermissionState.denied) ...[
                AppButton(
                  text: l10n.openSettings,
                  onPressed: () => ref.read(permissionProvider.notifier).openSettings(),
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: l10n.retryPermission,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => _handleRequestPermission(context, ref),
                ),
              ] else if (permState == MediaPermissionState.limited) ...[
                AppButton(
                  text: l10n.continueButton,
                  onPressed: () => context.go('/scan'),
                ),
                const SizedBox(height: 10),
                AppButton(
                  text: l10n.openSettings,
                  variant: AppButtonVariant.secondary,
                  onPressed: () => ref.read(permissionProvider.notifier).openSettings(),
                ),
              ] else ...[
                AppButton(
                  text: l10n.allowAccessButton,
                  onPressed: () => _handleRequestPermission(context, ref),
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
