// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'ضاغط الوسائط ومنظم التخزين';

  @override
  String get appTagline =>
      'معالجة محلية 100% على الجهاز لاستعادة مساحة التخزين وضغط الفيديو';

  @override
  String get onboardingTitle1 => 'استعد مساحة التخزين';

  @override
  String get onboardingDesc1 =>
      'اكتشف واضغط مقاطع الفيديو الضخمة بدقة 4K و 1080p فوراً لتحرير مساحات شاسعة من هاتفك.';

  @override
  String get onboardingTitle2 => 'معالجة خاصة ومحلية 100%';

  @override
  String get onboardingDesc2 =>
      'صورك وفيديوهاتك لا تغادر هاتفك إطلاقاً. معالجة محلية بالكامل دون رفع سحابي وبأمان تام.';

  @override
  String get onboardingTitle3 => 'جاهز لتنظيف هاتفك';

  @override
  String get onboardingDesc3 =>
      'دعنا نبدأ بفحص سريع لمكتبة الوسائط محلياً لاكتشاف المساحات المهدورة والقابلة للاستعادة.';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get continueButton => 'متابعة';

  @override
  String get skip => 'تخطي';

  @override
  String get startQuickScan => 'بدء الفحص السريع';

  @override
  String get privacyManifestoTitle => 'ملفاتك لا تغادر جهازك أبداً';

  @override
  String get privacyManifestoBody =>
      'تم تصميم التطبيق ليعمل أوفلاين 100%. لا نملك أي خوادم لمعالجة الوسائط، ولا يتم رفع صورك أو فيديوهاتك لأي مكان إطلاقاً.';

  @override
  String get prePermissionTitle => 'الوصول للوسائط';

  @override
  String get prePermissionSubtitle =>
      'للبحث عن الفيديوهات الثقيلة وفرز لقطات الشاشة، يحتاج التطبيق إلى إذن قراءة مكتبة الصور والفيديو. تتم كل العمليات داخل جهازك فقط.';

  @override
  String get allowAccessButton => 'منح الإذن ومتابعة الفحص';

  @override
  String get permissionTitle => 'صلاحية الوصول لمكتبة الوسائط';

  @override
  String get permissionRationale =>
      'لكي يتمكن التطبيق من فحص الفيديوهات الثقيلة وتنظيم لقطات الشاشة، يلزم منح إذن القراءة. جميع العمليات تتم محلياً 100% داخل جهازك دون اتصال سحابي.';

  @override
  String get grantPermission => 'منح الإذن لمتابعة الفحص';

  @override
  String get permissionDenied => 'تم رفض الصلاحية';

  @override
  String get permissionSettingsHint =>
      'يرجى الانتقال لإعدادات النظام وتفعيل إذن الوصول للصور والفيديو حتى يتمكن التطبيق من فحص وسائطك.';

  @override
  String get permissionLimitedTitle => 'تم منح وصول محدود';

  @override
  String get permissionLimitedDesc =>
      'يمكن للتطبيق رؤية الوسائط التي حددتها فقط. لفحص جميع الفيديوهات، يرجى تفعيل الوصول الكامل من إعدادات النظام.';

  @override
  String get permissionRestrictedTitle => 'صلاحية الوصول مقيّدة';

  @override
  String get permissionRestrictedDesc =>
      'الوصول للوسائط مقيّد بواسطة سياسة الجهاز أو المراقبة الأبوية في نظام التشغيل.';

  @override
  String get retryPermission => 'إعادة المحاولة';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get quickScanTitle => 'جاري فحص الذاكرة محلياً...';

  @override
  String get quickScanSubtitle =>
      'فحص الوسائط للعثور على الملفات التي تستهلك مساحتك.';

  @override
  String get scanningLibrary => 'جاري فحص مكتبتك...';

  @override
  String get taskVideos => 'فحص مقاطع الفيديو...';

  @override
  String get taskScreenshots => 'فرز لقطات الشاشة...';

  @override
  String get taskCalculating => 'حساب المساحة القابلة للتوفير...';

  @override
  String get cancelScan => 'إلغاء الفحص';

  @override
  String get scanCancelledTitle => 'تم إلغاء الفحص';

  @override
  String get scanCancelledDesc => 'تم إيقاف فحص الوسائط قبل اكتماله.';

  @override
  String get quickScanResultTitle => 'تم العثور على مساحة!';

  @override
  String quickScanResultDesc(Object size) {
    return 'تم اكتشاف ما يقارب $size يمكن استعادتها فوراً.';
  }

  @override
  String get scanResultHeader => 'اكتمل الفحص بنجاح';

  @override
  String get scanResultRecoverable => 'يمكنك استعادة';

  @override
  String scanResultFoundDetails(Object screenshots, Object videos) {
    return 'عبر $videos فيديو و $screenshots لقطة شاشة';
  }

  @override
  String get scanResultEmptyTitle => 'مساحة هاتفك نظيفة ومثالية!';

  @override
  String get scanResultEmptyDesc =>
      'لم يتم العثور على فيديوهات ثقيلة أو لقطات شاشة متراكمة.';

  @override
  String get continueToPaywall => 'استعراض خيارات التوفير';

  @override
  String get dashboardTitle => 'لوحة التحكم';

  @override
  String get storageOverview => 'نظرة عامة على التخزين';

  @override
  String get usedStorage => 'المساحة المستخدمة';

  @override
  String get recoverableSpace => 'مساحة قابلة للتوفير';

  @override
  String get largeVideos => 'فيديوهات كبيرة';

  @override
  String get screenshots => 'لقطات الشاشة';

  @override
  String get compressVideoAction => 'ضغط الفيديو';

  @override
  String get cleanScreenshotsAction => 'تنظيف لقطات الشاشة';

  @override
  String get noVideosFound => 'لا توجد فيديوهات بحجم كبير';

  @override
  String get noScreenshotsFound => 'لا توجد لقطات شاشة مسجلة';

  @override
  String get emptyStateSubtitle => 'مساحة جهازك نظيفة ومثالية حالياً.';

  @override
  String storageStatusAvailable(Object free, Object total) {
    return '$free متاح من أصل $total';
  }

  @override
  String get storageStatusUnavailable => 'تعذر قراءة السعة الكلية من النظام';

  @override
  String get placeholderCompressorTitle => 'ضاغط الفيديو';

  @override
  String get placeholderCompressorDesc =>
      'محرك الضغط المعتمد على عتاد الجهاز قيد الإعداد.';

  @override
  String get placeholderCleanerTitle => 'منظف لقطات الشاشة';

  @override
  String get placeholderCleanerDesc =>
      'منظم السحب السريع للقطات الشاشة قيد الإعداد.';

  @override
  String get videoLibraryTitle => 'اختر الفيديو للضغط';

  @override
  String get sortByLargest => 'مرتب تنازلياً حسب الأكبر حجماً';

  @override
  String get videoDuration => 'المدة';

  @override
  String get videoResolution => 'الدقة';

  @override
  String get videoFps => 'إطار/ث';

  @override
  String get videoSize => 'الحجم';

  @override
  String get presetWhatsApp => 'جاهز للواتساب (WhatsApp Fast)';

  @override
  String get presetWhatsAppDesc =>
      'تلقائي 720p • معدل بت ديناميكي للمشاركة السريعة (16 أو 64 ميجابايت)';

  @override
  String get presetEmail => 'جاهز للبريد (Email Ready)';

  @override
  String get presetEmailDesc =>
      'الحد الأقصى 24.5 ميجابايت • لتفادي حاجز الـ 25 ميجابايت لبريد Gmail و Outlook';

  @override
  String get presetMaxSaver => 'توفير فائق للمساحة (Maximum Space Saver)';

  @override
  String get presetMaxSaverDesc =>
      'خفض 60–80% مع الإبقاء على 1080p وترميز HEVC / H.265 عالي الكفاءة';

  @override
  String get presetCustom => 'حجم مخصص (Custom Target Size)';

  @override
  String get presetCustomDesc =>
      'شريط سحب لتحديد الحجم بالميجابايت بدقة • ميزة للمشتركين Pro';

  @override
  String get startCompression => 'بدء الضغط الآن';

  @override
  String get compressingVideo => 'جاري ضغط الفيديو...';

  @override
  String get processing => 'جاري المعالجة';

  @override
  String estimatedTimeRemaining(Object eta) {
    return 'الوقت المتبقي التقديري: $eta';
  }

  @override
  String get cancel => 'إلغاء العملية';

  @override
  String get aborting => 'جاري الإلغاء وحذف الملفات المؤقتة...';

  @override
  String get comparisonTitle => 'مقارنة الجودة الحية';

  @override
  String get original => 'الأصلي';

  @override
  String get compressed => 'المضغوط';

  @override
  String spaceSaved(Object percent) {
    return 'تم توفير $percent%';
  }

  @override
  String originalSizeLabel(Object size) {
    return 'الحجم الأصلي: $size';
  }

  @override
  String compressedSizeLabel(Object size) {
    return 'الحجم الجديد: $size';
  }

  @override
  String get saveAsCopy => 'حفظ كنسخة جديدة';

  @override
  String get replaceOriginal => 'استبدال الفيديو الأصلي';

  @override
  String get replaceWarning =>
      'سيتم حذف الفيديو الأصلي الضخم من ألبوم الكاميرا بعد حفظ النسخة الجديدة بنجاح.';

  @override
  String get saveSuccess => 'تم حفظ الفيديو بنجاح في ألبوم الجهاز';

  @override
  String get replaceSuccess =>
      'تم استبدال الفيديو الأصلي بالنسخة المضغوطة بأمان';

  @override
  String get screenshotCleanerTitle => 'منظم ومفرغ لقطات الشاشة';

  @override
  String get swipeInstructions => 'اسحب لليمين للإبقاء • اسحب لليسار للحذف';

  @override
  String get keep => 'إبقاء';

  @override
  String get delete => 'حذف';

  @override
  String get potentialSpaceRecovered => 'المساحة المقترحة للتحرير';

  @override
  String markedCount(Object count, Object size) {
    return '$count لقطة محددة للحذف ($size)';
  }

  @override
  String get reviewMarkedItems => 'مراجعة العناصر المحددة';

  @override
  String get confirmFinalDeletion => 'تأكيد الحذف النهائي من النظام';

  @override
  String get restoreAll => 'استعادة الكل';

  @override
  String get cleanComplete => 'تمت مراجعة جميع لقطات الشاشة بنجاح';

  @override
  String get paywallTitle => 'الترقية للنسخة الاحترافية Pro';

  @override
  String get paywallSubtitle =>
      'افتح إمكانيات الضغط غير المحدودة وأدوات HEVC فائقة الكفاءة.';

  @override
  String get featureUnlimitedCompression =>
      'عدد غير محدود نهائياً من عمليات ضغط الفيديو';

  @override
  String get feature4kHevc => 'دعم كامل لدقة 1080p و 4K بترميز HEVC المتقدم';

  @override
  String get featureInteractiveSlider =>
      'أداة مقارنة الجودة الحية التفاعلية (Split Slider)';

  @override
  String get featureUnlimitedScreenshots =>
      'فرز وتنظيف غير محدود لجميع لقطات الشاشة';

  @override
  String get featureCustomSize => 'التحكم الكامل بالحجم المخصص بالميجابايت';

  @override
  String get featureNoAds => 'تطبيق خالٍ تماماً من أي إعلانات';

  @override
  String get annualPlan => 'الاشتراك السنوي (القيمة المثلى)';

  @override
  String get annualPrice => '74.99 ر.س / سنة (19.99\$)';

  @override
  String get annualTrialNote => 'تجربة مجانية 3 أيام، ثم 1.66\$ / شهر فقط';

  @override
  String get lifetimePlan => 'شراء دائم مدى الحياة (Lifetime)';

  @override
  String get lifetimePrice => '99.99 ر.س لمرة واحدة (29.99\$)';

  @override
  String get lifetimeNote => 'ادفع مرة واحدة وتخلص من الاشتراكات للأبد';

  @override
  String get subscribeNow => 'بدء التجربة المجانية';

  @override
  String get buyLifetime => 'الحصول على النسخة الدائمة';

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String get termsAndPrivacy => 'شروط الخدمة وسياسة الخصوصية';

  @override
  String get exitIntentTitle => 'انتظر! عرض استثنائي لمرة واحدة فقط';

  @override
  String get exitIntentDesc =>
      'احصل على النسخة الدائمة مدى الحياة بخصم 40% حصري وفوري.';

  @override
  String get exitIntentPrice => '59.99 ر.س فقط (17.99\$)';

  @override
  String get claimDiscount => 'الحصول على الخصم الآن';

  @override
  String get dismiss => 'شكراً، لا أريد العرض';
}
