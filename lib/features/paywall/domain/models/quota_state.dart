import '../../../../core/constants/app_constants.dart';

/// Monetization and entitlement state model defining feature gating rules.
class QuotaState {
  final bool isProUser;
  final int compressionsUsed;
  final int screenshotsCleaned;
  final bool hasDismissedPaywallOnce;

  const QuotaState({
    this.isProUser = false,
    this.compressionsUsed = 0,
    this.screenshotsCleaned = 0,
    this.hasDismissedPaywallOnce = false,
  });

  /// Maximum allowed free compressions (PRD: 3 lifetime).
  int get maxFreeCompressions => AppConstants.freeTierLifetimeCompressions;

  /// Maximum allowed free screenshots (PRD: 25 screenshots).
  int get maxFreeScreenshots => AppConstants.freeTierMaxScreenshots;

  /// Remaining free compressions.
  int get remainingCompressions => isProUser
      ? 999999
      : (maxFreeCompressions - compressionsUsed).clamp(0, maxFreeCompressions);

  /// Whether the user can initiate a video compression.
  bool get canCompress => isProUser || compressionsUsed < maxFreeCompressions;

  /// Whether the user can clean more screenshots.
  bool get canCleanScreenshots => isProUser || screenshotsCleaned < maxFreeScreenshots;

  /// Feature-specific gates
  bool get canUseHevc4k => isProUser;
  bool get canUseInteractiveSlider => isProUser;
  bool get canUseCustomSizeSlider => isProUser;

  QuotaState copyWith({
    bool? isProUser,
    int? compressionsUsed,
    int? screenshotsCleaned,
    bool? hasDismissedPaywallOnce,
  }) {
    return QuotaState(
      isProUser: isProUser ?? this.isProUser,
      compressionsUsed: compressionsUsed ?? this.compressionsUsed,
      screenshotsCleaned: screenshotsCleaned ?? this.screenshotsCleaned,
      hasDismissedPaywallOnce: hasDismissedPaywallOnce ?? this.hasDismissedPaywallOnce,
    );
  }
}
