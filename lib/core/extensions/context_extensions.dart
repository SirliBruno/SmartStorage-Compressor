import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

/// Ergonomic BuildContext extensions for UI components.
extension ContextExtensions on BuildContext {
  /// Access current localization delegate.
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  /// Access ThemeData.
  ThemeData get theme => Theme.of(this);

  /// Access ColorScheme.
  ColorScheme get colorScheme => theme.colorScheme;

  /// Access TextTheme.
  TextTheme get textTheme => theme.textTheme;

  /// Check if the current reading direction is RTL.
  bool get isRtl => Directionality.of(this) == TextDirection.rtl;

  /// MediaQuery size dimensions.
  Size get screenSize => MediaQuery.sizeOf(this);
  double get screenWidth => screenSize.width;
  double get screenHeight => screenSize.height;

  /// Padding / safe area insets.
  EdgeInsets get padding => MediaQuery.paddingOf(this);
}

/// Convenience extension on AppLocalizations for locale checks.
extension AppLocalizationsX on AppLocalizations {
  bool get isArabic => localeName.startsWith('ar');
}
