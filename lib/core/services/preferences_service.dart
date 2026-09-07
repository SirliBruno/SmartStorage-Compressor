import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Service abstraction for persisting application preferences and flags.
abstract class PreferencesService {
  Future<bool> hasCompletedOnboarding();
  Future<void> setCompletedOnboarding(bool completed);
  Future<void> clearAll();
}

/// SharedPreferences implementation with in-memory fallback for testing.
class SharedPreferencesService implements PreferencesService {
  static const String _keyOnboardingCompleted = 'has_completed_onboarding';

  // Optional in-memory override for test environments
  bool? _inMemoryOnboardingOverride;

  @override
  Future<bool> hasCompletedOnboarding() async {
    if (_inMemoryOnboardingOverride != null) {
      return _inMemoryOnboardingOverride!;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_keyOnboardingCompleted) ?? false;
    } catch (e) {
      AppLogger.warn('Could not read SharedPreferences: $e. Falling back to false.');
      return false;
    }
  }

  @override
  Future<void> setCompletedOnboarding(bool completed) async {
    _inMemoryOnboardingOverride = completed;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyOnboardingCompleted, completed);
      AppLogger.info('Saved hasCompletedOnboarding = $completed');
    } catch (e) {
      AppLogger.warn('Could not write to SharedPreferences: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    _inMemoryOnboardingOverride = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    } catch (e) {
      AppLogger.warn('Could not clear SharedPreferences: $e');
    }
  }
}
