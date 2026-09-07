import 'package:flutter/material.dart';
import 'app_exception.dart';
import '../extensions/context_extensions.dart';
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

    final isArabic = l10n?.isArabic ?? false;

    if (error is PermissionDeniedException) {
      return UserFriendlyError(
        title: l10n?.permissionDenied ?? 'Permission Denied',
        message: l10n?.permissionSettingsHint ?? 'Please grant access in Settings.',
        actionLabel: l10n?.openSettings ?? 'Open Settings',
        onAction: onOpenSettings,
      );
    }

    if (error is InsufficientStorageException) {
      return UserFriendlyError(
        title: isArabic ? 'المساحة غير كافية' : 'Insufficient Storage',
        message: isArabic
            ? 'يرجى تحرير 200 ميجابايت على الأقل لمتابعة معالجة الفيديو.'
            : 'Please free up at least 200 MB of space to complete video compression.',
      );
    }

    if (error is QuotaExceededException) {
      return UserFriendlyError(
        title: isArabic ? 'تم استهلاك الحد المجاني' : 'Free Quota Reached',
        message: isArabic
            ? 'لقد استهلكت جميع عمليات الضغط المجانية. قم بالترقية لمتابعة الضغط بدون قيود.'
            : 'You have reached the limit of 3 free video compressions. Upgrade to Pro for unlimited access.',
        actionLabel: isArabic ? 'ترقية إلى Pro' : 'Upgrade to Pro',
        onAction: onUpgrade,
      );
    }

    if (error is UnsupportedCodecException) {
      return UserFriendlyError(
        title: isArabic ? 'صيغة غير مدعومة' : 'Unsupported Format',
        message: isArabic
            ? 'لا يمكن لعتاد هذا الجهاز معالجة ترميز هذا الفيديو.'
            : 'This video codec cannot be hardware-decoded on this device.',
      );
    }

    if (error is OperationCancelledException) {
      return UserFriendlyError(
        title: isArabic ? 'تم الإلغاء' : 'Cancelled',
        message: isArabic
            ? 'تم إيقاف المعالجة وحذف أي ملفات مؤقتة بنجاح.'
            : 'Processing was aborted and all temporary files were purged.',
      );
    }

    // Generic fallback
    return UserFriendlyError(
      title: isArabic ? 'حدث خطأ غير متوقع' : 'Unexpected Error',
      message: error.toString(),
      actionLabel: onRetry != null ? (isArabic ? 'إعادة المحاولة' : 'Retry') : null,
      onAction: onRetry,
    );
  }
}
