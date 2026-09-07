import 'package:smart_storage_compressor/features/paywall/domain/models/quota_state.dart';
import 'package:test/test.dart';

void main() {
  group('QuotaState & Entitlement Tests (PRD Section 4.1)', () {
    test('Initial free tier user has 3 remaining compressions and can compress', () {
      const state = QuotaState();
      expect(state.isProUser, isFalse);
      expect(state.compressionsUsed, equals(0));
      expect(state.remainingCompressions, equals(3));
      expect(state.canCompress, isTrue);
      expect(state.canCleanScreenshots, isTrue);
      expect(state.canUseHevc4k, isFalse);
      expect(state.canUseInteractiveSlider, isFalse);
      expect(state.canUseCustomSizeSlider, isFalse);
    });

    test('Free tier user reaches limit after 3 compressions', () {
      var state = const QuotaState();
      state = state.copyWith(compressionsUsed: 1);
      expect(state.remainingCompressions, equals(2));
      expect(state.canCompress, isTrue);

      state = state.copyWith(compressionsUsed: 3);
      expect(state.remainingCompressions, equals(0));
      expect(state.canCompress, isFalse);
    });

    test('Free tier user reaches screenshot limit after 25 screenshots', () {
      var state = const QuotaState();
      state = state.copyWith(screenshotsCleaned: 24);
      expect(state.canCleanScreenshots, isTrue);

      state = state.copyWith(screenshotsCleaned: 25);
      expect(state.canCleanScreenshots, isFalse);
    });

    test('Pro user has unlimited access and unlocks all advanced features', () {
      const state = QuotaState(isProUser: true, compressionsUsed: 10, screenshotsCleaned: 100);
      expect(state.canCompress, isTrue);
      expect(state.canCleanScreenshots, isTrue);
      expect(state.canUseHevc4k, isTrue);
      expect(state.canUseInteractiveSlider, isTrue);
      expect(state.canUseCustomSizeSlider, isTrue);
    });
  });
}
