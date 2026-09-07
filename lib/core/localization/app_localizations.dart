import 'package:flutter/widgets.dart';

/// Comprehensive Localization class for Smart Storage & Video Compressor.
/// Supports both English (LTR) and Arabic (RTL) locales.
class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    final instance = Localizations.of<AppLocalizations>(context, AppLocalizations);
    return instance ?? AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ar'),
  ];

  bool get isArabic => locale.languageCode == 'ar';

  // Translation dictionaries
  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appName': 'Smart Storage & Compressor',
      'appTagline': '100% On-Device Storage Recovery & Video Compression',
      'onboardingTitle1': 'Free Up Space',
      'onboardingDesc1': 'Quickly identify and compress bloated 4K/1080p videos to free up gigabytes of storage.',
      'onboardingTitle2': 'Compress Privately',
      'onboardingDesc2': 'Your photos and videos never leave your phone. All processing runs offline with zero server uploads.',
      'onboardingTitle3': 'Ready to Clean',
      'onboardingDesc3': 'Let\'s perform a quick local scan of your media library to find recoverable space.',
      'getStarted': 'Get Started',
      'continueButton': 'Continue',
      'skip': 'Skip',
      'startQuickScan': 'Start Quick Scan',
      'privacyManifestoTitle': 'Your Media Stays on Your Device',
      'privacyManifestoBody': 'Smart Storage is built from the ground up to be 100% offline. We do not operate media processing servers, and your videos and screenshots are never uploaded anywhere.',
      'prePermissionTitle': 'Media Access',
      'prePermissionSubtitle': 'To discover large videos and screenshots, the app needs read access to your media library. All operations happen strictly on-device.',
      'allowAccessButton': 'Allow Access',
      'permissionTitle': 'Media Library Access',
      'permissionRationale': 'To discover large videos and organize screenshots, the app requires read access to your photos library. All operations happen strictly on-device without cloud syncing.',
      'grantPermission': 'Allow Media Access',
      'permissionDenied': 'Permission Denied',
      'permissionSettingsHint': 'Please open system settings to grant photo and video access so the app can scan your library.',
      'permissionLimitedTitle': 'Limited Access Granted',
      'permissionLimitedDesc': 'The app can only see the media you explicitly selected. To scan all videos and screenshots, allow full library access in Settings.',
      'permissionRestrictedTitle': 'Media Access Restricted',
      'permissionRestrictedDesc': 'Media access is restricted by device parental controls or corporate device policy.',
      'retryPermission': 'Try Again',
      'openSettings': 'Open Settings',
      'quickScanTitle': 'Analyzing Storage...',
      'quickScanSubtitle': 'Scanning media files locally to find reclaimable storage space.',
      'scanningLibrary': 'Scanning your library...',
      'taskVideos': 'Analyzing videos...',
      'taskScreenshots': 'Identifying screenshots...',
      'taskCalculating': 'Calculating recoverable space...',
      'cancelScan': 'Cancel Scan',
      'scanCancelledTitle': 'Scan Cancelled',
      'scanCancelledDesc': 'Storage scan was stopped before completion.',
      'scanResultHeader': 'Scan Complete',
      'scanResultRecoverable': 'You could free up',
      'scanResultEmptyTitle': 'Your Storage is Lean!',
      'scanResultEmptyDesc': 'No bloated videos or clutter were detected.',
      'continueToPaywall': 'See Optimization Options',
      'dashboardTitle': 'Dashboard',
      'storageOverview': 'Storage Overview',
      'usedStorage': 'Used Space',
      'recoverableSpace': 'Recoverable',
      'largeVideos': 'Large Videos',
      'screenshots': 'Screenshots',
      'compressVideoAction': 'Compress Video',
      'cleanScreenshotsAction': 'Clean Screenshots',
      'noVideosFound': 'No videos found',
      'noScreenshotsFound': 'No screenshots found',
      'emptyStateSubtitle': 'Your storage is lean and optimized.',
      'storageStatusUnavailable': 'Storage capacity reading unavailable',
      'placeholderCompressorTitle': 'Video Compressor',
      'placeholderCompressorDesc': 'Hardware-accelerated compression engine is initializing.',
      'placeholderCleanerTitle': 'Screenshot Cleaner',
      'placeholderCleanerDesc': 'Fast swipe deck organizer is initializing.',
      'videoLibraryTitle': 'Select Video',
      'sortByLargest': 'Sorted by largest first',
      'videoDuration': 'Duration',
      'videoResolution': 'Resolution',
      'videoFps': 'FPS',
      'videoSize': 'Size',
      'presetWhatsApp': 'WhatsApp Fast',
      'presetWhatsAppDesc': 'Auto 720p • Dynamic bitrate for smooth WhatsApp sharing (16/64 MB)',
      'presetEmail': 'Email Ready',
      'presetEmailDesc': 'Target 24.5 MB • Under Gmail & Outlook 25 MB limit',
      'presetMaxSaver': 'Maximum Space Saver',
      'presetMaxSaverDesc': '60–80% size reduction • 1080p HEVC / H.265 high efficiency',
      'presetCustom': 'Custom Target Size',
      'presetCustomDesc': 'Precise MB slider control • Pro Feature',
      'startCompression': 'Start Compression',
      'compressingVideo': 'Compressing Video...',
      'processing': 'Processing',
      'cancel': 'Cancel',
      'aborting': 'Aborting...',
      'comparisonTitle': 'Quality Comparison',
      'original': 'Original',
      'compressed': 'Compressed',
      'saveAsCopy': 'Save as Copy',
      'replaceOriginal': 'Replace Original',
      'replaceWarning': 'This will delete the bloated original from your camera roll after saving the compressed version.',
      'saveSuccess': 'Video saved successfully to your gallery',
      'replaceSuccess': 'Original replaced with compressed copy',
      'screenshotCleanerTitle': 'Screenshot Cleaner',
      'swipeInstructions': 'Swipe Right to Keep • Swipe Left to Delete',
      'keep': 'Keep',
      'delete': 'Delete',
      'potentialSpaceRecovered': 'Potential Space Recovered',
      'reviewMarkedItems': 'Review Marked Items',
      'confirmFinalDeletion': 'Confirm Final Delete',
      'restoreAll': 'Restore All',
      'cleanComplete': 'All Screenshots Reviewed',
      'paywallTitle': 'Upgrade to Pro',
      'paywallSubtitle': 'Unlock unlimited compression and high-efficiency 4K HEVC tools.',
      'featureUnlimitedCompression': 'Unlimited video compressions',
      'feature4kHevc': 'Full 1080p & 4K HEVC hardware acceleration',
      'featureInteractiveSlider': 'Live split-screen quality comparison slider',
      'featureUnlimitedScreenshots': 'Unlimited screenshot batch sorting',
      'featureCustomSize': 'Precise Custom Size slider',
      'featureNoAds': '100% Ad-free experience',
      'annualPlan': 'Annual Plan',
      'annualPrice': '\$19.99 / year',
      'annualTrialNote': '3-day free trial, then \$19.99/year (\$1.66/month)',
      'lifetimePlan': 'Lifetime Access',
      'lifetimePrice': '\$29.99 one-time',
      'lifetimeNote': 'Pay once, keep forever. No recurring charges.',
      'subscribeNow': 'Start Free Trial',
      'buyLifetime': 'Get Lifetime Access',
      'restorePurchases': 'Restore Purchases',
      'termsAndPrivacy': 'Terms of Service & Privacy Policy',
      'exitIntentTitle': 'Wait! Exclusive One-Time Offer',
      'exitIntentDesc': 'Get Lifetime Pro Access with an instant 40% discount.',
      'exitIntentPrice': '\$17.99 one-time',
      'claimDiscount': 'Claim 40% Discount',
      'dismiss': 'No thanks',
    },
    'ar': {
      'appName': 'ضاغط الوسائط ومنظم التخزين',
      'appTagline': 'معالجة محلية 100% على الجهاز لاستعادة مساحة التخزين وضغط الفيديو',
      'onboardingTitle1': 'استعد مساحة التخزين',
      'onboardingDesc1': 'اكتشف واضغط مقاطع الفيديو الضخمة بدقة 4K و 1080p فوراً لتحرير مساحات شاسعة من هاتفك.',
      'onboardingTitle2': 'معالجة خاصة ومحلية 100%',
      'onboardingDesc2': 'صورك وفيديوهاتك لا تغادر هاتفك إطلاقاً. معالجة محلية بالكامل دون رفع سحابي وبأمان تام.',
      'onboardingTitle3': 'جاهز لتنظيف هاتفك',
      'onboardingDesc3': 'دعنا نبدأ بفحص سريع لمكتبة الوسائط محلياً لاكتشاف المساحات المهدورة والقابلة للاستعادة.',
      'getStarted': 'ابدأ الآن',
      'continueButton': 'متابعة',
      'skip': 'تخطي',
      'startQuickScan': 'بدء الفحص السريع',
      'privacyManifestoTitle': 'ملفاتك لا تغادر جهازك أبداً',
      'privacyManifestoBody': 'تم تصميم التطبيق ليعمل أوفلاين 100%. لا نملك أي خوادم لمعالجة الوسائط، ولا يتم رفع صورك أو فيديوهاتك لأي مكان إطلاقاً.',
      'prePermissionTitle': 'الوصول للوسائط',
      'prePermissionSubtitle': 'للبحث عن الفيديوهات الثقيلة وفرز لقطات الشاشة، يحتاج التطبيق إلى إذن قراءة مكتبة الصور والفيديو. تتم كل العمليات داخل جهازك فقط.',
      'allowAccessButton': 'منح الإذن ومتابعة الفحص',
      'permissionTitle': 'صلاحية الوصول لمكتبة الوسائط',
      'permissionRationale': 'لكي يتمكن التطبيق من فحص الفيديوهات الثقيلة وتنظيم لقطات الشاشة، يلزم منح إذن القراءة. جميع العمليات تتم محلياً 100% داخل جهازك دون اتصال سحابي.',
      'grantPermission': 'منح الإذن لمتابعة الفحص',
      'permissionDenied': 'تم رفض الصلاحية',
      'permissionSettingsHint': 'يرجى الانتقال لإعدادات النظام وتفعيل إذن الوصول للصور والفيديو حتى يتمكن التطبيق من فحص وسائطك.',
      'permissionLimitedTitle': 'تم منح وصول محدود',
      'permissionLimitedDesc': 'يمكن للتطبيق رؤية الوسائط التي حددتها فقط. لفحص جميع الفيديوهات، يرجى تفعيل الوصول الكامل من إعدادات النظام.',
      'permissionRestrictedTitle': 'صلاحية الوصول مقيّدة',
      'permissionRestrictedDesc': 'الوصول للوسائط مقيّد بواسطة سياسة الجهاز أو المراقبة الأبوية في نظام التشغيل.',
      'retryPermission': 'إعادة المحاولة',
      'openSettings': 'فتح الإعدادات',
      'quickScanTitle': 'جاري فحص الذاكرة محلياً...',
      'quickScanSubtitle': 'فحص الوسائط للعثور على الملفات التي تستهلك مساحتك.',
      'scanningLibrary': 'جاري فحص مكتبتك...',
      'taskVideos': 'فحص مقاطع الفيديو...',
      'taskScreenshots': 'فرز لقطات الشاشة...',
      'taskCalculating': 'حساب المساحة القابلة للتوفير...',
      'cancelScan': 'إلغاء الفحص',
      'scanCancelledTitle': 'تم إلغاء الفحص',
      'scanCancelledDesc': 'تم إيقاف فحص الوسائط قبل اكتماله.',
      'scanResultHeader': 'اكتمل الفحص بنجاح',
      'scanResultRecoverable': 'يمكنك استعادة',
      'scanResultEmptyTitle': 'مساحة هاتفك نظيفة ومثالية!',
      'scanResultEmptyDesc': 'لم يتم العثور على فيديوهات ثقيلة أو لقطات شاشة متراكمة.',
      'continueToPaywall': 'استعراض خيارات التوفير',
      'dashboardTitle': 'لوحة التحكم',
      'storageOverview': 'نظرة عامة على التخزين',
      'usedStorage': 'المساحة المستخدمة',
      'recoverableSpace': 'مساحة قابلة للتوفير',
      'largeVideos': 'فيديوهات كبيرة',
      'screenshots': 'لقطات الشاشة',
      'compressVideoAction': 'ضغط الفيديو',
      'cleanScreenshotsAction': 'تنظيف لقطات الشاشة',
      'noVideosFound': 'لا توجد فيديوهات بحجم كبير',
      'noScreenshotsFound': 'لا توجد لقطات شاشة مسجلة',
      'emptyStateSubtitle': 'مساحة جهازك نظيفة ومثالية حالياً.',
      'storageStatusUnavailable': 'تعذر قراءة السعة الكلية من النظام',
      'placeholderCompressorTitle': 'ضاغط الفيديو',
      'placeholderCompressorDesc': 'محرك الضغط المعتمد على عتاد الجهاز قيد الإعداد.',
      'placeholderCleanerTitle': 'منظف لقطات الشاشة',
      'placeholderCleanerDesc': 'منظم السحب السريع للقطات الشاشة قيد الإعداد.',
      'videoLibraryTitle': 'اختر الفيديو للضغط',
      'sortByLargest': 'مرتب تنازلياً حسب الأكبر حجماً',
      'videoDuration': 'المدة',
      'videoResolution': 'الدقة',
      'videoFps': 'إطار/ث',
      'videoSize': 'الحجم',
      'presetWhatsApp': 'جاهز للواتساب (WhatsApp Fast)',
      'presetWhatsAppDesc': 'تلقائي 720p • معدل بت ديناميكي للمشاركة السريعة (16 أو 64 ميجابايت)',
      'presetEmail': 'جاهز للبريد (Email Ready)',
      'presetEmailDesc': 'الحد الأقصى 24.5 ميجابايت • لتفادي حاجز الـ 25 ميجابايت لبريد Gmail و Outlook',
      'presetMaxSaver': 'توفير فائق للمساحة (Maximum Space Saver)',
      'presetMaxSaverDesc': 'خفض 60–80% مع الإبقاء على 1080p وترميز HEVC / H.265 عالي الكفاءة',
      'presetCustom': 'حجم مخصص (Custom Target Size)',
      'presetCustomDesc': 'شريط سحب لتحديد الحجم بالميجابايت بدقة • ميزة للمشتركين Pro',
      'startCompression': 'بدء الضغط الآن',
      'compressingVideo': 'جاري ضغط الفيديو...',
      'processing': 'جاري المعالجة',
      'cancel': 'إلغاء العملية',
      'aborting': 'جاري الإلغاء وحذف الملفات المؤقتة...',
      'comparisonTitle': 'مقارنة الجودة الحية',
      'original': 'الأصلي',
      'compressed': 'المضغوط',
      'saveAsCopy': 'حفظ كنسخة جديدة',
      'replaceOriginal': 'استبدال الفيديو الأصلي',
      'replaceWarning': 'سيتم حذف الفيديو الأصلي الضخم من ألبوم الكاميرا بعد حفظ النسخة الجديدة بنجاح.',
      'saveSuccess': 'تم حفظ الفيديو بنجاح في ألبوم الجهاز',
      'replaceSuccess': 'تم استبدال الفيديو الأصلي بالنسخة المضغوطة بأمان',
      'screenshotCleanerTitle': 'منظم ومفرغ لقطات الشاشة',
      'swipeInstructions': 'اسحب لليمين للإبقاء • اسحب لليسار للحذف',
      'keep': 'إبقاء',
      'delete': 'حذف',
      'potentialSpaceRecovered': 'المساحة المقترحة للتحرير',
      'reviewMarkedItems': 'مراجعة العناصر المحددة',
      'confirmFinalDeletion': 'تأكيد الحذف النهائي من النظام',
      'restoreAll': 'استعادة الكل',
      'cleanComplete': 'تمت مراجعة جميع لقطات الشاشة بنجاح',
      'paywallTitle': 'الترقية للنسخة الاحترافية Pro',
      'paywallSubtitle': 'افتح إمكانيات الضغط غير المحدودة وأدوات HEVC فائقة الكفاءة.',
      'featureUnlimitedCompression': 'عدد غير محدود نهائياً من عمليات ضغط الفيديو',
      'feature4kHevc': 'دعم كامل لدقة 1080p و 4K بترميز HEVC المتقدم',
      'featureInteractiveSlider': 'أداة مقارنة الجودة الحية التفاعلية (Split Slider)',
      'featureUnlimitedScreenshots': 'فرز وتنظيف غير محدود لجميع لقطات الشاشة',
      'featureCustomSize': 'التحكم الكامل بالحجم المخصص بالميجابايت',
      'featureNoAds': 'تطبيق خالٍ تماماً من أي إعلانات',
      'annualPlan': 'الاشتراك السنوي (القيمة المثلى)',
      'annualPrice': '74.99 ر.س / سنة (19.99\$)',
      'annualTrialNote': 'تجربة مجانية 3 أيام، ثم 1.66\$ / شهر فقط',
      'lifetimePlan': 'شراء دائم مدى الحياة (Lifetime)',
      'lifetimePrice': '99.99 ر.س لمرة واحدة (29.99\$)',
      'lifetimeNote': 'ادفع مرة واحدة وتخلص من الاشتراكات للأبد',
      'subscribeNow': 'بدء التجربة المجانية',
      'buyLifetime': 'الحصول على النسخة الدائمة',
      'restorePurchases': 'استعادة المشتريات',
      'termsAndPrivacy': 'شروط الخدمة وسياسة الخصوصية',
      'exitIntentTitle': 'انتظر! عرض استثنائي لمرة واحدة فقط',
      'exitIntentDesc': 'احصل على النسخة الدائمة مدى الحياة بخصم 40% حصري وفوري.',
      'exitIntentPrice': '59.99 ر.س فقط (17.99\$)',
      'claimDiscount': 'الحصول على الخصم الآن',
      'dismiss': 'شكراً، لا أريد العرض',
    },
  };

  String _get(String key) {
    final lang = locale.languageCode;
    return _localizedValues[lang]?[key] ?? _localizedValues['en']?[key] ?? key;
  }

  String get appName => _get('appName');
  String get appTagline => _get('appTagline');
  String get onboardingTitle1 => _get('onboardingTitle1');
  String get onboardingDesc1 => _get('onboardingDesc1');
  String get onboardingTitle2 => _get('onboardingTitle2');
  String get onboardingDesc2 => _get('onboardingDesc2');
  String get onboardingTitle3 => _get('onboardingTitle3');
  String get onboardingDesc3 => _get('onboardingDesc3');
  String get getStarted => _get('getStarted');
  String get continueButton => _get('continueButton');
  String get skip => _get('skip');
  String get startQuickScan => _get('startQuickScan');
  String get privacyManifestoTitle => _get('privacyManifestoTitle');
  String get privacyManifestoBody => _get('privacyManifestoBody');
  String get prePermissionTitle => _get('prePermissionTitle');
  String get prePermissionSubtitle => _get('prePermissionSubtitle');
  String get allowAccessButton => _get('allowAccessButton');
  String get permissionTitle => _get('permissionTitle');
  String get permissionRationale => _get('permissionRationale');
  String get grantPermission => _get('grantPermission');
  String get permissionDenied => _get('permissionDenied');
  String get permissionSettingsHint => _get('permissionSettingsHint');
  String get permissionLimitedTitle => _get('permissionLimitedTitle');
  String get permissionLimitedDesc => _get('permissionLimitedDesc');
  String get permissionRestrictedTitle => _get('permissionRestrictedTitle');
  String get permissionRestrictedDesc => _get('permissionRestrictedDesc');
  String get retryPermission => _get('retryPermission');
  String get openSettings => _get('openSettings');
  String get quickScanTitle => _get('quickScanTitle');
  String get quickScanSubtitle => _get('quickScanSubtitle');
  String get scanningLibrary => _get('scanningLibrary');
  String get taskVideos => _get('taskVideos');
  String get taskScreenshots => _get('taskScreenshots');
  String get taskCalculating => _get('taskCalculating');
  String get cancelScan => _get('cancelScan');
  String get scanCancelledTitle => _get('scanCancelledTitle');
  String get scanCancelledDesc => _get('scanCancelledDesc');
  String get scanResultHeader => _get('scanResultHeader');
  String get scanResultRecoverable => _get('scanResultRecoverable');
  String get scanResultEmptyTitle => _get('scanResultEmptyTitle');
  String get scanResultEmptyDesc => _get('scanResultEmptyDesc');
  String get continueToPaywall => _get('continueToPaywall');
  String get dashboardTitle => _get('dashboardTitle');
  String get storageOverview => _get('storageOverview');
  String get usedStorage => _get('usedStorage');
  String get recoverableSpace => _get('recoverableSpace');
  String get largeVideos => _get('largeVideos');
  String get screenshots => _get('screenshots');
  String get compressVideoAction => _get('compressVideoAction');
  String get cleanScreenshotsAction => _get('cleanScreenshotsAction');
  String get noVideosFound => _get('noVideosFound');
  String get noScreenshotsFound => _get('noScreenshotsFound');
  String get emptyStateSubtitle => _get('emptyStateSubtitle');
  String get storageStatusUnavailable => _get('storageStatusUnavailable');
  String get placeholderCompressorTitle => _get('placeholderCompressorTitle');
  String get placeholderCompressorDesc => _get('placeholderCompressorDesc');
  String get placeholderCleanerTitle => _get('placeholderCleanerTitle');
  String get placeholderCleanerDesc => _get('placeholderCleanerDesc');
  String get videoLibraryTitle => _get('videoLibraryTitle');
  String get sortByLargest => _get('sortByLargest');
  String get videoDuration => _get('videoDuration');
  String get videoResolution => _get('videoResolution');
  String get videoFps => _get('videoFps');
  String get videoSize => _get('videoSize');
  String get presetWhatsApp => _get('presetWhatsApp');
  String get presetWhatsAppDesc => _get('presetWhatsAppDesc');
  String get presetEmail => _get('presetEmail');
  String get presetEmailDesc => _get('presetEmailDesc');
  String get presetMaxSaver => _get('presetMaxSaver');
  String get presetMaxSaverDesc => _get('presetMaxSaverDesc');
  String get presetCustom => _get('presetCustom');
  String get presetCustomDesc => _get('presetCustomDesc');
  String get startCompression => _get('startCompression');
  String get compressingVideo => _get('compressingVideo');
  String get processing => _get('processing');
  String get cancel => _get('cancel');
  String get aborting => _get('aborting');
  String get comparisonTitle => _get('comparisonTitle');
  String get original => _get('original');
  String get compressed => _get('compressed');
  String get saveAsCopy => _get('saveAsCopy');
  String get replaceOriginal => _get('replaceOriginal');
  String get replaceWarning => _get('replaceWarning');
  String get saveSuccess => _get('saveSuccess');
  String get replaceSuccess => _get('replaceSuccess');
  String get screenshotCleanerTitle => _get('screenshotCleanerTitle');
  String get swipeInstructions => _get('swipeInstructions');
  String get keep => _get('keep');
  String get delete => _get('delete');
  String get potentialSpaceRecovered => _get('potentialSpaceRecovered');
  String get reviewMarkedItems => _get('reviewMarkedItems');
  String get confirmFinalDeletion => _get('confirmFinalDeletion');
  String get restoreAll => _get('restoreAll');
  String get cleanComplete => _get('cleanComplete');
  String get paywallTitle => _get('paywallTitle');
  String get paywallSubtitle => _get('paywallSubtitle');
  String get featureUnlimitedCompression => _get('featureUnlimitedCompression');
  String get feature4kHevc => _get('feature4kHevc');
  String get featureInteractiveSlider => _get('featureInteractiveSlider');
  String get featureUnlimitedScreenshots => _get('featureUnlimitedScreenshots');
  String get featureCustomSize => _get('featureCustomSize');
  String get featureNoAds => _get('featureNoAds');
  String get annualPlan => _get('annualPlan');
  String get annualPrice => _get('annualPrice');
  String get annualTrialNote => _get('annualTrialNote');
  String get lifetimePlan => _get('lifetimePlan');
  String get lifetimePrice => _get('lifetimePrice');
  String get lifetimeNote => _get('lifetimeNote');
  String get subscribeNow => _get('subscribeNow');
  String get buyLifetime => _get('buyLifetime');
  String get restorePurchases => _get('restorePurchases');
  String get termsAndPrivacy => _get('termsAndPrivacy');
  String get exitIntentTitle => _get('exitIntentTitle');
  String get exitIntentDesc => _get('exitIntentDesc');
  String get exitIntentPrice => _get('exitIntentPrice');
  String get claimDiscount => _get('claimDiscount');
  String get dismiss => _get('dismiss');

  String spaceSaved(int percent) => isArabic ? 'تم توفير $percent%' : 'Saved $percent%';
  String originalSizeLabel(String size) => isArabic ? 'الحجم الأصلي: $size' : 'Original: $size';
  String compressedSizeLabel(String size) => isArabic ? 'الحجم الجديد: $size' : 'New: $size';
  String estimatedTimeRemaining(String eta) =>
      isArabic ? 'الوقت المتبقي التقديري: $eta' : 'Estimated time remaining: $eta';
  String markedCount(int count, String size) =>
      isArabic ? '$count لقطة محددة للحذف ($size)' : '$count screenshots marked ($size)';
  String quickScanResultDesc(String size) =>
      isArabic ? 'تم اكتشاف ما يقارب $size يمكن استعادتها فوراً.' : 'Approximately $size of recoverable storage detected.';
  String scanResultFoundDetails(int videos, int screenshots) =>
      isArabic ? 'عبر $videos فيديو و $screenshots لقطة شاشة' : 'across $videos videos and $screenshots screenshots';
  String storageStatusAvailable(String free, String total) =>
      isArabic ? '$free متاح من أصل $total' : '$free available of $total';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
