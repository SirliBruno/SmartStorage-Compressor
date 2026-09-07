import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Smart Storage & Compressor'**
  String get appName;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'100% On-Device Storage Recovery & Video Compression'**
  String get appTagline;

  /// No description provided for @onboardingTitle1.
  ///
  /// In en, this message translates to:
  /// **'Free Up Space'**
  String get onboardingTitle1;

  /// No description provided for @onboardingDesc1.
  ///
  /// In en, this message translates to:
  /// **'Quickly identify and compress bloated 4K/1080p videos to free up gigabytes of storage.'**
  String get onboardingDesc1;

  /// No description provided for @onboardingTitle2.
  ///
  /// In en, this message translates to:
  /// **'Compress Privately'**
  String get onboardingTitle2;

  /// No description provided for @onboardingDesc2.
  ///
  /// In en, this message translates to:
  /// **'Your photos and videos never leave your phone. All processing runs offline with zero server uploads.'**
  String get onboardingDesc2;

  /// No description provided for @onboardingTitle3.
  ///
  /// In en, this message translates to:
  /// **'Ready to Clean'**
  String get onboardingTitle3;

  /// No description provided for @onboardingDesc3.
  ///
  /// In en, this message translates to:
  /// **'Let\'s perform a quick local scan of your media library to find recoverable space.'**
  String get onboardingDesc3;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get getStarted;

  /// No description provided for @continueButton.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueButton;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @startQuickScan.
  ///
  /// In en, this message translates to:
  /// **'Start Quick Scan'**
  String get startQuickScan;

  /// No description provided for @privacyManifestoTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Media Stays on Your Device'**
  String get privacyManifestoTitle;

  /// No description provided for @privacyManifestoBody.
  ///
  /// In en, this message translates to:
  /// **'Smart Storage is built from the ground up to be 100% offline. We do not operate media processing servers, and your videos and screenshots are never uploaded anywhere.'**
  String get privacyManifestoBody;

  /// No description provided for @prePermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Media Access'**
  String get prePermissionTitle;

  /// No description provided for @prePermissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'To discover large videos and screenshots, the app needs read access to your media library. All operations happen strictly on-device.'**
  String get prePermissionSubtitle;

  /// No description provided for @allowAccessButton.
  ///
  /// In en, this message translates to:
  /// **'Allow Access'**
  String get allowAccessButton;

  /// No description provided for @permissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Media Library Access'**
  String get permissionTitle;

  /// No description provided for @permissionRationale.
  ///
  /// In en, this message translates to:
  /// **'To discover large videos and organize screenshots, the app requires read access to your photos library. All operations happen strictly on-device without cloud syncing.'**
  String get permissionRationale;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Allow Media Access'**
  String get grantPermission;

  /// No description provided for @permissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Permission Denied'**
  String get permissionDenied;

  /// No description provided for @permissionSettingsHint.
  ///
  /// In en, this message translates to:
  /// **'Please open system settings to grant photo and video access so the app can scan your library.'**
  String get permissionSettingsHint;

  /// No description provided for @permissionLimitedTitle.
  ///
  /// In en, this message translates to:
  /// **'Limited Access Granted'**
  String get permissionLimitedTitle;

  /// No description provided for @permissionLimitedDesc.
  ///
  /// In en, this message translates to:
  /// **'The app can only see the media you explicitly selected. To scan all videos and screenshots, allow full library access in Settings.'**
  String get permissionLimitedDesc;

  /// No description provided for @permissionRestrictedTitle.
  ///
  /// In en, this message translates to:
  /// **'Media Access Restricted'**
  String get permissionRestrictedTitle;

  /// No description provided for @permissionRestrictedDesc.
  ///
  /// In en, this message translates to:
  /// **'Media access is restricted by device parental controls or corporate device policy.'**
  String get permissionRestrictedDesc;

  /// No description provided for @retryPermission.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get retryPermission;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @quickScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Analyzing Storage...'**
  String get quickScanTitle;

  /// No description provided for @quickScanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Scanning media files locally to find reclaimable storage space.'**
  String get quickScanSubtitle;

  /// No description provided for @scanningLibrary.
  ///
  /// In en, this message translates to:
  /// **'Scanning your library...'**
  String get scanningLibrary;

  /// No description provided for @taskVideos.
  ///
  /// In en, this message translates to:
  /// **'Analyzing videos...'**
  String get taskVideos;

  /// No description provided for @taskScreenshots.
  ///
  /// In en, this message translates to:
  /// **'Identifying screenshots...'**
  String get taskScreenshots;

  /// No description provided for @taskCalculating.
  ///
  /// In en, this message translates to:
  /// **'Calculating recoverable space...'**
  String get taskCalculating;

  /// No description provided for @cancelScan.
  ///
  /// In en, this message translates to:
  /// **'Cancel Scan'**
  String get cancelScan;

  /// No description provided for @scanCancelledTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan Cancelled'**
  String get scanCancelledTitle;

  /// No description provided for @scanCancelledDesc.
  ///
  /// In en, this message translates to:
  /// **'Storage scan was stopped before completion.'**
  String get scanCancelledDesc;

  /// No description provided for @quickScanResultTitle.
  ///
  /// In en, this message translates to:
  /// **'Space Found!'**
  String get quickScanResultTitle;

  /// No description provided for @quickScanResultDesc.
  ///
  /// In en, this message translates to:
  /// **'Approximately {size} of recoverable storage detected.'**
  String quickScanResultDesc(Object size);

  /// No description provided for @scanResultHeader.
  ///
  /// In en, this message translates to:
  /// **'Scan Complete'**
  String get scanResultHeader;

  /// No description provided for @scanResultRecoverable.
  ///
  /// In en, this message translates to:
  /// **'You could free up'**
  String get scanResultRecoverable;

  /// No description provided for @scanResultFoundDetails.
  ///
  /// In en, this message translates to:
  /// **'across {videos} videos and {screenshots} screenshots'**
  String scanResultFoundDetails(Object screenshots, Object videos);

  /// No description provided for @scanResultEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Your Storage is Lean!'**
  String get scanResultEmptyTitle;

  /// No description provided for @scanResultEmptyDesc.
  ///
  /// In en, this message translates to:
  /// **'No bloated videos or clutter were detected.'**
  String get scanResultEmptyDesc;

  /// No description provided for @continueToPaywall.
  ///
  /// In en, this message translates to:
  /// **'See Optimization Options'**
  String get continueToPaywall;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @storageOverview.
  ///
  /// In en, this message translates to:
  /// **'Storage Overview'**
  String get storageOverview;

  /// No description provided for @usedStorage.
  ///
  /// In en, this message translates to:
  /// **'Used Space'**
  String get usedStorage;

  /// No description provided for @recoverableSpace.
  ///
  /// In en, this message translates to:
  /// **'Recoverable'**
  String get recoverableSpace;

  /// No description provided for @largeVideos.
  ///
  /// In en, this message translates to:
  /// **'Large Videos'**
  String get largeVideos;

  /// No description provided for @screenshots.
  ///
  /// In en, this message translates to:
  /// **'Screenshots'**
  String get screenshots;

  /// No description provided for @compressVideoAction.
  ///
  /// In en, this message translates to:
  /// **'Compress Video'**
  String get compressVideoAction;

  /// No description provided for @cleanScreenshotsAction.
  ///
  /// In en, this message translates to:
  /// **'Clean Screenshots'**
  String get cleanScreenshotsAction;

  /// No description provided for @noVideosFound.
  ///
  /// In en, this message translates to:
  /// **'No videos found'**
  String get noVideosFound;

  /// No description provided for @noScreenshotsFound.
  ///
  /// In en, this message translates to:
  /// **'No screenshots found'**
  String get noScreenshotsFound;

  /// No description provided for @emptyStateSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Your storage is lean and optimized.'**
  String get emptyStateSubtitle;

  /// No description provided for @storageStatusAvailable.
  ///
  /// In en, this message translates to:
  /// **'{free} available of {total}'**
  String storageStatusAvailable(Object free, Object total);

  /// No description provided for @storageStatusUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Storage capacity reading unavailable'**
  String get storageStatusUnavailable;

  /// No description provided for @placeholderCompressorTitle.
  ///
  /// In en, this message translates to:
  /// **'Video Compressor'**
  String get placeholderCompressorTitle;

  /// No description provided for @placeholderCompressorDesc.
  ///
  /// In en, this message translates to:
  /// **'Hardware-accelerated compression engine is initializing.'**
  String get placeholderCompressorDesc;

  /// No description provided for @placeholderCleanerTitle.
  ///
  /// In en, this message translates to:
  /// **'Screenshot Cleaner'**
  String get placeholderCleanerTitle;

  /// No description provided for @placeholderCleanerDesc.
  ///
  /// In en, this message translates to:
  /// **'Fast swipe deck organizer is initializing.'**
  String get placeholderCleanerDesc;

  /// No description provided for @videoLibraryTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Video'**
  String get videoLibraryTitle;

  /// No description provided for @sortByLargest.
  ///
  /// In en, this message translates to:
  /// **'Sorted by largest first'**
  String get sortByLargest;

  /// No description provided for @videoDuration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get videoDuration;

  /// No description provided for @videoResolution.
  ///
  /// In en, this message translates to:
  /// **'Resolution'**
  String get videoResolution;

  /// No description provided for @videoFps.
  ///
  /// In en, this message translates to:
  /// **'FPS'**
  String get videoFps;

  /// No description provided for @videoSize.
  ///
  /// In en, this message translates to:
  /// **'Size'**
  String get videoSize;

  /// No description provided for @presetWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp Fast'**
  String get presetWhatsApp;

  /// No description provided for @presetWhatsAppDesc.
  ///
  /// In en, this message translates to:
  /// **'Auto 720p • Dynamic bitrate for smooth WhatsApp sharing (16/64 MB)'**
  String get presetWhatsAppDesc;

  /// No description provided for @presetEmail.
  ///
  /// In en, this message translates to:
  /// **'Email Ready'**
  String get presetEmail;

  /// No description provided for @presetEmailDesc.
  ///
  /// In en, this message translates to:
  /// **'Target 24.5 MB • Under Gmail & Outlook 25 MB limit'**
  String get presetEmailDesc;

  /// No description provided for @presetMaxSaver.
  ///
  /// In en, this message translates to:
  /// **'Maximum Space Saver'**
  String get presetMaxSaver;

  /// No description provided for @presetMaxSaverDesc.
  ///
  /// In en, this message translates to:
  /// **'60–80% size reduction • 1080p HEVC / H.265 high efficiency'**
  String get presetMaxSaverDesc;

  /// No description provided for @presetCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom Target Size'**
  String get presetCustom;

  /// No description provided for @presetCustomDesc.
  ///
  /// In en, this message translates to:
  /// **'Precise MB slider control • Pro Feature'**
  String get presetCustomDesc;

  /// No description provided for @startCompression.
  ///
  /// In en, this message translates to:
  /// **'Start Compression'**
  String get startCompression;

  /// No description provided for @compressingVideo.
  ///
  /// In en, this message translates to:
  /// **'Compressing Video...'**
  String get compressingVideo;

  /// No description provided for @processing.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get processing;

  /// No description provided for @estimatedTimeRemaining.
  ///
  /// In en, this message translates to:
  /// **'Estimated time remaining: {eta}'**
  String estimatedTimeRemaining(Object eta);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @aborting.
  ///
  /// In en, this message translates to:
  /// **'Aborting...'**
  String get aborting;

  /// No description provided for @comparisonTitle.
  ///
  /// In en, this message translates to:
  /// **'Quality Comparison'**
  String get comparisonTitle;

  /// No description provided for @original.
  ///
  /// In en, this message translates to:
  /// **'Original'**
  String get original;

  /// No description provided for @compressed.
  ///
  /// In en, this message translates to:
  /// **'Compressed'**
  String get compressed;

  /// No description provided for @spaceSaved.
  ///
  /// In en, this message translates to:
  /// **'Saved {percent}%'**
  String spaceSaved(Object percent);

  /// No description provided for @originalSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'Original: {size}'**
  String originalSizeLabel(Object size);

  /// No description provided for @compressedSizeLabel.
  ///
  /// In en, this message translates to:
  /// **'New: {size}'**
  String compressedSizeLabel(Object size);

  /// No description provided for @saveAsCopy.
  ///
  /// In en, this message translates to:
  /// **'Save as Copy'**
  String get saveAsCopy;

  /// No description provided for @replaceOriginal.
  ///
  /// In en, this message translates to:
  /// **'Replace Original'**
  String get replaceOriginal;

  /// No description provided for @replaceWarning.
  ///
  /// In en, this message translates to:
  /// **'This will delete the bloated original from your camera roll after saving the compressed version.'**
  String get replaceWarning;

  /// No description provided for @saveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Video saved successfully to your gallery'**
  String get saveSuccess;

  /// No description provided for @replaceSuccess.
  ///
  /// In en, this message translates to:
  /// **'Original replaced with compressed copy'**
  String get replaceSuccess;

  /// No description provided for @screenshotCleanerTitle.
  ///
  /// In en, this message translates to:
  /// **'Screenshot Cleaner'**
  String get screenshotCleanerTitle;

  /// No description provided for @swipeInstructions.
  ///
  /// In en, this message translates to:
  /// **'Swipe Right to Keep • Swipe Left to Delete'**
  String get swipeInstructions;

  /// No description provided for @keep.
  ///
  /// In en, this message translates to:
  /// **'Keep'**
  String get keep;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @potentialSpaceRecovered.
  ///
  /// In en, this message translates to:
  /// **'Potential Space Recovered'**
  String get potentialSpaceRecovered;

  /// No description provided for @markedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} screenshots marked ({size})'**
  String markedCount(Object count, Object size);

  /// No description provided for @reviewMarkedItems.
  ///
  /// In en, this message translates to:
  /// **'Review Marked Items'**
  String get reviewMarkedItems;

  /// No description provided for @confirmFinalDeletion.
  ///
  /// In en, this message translates to:
  /// **'Confirm Final Delete'**
  String get confirmFinalDeletion;

  /// No description provided for @restoreAll.
  ///
  /// In en, this message translates to:
  /// **'Restore All'**
  String get restoreAll;

  /// No description provided for @cleanComplete.
  ///
  /// In en, this message translates to:
  /// **'All Screenshots Reviewed'**
  String get cleanComplete;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Upgrade to Pro'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Unlock unlimited compression and high-efficiency 4K HEVC tools.'**
  String get paywallSubtitle;

  /// No description provided for @featureUnlimitedCompression.
  ///
  /// In en, this message translates to:
  /// **'Unlimited video compressions'**
  String get featureUnlimitedCompression;

  /// No description provided for @feature4kHevc.
  ///
  /// In en, this message translates to:
  /// **'Full 1080p & 4K HEVC hardware acceleration'**
  String get feature4kHevc;

  /// No description provided for @featureInteractiveSlider.
  ///
  /// In en, this message translates to:
  /// **'Live split-screen quality comparison slider'**
  String get featureInteractiveSlider;

  /// No description provided for @featureUnlimitedScreenshots.
  ///
  /// In en, this message translates to:
  /// **'Unlimited screenshot batch sorting'**
  String get featureUnlimitedScreenshots;

  /// No description provided for @featureCustomSize.
  ///
  /// In en, this message translates to:
  /// **'Precise Custom Size slider'**
  String get featureCustomSize;

  /// No description provided for @featureNoAds.
  ///
  /// In en, this message translates to:
  /// **'100% Ad-free experience'**
  String get featureNoAds;

  /// No description provided for @annualPlan.
  ///
  /// In en, this message translates to:
  /// **'Annual Plan'**
  String get annualPlan;

  /// No description provided for @annualPrice.
  ///
  /// In en, this message translates to:
  /// **'\$19.99 / year'**
  String get annualPrice;

  /// No description provided for @annualTrialNote.
  ///
  /// In en, this message translates to:
  /// **'3-day free trial, then \$19.99/year (\$1.66/month)'**
  String get annualTrialNote;

  /// No description provided for @lifetimePlan.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Access'**
  String get lifetimePlan;

  /// No description provided for @lifetimePrice.
  ///
  /// In en, this message translates to:
  /// **'\$29.99 one-time'**
  String get lifetimePrice;

  /// No description provided for @lifetimeNote.
  ///
  /// In en, this message translates to:
  /// **'Pay once, keep forever. No recurring charges.'**
  String get lifetimeNote;

  /// No description provided for @subscribeNow.
  ///
  /// In en, this message translates to:
  /// **'Start Free Trial'**
  String get subscribeNow;

  /// No description provided for @buyLifetime.
  ///
  /// In en, this message translates to:
  /// **'Get Lifetime Access'**
  String get buyLifetime;

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore Purchases'**
  String get restorePurchases;

  /// No description provided for @termsAndPrivacy.
  ///
  /// In en, this message translates to:
  /// **'Terms of Service & Privacy Policy'**
  String get termsAndPrivacy;

  /// No description provided for @exitIntentTitle.
  ///
  /// In en, this message translates to:
  /// **'Wait! Exclusive One-Time Offer'**
  String get exitIntentTitle;

  /// No description provided for @exitIntentDesc.
  ///
  /// In en, this message translates to:
  /// **'Get Lifetime Pro Access with an instant 40% discount.'**
  String get exitIntentDesc;

  /// No description provided for @exitIntentPrice.
  ///
  /// In en, this message translates to:
  /// **'\$17.99 one-time'**
  String get exitIntentPrice;

  /// No description provided for @claimDiscount.
  ///
  /// In en, this message translates to:
  /// **'Claim 40% Discount'**
  String get claimDiscount;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'No thanks'**
  String get dismiss;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
