import '../../features/paywall/domain/models/quota_state.dart';

enum SubscriptionPlan { annualTrial, lifetime }

/// Facade abstraction isolating RevenueCat / in-app billing logic from the UI.
abstract class MonetizationService {
  /// Fetches current entitlement and quota state.
  Future<QuotaState> getQuotaState();

  /// Consumes one video compression credit from the free tier.
  Future<void> consumeCompressionCredit();

  /// Records screenshots cleaned against free tier.
  Future<void> recordScreenshotsCleaned(int count);

  /// Purchases a specific plan (Annual with 3-day trial or Lifetime).
  Future<bool> purchasePlan(SubscriptionPlan plan);

  /// Restores previous purchases (StoreKit 2 / Google Play).
  Future<bool> restorePurchases();

  /// Records that the user has seen/dismissed the paywall once (for exit intent triggering).
  Future<void> markPaywallDismissed();
}
