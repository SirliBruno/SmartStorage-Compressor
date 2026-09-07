import 'package:flutter/material.dart';
import 'app_exception.dart';
import '../localization/app_localizations.dart';

/// Presentation-level error model with recovery recommendation.
class UserFriendlyError {
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const UserFriendlyError({
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });
}

/// Central Error Handler to transform low-level exceptions into actionable user errors.
abstract class ErrorHandler {
  static UserFriendlyError resolve(
    BuildContext context,
    Object error, {
    VoidCallback? onRetry,
    VoidCallback? onOpenSettings,
    VoidCallback? onUpgrade,
  }) {
    final l10n = AppLocalizations.of(context);

    if (error is PermissionDeniedException) {
      return UserFriendlyError(
        title: l10n.permissionDenied,
        message: l10n.permissionSettingsHint,
        actionLabel: l10n.openSettings,
        onAction: onOpenSettings,
      );
    }

    if (error is InsufficientStorageException) {
      return UserFriendlyError(
        title: l10n.isArabic ? 'المساحة غير كافية' : 'Insufficient Storage',
        message: l10n.isArabic
            ? 'يرجى تحرير 200 ميجابايت على الأقل لمتابعة معالجة الفيديو.'
            : 'Please free up at least 200 MB of space to complete video compression.',
        actionLabel: l10n.cleanScreenshotsAction,
      );
    }

    if (error is UnsupportedCodecException) {
      return UserFriendlyError(
        title: l10n.isArabic ? 'صيغة غير مدعومة' : 'Unsupported Format',
        message: l10n.isArabic
            ? 'يتعذر على عتاد الجهاز معالجة هذا الترميز. يرجى تجربة فيديو آخر.'
            : 'The device hardware cannot encode this specific video format.',
      );
    }

    if (error is QuotaExceededException) {
      return UserFriendlyError(
        title: l10n.isArabic ? 'انتهت الحصة المجانية' : 'Free Limit Reached',
        message: l10n.isArabic
            ? 'لقد استهلكت الـ 3 ضغطات المجانية. قم بالترقية للحصول على ضغط غير محدود.'
            : 'You have used your 3 free compressions. Upgrade to Pro for unlimited access.',
        actionLabel: l10n.isArabic ? 'ترقية الآن' : 'Upgrade Now',
        onAction: onUpgrade,
      );
    }

    if (error is OperationCancelledException) {
      return UserFriendlyError(
        title: l10n.isArabic ? 'تم الإلغاء' : 'Cancelled',
        message: l10n.isArabic
            ? 'تم إيقاف المعالجة وحذف أي ملفات مؤقتة بنجاح.'
            : 'Processing was aborted and all temporary files were purged.',
      );
    }

    // Generic fallback
    return UserFriendlyError(
      title: l10n.isArabic ? 'حدث خطأ غير متوقع' : 'Unexpected Error',
      message: error.toString(),
      actionLabel: onRetry != null ? (l10n.isArabic ? 'إعادة المحاولة' : 'Retry') : null,
      onAction: onRetry,
    );
  }
}
