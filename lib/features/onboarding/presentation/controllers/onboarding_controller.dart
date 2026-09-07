import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/preferences_service.dart';

/// State of onboarding completion.
class OnboardingState {
  final bool isCompleted;
  final bool isInitialized;

  const OnboardingState({
    this.isCompleted = false,
    this.isInitialized = false,
  });

  OnboardingState copyWith({
    bool? isCompleted,
    bool? isInitialized,
  }) {
    return OnboardingState(
      isCompleted: isCompleted ?? this.isCompleted,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// StateNotifier handling onboarding completion and persistence.
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  final PreferencesService _preferencesService;

  OnboardingNotifier(this._preferencesService) : super(const OnboardingState()) {
    _loadInitialState();
  }

  Future<void> _loadInitialState() async {
    final completed = await _preferencesService.hasCompletedOnboarding();
    state = OnboardingState(isCompleted: completed, isInitialized: true);
  }

  /// Marks onboarding as completed and persists to local storage.
  Future<void> completeOnboarding() async {
    await _preferencesService.setCompletedOnboarding(true);
    state = state.copyWith(isCompleted: true);
  }

  /// Resets onboarding (e.g. for developer testing or logout).
  Future<void> resetOnboarding() async {
    await _preferencesService.setCompletedOnboarding(false);
    state = state.copyWith(isCompleted: false);
  }
}

/// Global provider for PreferencesService.
final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return SharedPreferencesService();
});

/// Global provider for onboarding completion state.
final onboardingProvider = StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
  final prefs = ref.watch(preferencesServiceProvider);
  return OnboardingNotifier(prefs);
});
