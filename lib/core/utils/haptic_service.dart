import 'package:flutter/services.dart';

/// Haptic feedback abstraction for consistent, subtle micro-interactions.
abstract class HapticService {
  /// Subtle tick for preset switching or slider dragging.
  static Future<void> selectionTick() async {
    await HapticFeedback.selectionClick();
  }

  /// Light feedback for card touches.
  static Future<void> light() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium feedback triggered during Swipe Deck keep/delete actions (PRD Section 2.2).
  static Future<void> medium() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy feedback for final batch deletion confirmations.
  static Future<void> heavy() async {
    await HapticFeedback.heavyImpact();
  }

  /// Vibration pattern for errors or quota limits reached.
  static Future<void> errorAlert() async {
    await HapticFeedback.vibrate();
  }
}
