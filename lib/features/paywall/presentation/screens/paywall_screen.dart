import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/extensions/context_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../controllers/quota_controller.dart';
import '../../../onboarding/presentation/controllers/onboarding_controller.dart';

/// Monetization Paywall Screen displaying Annual with Trial & Lifetime packages.
class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  int _selectedPlanIndex = 0; // 0 = Annual, 1 = Lifetime

  void _proceedToDashboard() {
    ref.read(onboardingProvider.notifier).completeOnboarding();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/dashboard');
    }
  }

  void _onClose() {
    final quota = ref.read(quotaProvider);
    if (!quota.hasDismissedPaywallOnce && !quota.isProUser) {
      ref.read(quotaProvider.notifier).markPaywallDismissed();
      _showExitIntentDialog();
    } else {
      _proceedToDashboard();
    }
  }

  void _showExitIntentDialog() {
    final l10n = context.l10n;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        title: Row(
          children: [
            const Icon(Icons.local_offer_rounded, color: AppColors.goldPro),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.exitIntentTitle,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.exitIntentDesc),
            const SizedBox(height: 12),
            Text(
              l10n.exitIntentPrice,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              _proceedToDashboard();
            },
            child: Text(l10n.dismiss),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(quotaProvider.notifier).upgradeToPro();
              Navigator.of(dialogCtx).pop();
              _proceedToDashboard();
            },
            child: Text(l10n.claimDiscount),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final features = [
      (Icons.all_inclusive_rounded, l10n.featureUnlimitedCompression),
      (Icons.hd_rounded, l10n.feature4kHevc),
      (Icons.compare_rounded, l10n.featureInteractiveSlider),
      (Icons.photo_library_rounded, l10n.featureUnlimitedScreenshots),
      (Icons.tune_rounded, l10n.featureCustomSize),
      (Icons.block_rounded, l10n.featureNoAds),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: _onClose,
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text(l10n.restorePurchases),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.paywallTitle,
                style: context.textTheme.displayMedium?.copyWith(fontSize: 28),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.paywallSubtitle,
                style: context.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),

              // Feature list
              AppCard(
                child: Column(
                  children: features.map((f) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(f.$1, size: 20, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              f.$2,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Plan Cards
              // 1. Annual Plan (Best Value with Trial)
              AppCard(
                onTap: () => setState(() => _selectedPlanIndex = 0),
                borderSide: BorderSide(
                  color: _selectedPlanIndex == 0 ? AppColors.primary : AppColors.borderSubtle,
                  width: _selectedPlanIndex == 0 ? 2 : 1,
                ),
                child: Row(
                  children: [
                    Radio<int>(
                      value: 0,
                      groupValue: _selectedPlanIndex,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _selectedPlanIndex = val!),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(l10n.annualPlan, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  l10n.isArabic ? 'الأفضل قيمة' : 'Best Value',
                                  style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w700),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(l10n.annualTrialNote, style: context.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Text(
                      l10n.annualPrice,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. Lifetime Plan
              AppCard(
                onTap: () => setState(() => _selectedPlanIndex = 1),
                borderSide: BorderSide(
                  color: _selectedPlanIndex == 1 ? AppColors.primary : AppColors.borderSubtle,
                  width: _selectedPlanIndex == 1 ? 2 : 1,
                ),
                child: Row(
                  children: [
                    Radio<int>(
                      value: 1,
                      groupValue: _selectedPlanIndex,
                      activeColor: AppColors.primary,
                      onChanged: (val) => setState(() => _selectedPlanIndex = val!),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.lifetimePlan, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 2),
                          Text(l10n.lifetimeNote, style: context.textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Text(
                      l10n.lifetimePrice,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              AppButton(
                text: _selectedPlanIndex == 0 ? l10n.subscribeNow : l10n.buyLifetime,
                onPressed: () {
                  ref.read(quotaProvider.notifier).upgradeToPro();
                  _proceedToDashboard();
                },
              ),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  l10n.termsAndPrivacy,
                  style: context.textTheme.bodySmall?.copyWith(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
