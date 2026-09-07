import 'package:smart_storage_compressor/core/services/preferences_service.dart';
import 'package:smart_storage_compressor/features/onboarding/presentation/controllers/onboarding_controller.dart';
import 'package:test/test.dart';

class MockPreferencesService implements PreferencesService {
  bool _completed = false;

  @override
  Future<bool> hasCompletedOnboarding() async => _completed;

  @override
  Future<void> setCompletedOnboarding(bool completed) async {
    _completed = completed;
  }

  @override
  Future<void> clearAll() async {
    _completed = false;
  }
}

void main() {
  group('OnboardingController Tests', () {
    late MockPreferencesService mockPrefs;
    late OnboardingNotifier notifier;

    setUp(() {
      mockPrefs = MockPreferencesService();
      notifier = OnboardingNotifier(mockPrefs);
    });

    test('Initial onboarding state is not completed', () {
      expect(notifier.state.isCompleted, isFalse);
    });

    test('completeOnboarding() sets isCompleted to true and persists', () async {
      await notifier.completeOnboarding();

      expect(notifier.state.isCompleted, isTrue);
      expect(await mockPrefs.hasCompletedOnboarding(), isTrue);
    });

    test('resetOnboarding() reverts state to false', () async {
      await notifier.completeOnboarding();
      expect(notifier.state.isCompleted, isTrue);

      await notifier.resetOnboarding();
      expect(notifier.state.isCompleted, isFalse);
      expect(await mockPrefs.hasCompletedOnboarding(), isFalse);
    });
  });
}
