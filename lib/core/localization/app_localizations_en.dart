// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Smart Storage & Compressor';

  @override
  String get appTagline =>
      '100% On-Device Storage Recovery & Video Compression';

  @override
  String get onboardingTitle1 => 'Free Up Space';

  @override
  String get onboardingDesc1 =>
      'Quickly identify and compress bloated 4K/1080p videos to free up gigabytes of storage.';

  @override
  String get onboardingTitle2 => 'Compress Privately';

  @override
  String get onboardingDesc2 =>
      'Your photos and videos never leave your phone. All processing runs offline with zero server uploads.';

  @override
  String get onboardingTitle3 => 'Ready to Clean';

  @override
  String get onboardingDesc3 =>
      'Let\'s perform a quick local scan of your media library to find recoverable space.';

  @override
  String get getStarted => 'Get Started';

  @override
  String get continueButton => 'Continue';

  @override
  String get skip => 'Skip';

  @override
  String get startQuickScan => 'Start Quick Scan';

  @override
  String get privacyManifestoTitle => 'Your Media Stays on Your Device';

  @override
  String get privacyManifestoBody =>
      'Smart Storage is built from the ground up to be 100% offline. We do not operate media processing servers, and your videos and screenshots are never uploaded anywhere.';

  @override
  String get prePermissionTitle => 'Media Access';

  @override
  String get prePermissionSubtitle =>
      'To discover large videos and screenshots, the app needs read access to your media library. All operations happen strictly on-device.';

  @override
  String get allowAccessButton => 'Allow Access';

  @override
  String get permissionTitle => 'Media Library Access';

  @override
  String get permissionRationale =>
      'To discover large videos and organize screenshots, the app requires read access to your photos library. All operations happen strictly on-device without cloud syncing.';

  @override
  String get grantPermission => 'Allow Media Access';

  @override
  String get permissionDenied => 'Permission Denied';

  @override
  String get permissionSettingsHint =>
      'Please open system settings to grant photo and video access so the app can scan your library.';

  @override
  String get permissionLimitedTitle => 'Limited Access Granted';

  @override
  String get permissionLimitedDesc =>
      'The app can only see the media you explicitly selected. To scan all videos and screenshots, allow full library access in Settings.';

  @override
  String get permissionRestrictedTitle => 'Media Access Restricted';

  @override
  String get permissionRestrictedDesc =>
      'Media access is restricted by device parental controls or corporate device policy.';

  @override
  String get retryPermission => 'Try Again';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get quickScanTitle => 'Analyzing Storage...';

  @override
  String get quickScanSubtitle =>
      'Scanning media files locally to find reclaimable storage space.';

  @override
  String get scanningLibrary => 'Scanning your library...';

  @override
  String get taskVideos => 'Analyzing videos...';

  @override
  String get taskScreenshots => 'Identifying screenshots...';

  @override
  String get taskCalculating => 'Calculating recoverable space...';

  @override
  String get cancelScan => 'Cancel Scan';

  @override
  String get scanCancelledTitle => 'Scan Cancelled';

  @override
  String get scanCancelledDesc => 'Storage scan was stopped before completion.';

  @override
  String get quickScanResultTitle => 'Space Found!';

  @override
  String quickScanResultDesc(Object size) {
    return 'Approximately $size of recoverable storage detected.';
  }

  @override
  String get scanResultHeader => 'Scan Complete';

  @override
  String get scanResultRecoverable => 'You could free up';

  @override
  String scanResultFoundDetails(Object screenshots, Object videos) {
    return 'across $videos videos and $screenshots screenshots';
  }

  @override
  String get scanResultEmptyTitle => 'Your Storage is Lean!';

  @override
  String get scanResultEmptyDesc =>
      'No bloated videos or clutter were detected.';

  @override
  String get continueToPaywall => 'See Optimization Options';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get storageOverview => 'Storage Overview';

  @override
  String get usedStorage => 'Used Space';

  @override
  String get recoverableSpace => 'Recoverable';

  @override
  String get largeVideos => 'Large Videos';

  @override
  String get screenshots => 'Screenshots';

  @override
  String get compressVideoAction => 'Compress Video';

  @override
  String get cleanScreenshotsAction => 'Clean Screenshots';

  @override
  String get noVideosFound => 'No videos found';

  @override
  String get noScreenshotsFound => 'No screenshots found';

  @override
  String get emptyStateSubtitle => 'Your storage is lean and optimized.';

  @override
  String storageStatusAvailable(Object free, Object total) {
    return '$free available of $total';
  }

  @override
  String get storageStatusUnavailable => 'Storage capacity reading unavailable';

  @override
  String get placeholderCompressorTitle => 'Video Compressor';

  @override
  String get placeholderCompressorDesc =>
      'Hardware-accelerated compression engine is initializing.';

  @override
  String get placeholderCleanerTitle => 'Screenshot Cleaner';

  @override
  String get placeholderCleanerDesc =>
      'Fast swipe deck organizer is initializing.';

  @override
  String get videoLibraryTitle => 'Select Video';

  @override
  String get sortByLargest => 'Sorted by largest first';

  @override
  String get videoDuration => 'Duration';

  @override
  String get videoResolution => 'Resolution';

  @override
  String get videoFps => 'FPS';

  @override
  String get videoSize => 'Size';

  @override
  String get presetWhatsApp => 'WhatsApp Fast';

  @override
  String get presetWhatsAppDesc =>
      'Auto 720p • Dynamic bitrate for smooth WhatsApp sharing (16/64 MB)';

  @override
  String get presetEmail => 'Email Ready';

  @override
  String get presetEmailDesc =>
      'Target 24.5 MB • Under Gmail & Outlook 25 MB limit';

  @override
  String get presetMaxSaver => 'Maximum Space Saver';

  @override
  String get presetMaxSaverDesc =>
      '60–80% size reduction • 1080p HEVC / H.265 high efficiency';

  @override
  String get presetCustom => 'Custom Target Size';

  @override
  String get presetCustomDesc => 'Precise MB slider control • Pro Feature';

  @override
  String get startCompression => 'Start Compression';

  @override
  String get compressingVideo => 'Compressing Video...';

  @override
  String get processing => 'Processing';

  @override
  String estimatedTimeRemaining(Object eta) {
    return 'Estimated time remaining: $eta';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get aborting => 'Aborting...';

  @override
  String get comparisonTitle => 'Quality Comparison';

  @override
  String get original => 'Original';

  @override
  String get compressed => 'Compressed';

  @override
  String spaceSaved(Object percent) {
    return 'Saved $percent%';
  }

  @override
  String originalSizeLabel(Object size) {
    return 'Original: $size';
  }

  @override
  String compressedSizeLabel(Object size) {
    return 'New: $size';
  }

  @override
  String get saveAsCopy => 'Save as Copy';

  @override
  String get replaceOriginal => 'Replace Original';

  @override
  String get replaceWarning =>
      'This will delete the bloated original from your camera roll after saving the compressed version.';

  @override
  String get saveSuccess => 'Video saved successfully to your gallery';

  @override
  String get replaceSuccess => 'Original replaced with compressed copy';

  @override
  String get screenshotCleanerTitle => 'Screenshot Cleaner';

  @override
  String get swipeInstructions => 'Swipe Right to Keep • Swipe Left to Delete';

  @override
  String get keep => 'Keep';

  @override
  String get delete => 'Delete';

  @override
  String get potentialSpaceRecovered => 'Potential Space Recovered';

  @override
  String markedCount(Object count, Object size) {
    return '$count screenshots marked ($size)';
  }

  @override
  String get reviewMarkedItems => 'Review Marked Items';

  @override
  String get confirmFinalDeletion => 'Confirm Final Delete';

  @override
  String get restoreAll => 'Restore All';

  @override
  String get cleanComplete => 'All Screenshots Reviewed';

  @override
  String get paywallTitle => 'Upgrade to Pro';

  @override
  String get paywallSubtitle =>
      'Unlock unlimited compression and high-efficiency 4K HEVC tools.';

  @override
  String get featureUnlimitedCompression => 'Unlimited video compressions';

  @override
  String get feature4kHevc => 'Full 1080p & 4K HEVC hardware acceleration';

  @override
  String get featureInteractiveSlider =>
      'Live split-screen quality comparison slider';

  @override
  String get featureUnlimitedScreenshots =>
      'Unlimited screenshot batch sorting';

  @override
  String get featureCustomSize => 'Precise Custom Size slider';

  @override
  String get featureNoAds => '100% Ad-free experience';

  @override
  String get annualPlan => 'Annual Plan';

  @override
  String get annualPrice => '\$19.99 / year';

  @override
  String get annualTrialNote =>
      '3-day free trial, then \$19.99/year (\$1.66/month)';

  @override
  String get lifetimePlan => 'Lifetime Access';

  @override
  String get lifetimePrice => '\$29.99 one-time';

  @override
  String get lifetimeNote => 'Pay once, keep forever. No recurring charges.';

  @override
  String get subscribeNow => 'Start Free Trial';

  @override
  String get buyLifetime => 'Get Lifetime Access';

  @override
  String get restorePurchases => 'Restore Purchases';

  @override
  String get termsAndPrivacy => 'Terms of Service & Privacy Policy';

  @override
  String get exitIntentTitle => 'Wait! Exclusive One-Time Offer';

  @override
  String get exitIntentDesc =>
      'Get Lifetime Pro Access with an instant 40% discount.';

  @override
  String get exitIntentPrice => '\$17.99 one-time';

  @override
  String get claimDiscount => 'Claim 40% Discount';

  @override
  String get dismiss => 'No thanks';
}
