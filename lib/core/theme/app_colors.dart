import 'package:flutter/material.dart';

/// OLED Dark-First Color Palette for Smart Storage & Video Compressor.
/// Engineered for high contrast, minimal battery consumption, and a premium utility feel.
abstract class AppColors {
  // Backgrounds (True Pitch Black for OLED)
  static const Color background = Color(0xFF000000);
  static const Color surface = Color(0xFF0D0D11);
  static const Color surfaceElevated = Color(0xFF16161D);
  static const Color surfaceHighlight = Color(0xFF22222B);

  // Borders & Dividers
  static const Color borderSubtle = Color(0x1AFFFFFF); // 10% white
  static const Color borderMedium = Color(0x33FFFFFF); // 20% white
  static const Color divider = Color(0x14FFFFFF);

  // Primary Accent (Emerald Green - symbol of recovered storage & speed)
  static const Color primary = Color(0xFF10B981);
  static const Color primaryHover = Color(0xFF059669);
  static const Color primaryContainer = Color(0xFF064E3B);
  static const Color onPrimary = Color(0xFF000000);

  // Secondary Accent (Electric Cyan - technology & precision)
  static const Color secondary = Color(0xFF38BDF8);
  static const Color secondaryContainer = Color(0xFF0C4A6E);

  // Danger & Delete (Red for deletion swipe & destructive actions)
  static const Color error = Color(0xFFEF4444);
  static const Color errorContainer = Color(0xFF7F1D1D);
  static const Color onError = Color(0xFFFFFFFF);

  // Success (Keep swipe & save success)
  static const Color success = Color(0xFF22C55E);

  // Neutral Typography
  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textTertiary = Color(0xFF64748B);
  static const Color textDisabled = Color(0xFF475569);

  // Special UI Elements
  static const Color goldPro = Color(0xFFF59E0B);
  static const Color goldProContainer = Color(0xFF78350F);
  static const Color overlayDark = Color(0xCC000000);
}
