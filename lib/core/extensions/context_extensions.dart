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

/// Convenience extension on AppLocalizations for locale checks and Sprint 04 engine strings.
extension AppLocalizationsX on AppLocalizations {
  bool get isArabic => localeName.startsWith('ar');

  String get compressionCompleted => isArabic ? 'اكتمل الضغط بنجاح' : 'Compression Completed';
  String get compressionCancelled => isArabic ? 'تم إلغاء الضغط' : 'Compression Cancelled';
  String get compressionFailed => isArabic ? 'فشل الضغط' : 'Compression Failed';
  String get preparingCompression => isArabic ? 'جاري التحضير للضغط...' : 'Preparing compression...';
  String get calculating => isArabic ? 'جاري الحساب...' : 'Calculating...';
  String get compressionCancelledDesc => isArabic ? 'تم إيقاف عملية الضغط وحذف الملف المؤقت بأمان.' : 'The compression process was aborted and temporary files were cleaned up.';
  String get tryAgain => isArabic ? 'إعادة المحاولة' : 'Try Again';
  String get insufficientStorageTitle => isArabic ? 'مساحة التخزين غير كافية' : 'Insufficient Storage';
  String get insufficientStorageMessage => isArabic ? 'لا توجد مساحة كافية على جهازك لضغط هذا الفيديو بأمان.' : 'There is not enough free space on your device to compress this video safely.';
}
