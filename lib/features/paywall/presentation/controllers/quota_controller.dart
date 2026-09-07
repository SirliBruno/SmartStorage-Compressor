import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/quota_state.dart';

/// Riverpod StateNotifier managing free quota vs Pro entitlement.
class QuotaNotifier extends StateNotifier<QuotaState> {
  QuotaNotifier() : super(const QuotaState());

  void consumeCompression() {
    if (!state.isProUser) {
      state = state.copyWith(compressionsUsed: state.compressionsUsed + 1);
    }
  }

  void recordScreenshotsCleaned(int count) {
    if (!state.isProUser) {
      state = state.copyWith(screenshotsCleaned: state.screenshotsCleaned + count);
    }
  }

  void upgradeToPro() {
    state = state.copyWith(isProUser: true);
  }

  void markPaywallDismissed() {
    state = state.copyWith(hasDismissedPaywallOnce: true);
  }

  void resetFreeQuotaForTesting() {
    state = const QuotaState();
  }
}

/// Global provider for QuotaState.
final quotaProvider = StateNotifierProvider<QuotaNotifier, QuotaState>((ref) {
  return QuotaNotifier();
});
