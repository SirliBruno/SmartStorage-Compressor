import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';

/// Privacy-First Analytics Service.
/// Implements PRD Section 7.1 Schema without sending any photos, videos, or private metadata off-device.
abstract class AnalyticsService {
  void logOnboardingCompleted({required int timeSpentSeconds});

  void logVideoCompressStarted({
    required double originalSizeMb,
    required String presetChosen,
  });

  void logVideoCompressSuccess({
    required double newSizeMb,
    required double savedRatio,
    required int durationMs,
  });

  void logVideoSavedToGallery({required String actionType});

  void logSwipeCleanExecuted({
    required int itemsDeletedCount,
    required double freedMb,
  });

  void logPaywallImpression({required String source});

  void logSubscriptionStarted({
    required String planId,
    required String currency,
  });

  /// Flexible event tracking
  void track(String event, [Map<String, dynamic>? properties]);
}

/// Lightweight privacy-first local analytics implementation.
class LocalPrivacyAnalyticsService implements AnalyticsService {
  @override
  void logOnboardingCompleted({required int timeSpentSeconds}) {
    AppLogger.info('[Analytics] onboarding_completed (time_spent_seconds: $timeSpentSeconds)');
  }

  @override
  void logVideoCompressStarted({
    required double originalSizeMb,
    required String presetChosen,
  }) {
    AppLogger.info(
      '[Analytics] video_compress_started (original_size_mb: $originalSizeMb, preset: $presetChosen)',
    );
  }

  @override
  void logVideoCompressSuccess({
    required double newSizeMb,
    required double savedRatio,
    required int durationMs,
  }) {
    AppLogger.info(
      '[Analytics] video_compress_success (new_size_mb: $newSizeMb, saved_ratio: $savedRatio, duration_ms: $durationMs)',
    );
  }

  @override
  void logVideoSavedToGallery({required String actionType}) {
    AppLogger.info('[Analytics] video_saved_to_gallery (action_type: $actionType)');
  }

  @override
  void logSwipeCleanExecuted({
    required int itemsDeletedCount,
    required double freedMb,
  }) {
    AppLogger.info(
      '[Analytics] swipe_clean_executed (deleted: $itemsDeletedCount, freed_mb: $freedMb)',
    );
  }

  @override
  void logPaywallImpression({required String source}) {
    AppLogger.info('[Analytics] paywall_impression (source: $source)');
  }

  @override
  void logSubscriptionStarted({
    required String planId,
    required String currency,
  }) {
    AppLogger.info(
      '[Analytics] subscription_started (plan_id: $planId, currency: $currency)',
    );
  }

  @override
  void track(String event, [Map<String, dynamic>? properties]) {
    final propsStr = properties != null ? ' $properties' : '';
    AppLogger.info('[Analytics] $event$propsStr');
  }
}

/// Global provider for privacy-first analytics
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return LocalPrivacyAnalyticsService();
});
