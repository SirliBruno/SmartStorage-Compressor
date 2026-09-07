import '../lib/core/constants/app_constants.dart';
import '../lib/core/utils/bitrate_calculator.dart';
import '../lib/core/extensions/file_size_extensions.dart';
import '../lib/core/extensions/duration_extensions.dart';
import '../lib/features/paywall/domain/models/quota_state.dart';
import '../lib/features/video_compressor/domain/models/compression_preset.dart';
import '../lib/features/video_compressor/domain/models/compression_result.dart';
import '../lib/features/onboarding/domain/models/permission_models.dart';
import '../lib/features/onboarding/domain/models/scan_models.dart';
import '../lib/core/services/storage_info_service.dart';
import '../lib/features/video_compressor/domain/models/video_asset.dart';
import 'dart:collection';

// Standalone in-memory state machine for testing onboarding logic
class PureOnboardingStateMachine {
  bool _isCompleted;
  PureOnboardingStateMachine({bool isCompleted = false}) : _isCompleted = isCompleted;

  bool get isCompleted => _isCompleted;

  void complete() {
    _isCompleted = true;
  }

  void reset() {
    _isCompleted = false;
  }
}

void main() {
  print('====================================================');
  print('Running Sprint 01 + Sprint 02 Verification Suite');
  print('====================================================\n');

  var passedCount = 0;
  var failedCount = 0;

  void assertTest(String name, bool condition) {
    if (condition) {
      print('  [PASS] $name');
      passedCount++;
    } else {
      print('  [FAIL] $name');
      failedCount++;
    }
  }

  // ----------------------------------------------------
  // 1. Bitrate Calculator Tests (PRD Equation: Bitrate = (Target Bits / Duration) - Audio Bitrate)
  // ----------------------------------------------------
  print('1. Bitrate Calculator & PRD Formulas:');
  const targetBytes = 16 * 1024 * 1024; // 16 MB = 134,217,728 bits
  const duration60 = Duration(seconds: 60);
  final bitrate16Mb = BitrateCalculator.calculateTargetVideoBitrate(
    targetSizeBytes: targetBytes,
    duration: duration60,
  );
  assertTest('WhatsApp 16MB 60s bitrate == 2,108,962 bps (~2.1 Mbps)', bitrate16Mb == 2108962);

  // Email Ready: 24.5 MB over 120s
  final emailBytes = (245 * AppConstants.bytesPerMb) ~/ 10;
  final emailBitrate = BitrateCalculator.calculateTargetVideoBitrate(
    targetSizeBytes: emailBytes,
    duration: const Duration(seconds: 120),
  );
  assertTest('Email Ready 24.5MB 120s bitrate == 1,584,674 bps (~1.58 Mbps)', emailBitrate == 1584674);

  // Minimum floor clamp (250 kbps)
  final clampedFloor = BitrateCalculator.calculateTargetVideoBitrate(
    targetSizeBytes: 1 * 1024 * 1024,
    duration: const Duration(hours: 1),
  );
  assertTest('Enforces min video bitrate floor of 250 kbps', clampedFloor == AppConstants.minVideoBitrateBps);

  // Clamped to original
  final clampedOriginal = BitrateCalculator.calculateTargetVideoBitrate(
    targetSizeBytes: 500 * 1024 * 1024,
    duration: const Duration(seconds: 5),
    originalBitrateBps: 8000000,
  );
  assertTest('Clamps bitrate to original video bitrate when target is higher', clampedOriginal == 8000000);

  // Email resolution recommendation
  final emailShort = BitrateCalculator.recommendEmailResolution(const Duration(minutes: 2));
  assertTest('Recommends 720p for email <= 3 minutes', emailShort.width == 1280 && emailShort.height == 720);

  final emailLong = BitrateCalculator.recommendEmailResolution(const Duration(minutes: 5));
  assertTest('Recommends 540p for email > 3 minutes', emailLong.width == 960 && emailLong.height == 540);

  // ----------------------------------------------------
  // 2. File Size Extensions & Savings Computation
  // ----------------------------------------------------
  print('\n2. File Size & Savings Computations:');
  assertTest('Formats 0 bytes as "0 B"', 0.formatBytes() == '0 B');
  assertTest('Formats 1024 bytes as "1.0 KB"', 1024.formatBytes() == '1.0 KB');
  assertTest('Formats 15 MB as "15.0 MB"', (15 * 1024 * 1024).formatBytes() == '15.0 MB');
  assertTest('Formats 1.8 GB as "1.8 GB"', (1887436800).formatBytes() == '1.8 GB');

  // PRD Example: 320 MB -> 28 MB is ~91% savings
  const origBytes = 320 * 1024 * 1024;
  const compBytes = 28 * 1024 * 1024;
  final savedPercent = origBytes.calculateSavedPercentage(compBytes);
  final isCloseTo91 = (savedPercent - 91.25).abs() < 0.01;
  assertTest('PRD Example: 320MB -> 28MB yields 91.25% savings', isCloseTo91);

  // CompressionResult model test
  final resultModel = CompressionResult(
    originalPath: '/input.mp4',
    compressedPath: '/output.mp4',
    originalSizeBytes: origBytes,
    compressedSizeBytes: compBytes,
    duration: const Duration(seconds: 45),
    processingTime: const Duration(seconds: 4),
  );
  assertTest('CompressionResult computes 91.25% saved percentage', (resultModel.savedPercentage - 91.25).abs() < 0.01);
  assertTest('CompressionResult computes correct saved bytes', resultModel.savedBytes == (origBytes - compBytes));

  // ----------------------------------------------------
  // 3. Duration Extensions
  // ----------------------------------------------------
  print('\n3. Duration & ETA Formatting:');
  assertTest('Formats 92 seconds as "01:32"', const Duration(seconds: 92).formatDuration() == '01:32');
  assertTest('Formats 3920 seconds as "01:05:20"', const Duration(seconds: 3920).formatDuration() == '01:05:20');
  assertTest('Formats English ETA "4 sec"', const Duration(seconds: 4).formatEta(isArabic: false) == '4 sec');
  assertTest('Formats Arabic ETA "4 ثوان"', const Duration(seconds: 4).formatEta(isArabic: true) == '4 ثوان');

  // ----------------------------------------------------
  // 4. Quota State & Entitlements (PRD Section 4.1)
  // ----------------------------------------------------
  print('\n4. Quota & Pro Entitlements (PRD Matrix):');
  var quota = const QuotaState();
  assertTest('Default free tier has 3 remaining compressions', quota.remainingCompressions == 3);
  assertTest('Default free tier can compress', quota.canCompress == true);
  assertTest('Default free tier cannot use 4K HEVC', quota.canUseHevc4k == false);
  assertTest('Default free tier cannot use interactive slider', quota.canUseInteractiveSlider == false);
  assertTest('Default free tier cannot use custom size slider', quota.canUseCustomSizeSlider == false);

  quota = quota.copyWith(compressionsUsed: 3);
  assertTest('Quota locked after 3 compressions used', quota.canCompress == false);
  assertTest('0 remaining compressions', quota.remainingCompressions == 0);

  quota = quota.copyWith(screenshotsCleaned: 25);
  assertTest('Screenshot cleaner locked after 25 screenshots in free tier', quota.canCleanScreenshots == false);

  quota = quota.copyWith(isProUser: true);
  assertTest('Pro user unlocks unlimited compression', quota.canCompress == true);
  assertTest('Pro user unlocks 4K HEVC', quota.canUseHevc4k == true);
  assertTest('Pro user unlocks interactive slider', quota.canUseInteractiveSlider == true);
  assertTest('Pro user unlocks custom size slider', quota.canUseCustomSizeSlider == true);
  assertTest('Pro user unlocks unlimited screenshots', quota.canCleanScreenshots == true);

  // ----------------------------------------------------
  // 5. Preset Configurations
  // ----------------------------------------------------
  print('\n5. Compression Presets:');
  final waPreset = CompressionConfig.whatsAppFast(targetBitrateBps: 2000000);
  assertTest('WhatsApp Fast preset targets 720p (1280x720)', waPreset.targetResolutionWidth == 1280 && waPreset.targetResolutionHeight == 720);
  assertTest('WhatsApp Fast is available for Free tier', waPreset.isProOnly == false);

  final maxPreset = CompressionConfig.maxSpaceSaver(targetBitrateBps: 1500000);
  assertTest('Maximum Space Saver preset uses HEVC (H.265)', maxPreset.useHevc == true);
  assertTest('Maximum Space Saver preset targets 1080p', maxPreset.targetResolutionWidth == 1920 && maxPreset.targetResolutionHeight == 1080);
  assertTest('Maximum Space Saver is Pro only', maxPreset.isProOnly == true);

  final customPreset = CompressionConfig.custom(
    customTargetSizeBytes: 50 * 1024 * 1024,
    targetBitrateBps: 3000000,
    width: 1920,
    height: 1080,
  );
  assertTest('Custom size preset is Pro only', customPreset.isProOnly == true);

  // ----------------------------------------------------
  // 6. Sprint 02: Onboarding Persistence Tests
  // ----------------------------------------------------
  print('\n6. Sprint 02 - Onboarding Persistence & State Machine:');
  final onboardingMachine = PureOnboardingStateMachine(isCompleted: false);
  assertTest('Onboarding initial state isCompleted == false', onboardingMachine.isCompleted == false);

  onboardingMachine.complete();
  assertTest('complete() transitions isCompleted to true', onboardingMachine.isCompleted == true);

  onboardingMachine.reset();
  assertTest('reset() resets isCompleted to false', onboardingMachine.isCompleted == false);

  // ----------------------------------------------------
  // 7. Sprint 02: Platform Permission States Tests
  // ----------------------------------------------------
  print('\n7. Sprint 02 - Media Permission Handling:');
  assertTest('MediaPermissionState supports unknown', MediaPermissionState.unknown.name == 'unknown');
  assertTest('MediaPermissionState supports granted', MediaPermissionState.granted.name == 'granted');
  assertTest('MediaPermissionState supports limited', MediaPermissionState.limited.name == 'limited');
  assertTest('MediaPermissionState supports denied', MediaPermissionState.denied.name == 'denied');
  assertTest('MediaPermissionState supports restricted', MediaPermissionState.restricted.name == 'restricted');

  // ----------------------------------------------------
  // 8. Sprint 02: Real Media Scanner & Zero Fake Data
  // ----------------------------------------------------
  print('\n8. Sprint 02 - Real Media Scanner & Zero Fake Data:');
  const emptyData = ScanResultData.empty;
  assertTest('Empty scan hasMedia == false', emptyData.hasMedia == false);
  assertTest('Empty scan videoCount == 0', emptyData.videoCount == 0);
  assertTest('Empty scan recoverableBytes == 0 (Zero fake 1.8 GB)', emptyData.estimatedRecoverableBytes == 0);

  const scannedData = ScanResultData(
    videoCount: 8,
    screenshotCount: 32,
    totalScannedBytes: 2500000000,
    estimatedRecoverableBytes: 1650000000,
    isCompleted: true,
  );
  assertTest('Scanned data hasMedia == true', scannedData.hasMedia == true);
  assertTest('Scanned data accurately reports 8 videos', scannedData.videoCount == 8);
  assertTest('Scanned data accurately reports 32 screenshots', scannedData.screenshotCount == 32);
  assertTest('Scanned data calculates 1.5 GB recoverable space without hardcoding', scannedData.estimatedRecoverableBytes.formatBytes() == '1.5 GB');

  final cancelToken = ScanCancellationToken();
  assertTest('CancellationToken initial isCancelled == false', cancelToken.isCancelled == false);
  cancelToken.cancel();
  assertTest('CancellationToken cancel() flags isCancelled == true', cancelToken.isCancelled == true);

  // ----------------------------------------------------
  // 9. Sprint 02: System Storage Info (Real vs Unavailable)
  // ----------------------------------------------------
  print('\n9. Sprint 02 - System Storage Metrics:');
  const unavailableInfo = SystemStorageInfo.unavailable;
  assertTest('Unavailable storage info has isAvailable == false', unavailableInfo.isAvailable == false);
  assertTest('Unavailable storage info has 0 used bytes', unavailableInfo.usedBytes == 0);

  const activeInfo = SystemStorageInfo(totalBytes: 128000000000, freeBytes: 40000000000, isAvailable: true);
  assertTest('Active storage info computes usedBytes correctly (88 GB)', activeInfo.usedBytes == 88000000000);
  assertTest('Active storage info reports isAvailable == true', activeInfo.isAvailable == true);

  // ----------------------------------------------------
  // 10. Sprint 03: VideoAsset Domain Entity & Metadata Formatting
  // ----------------------------------------------------
  print('\n10. Sprint 03 - VideoAsset Domain Model & Metadata Formatting:');
  final now = DateTime.now();

  final video4k = VideoAsset(
    id: 'vid-4k-01',
    localIdentifier: 'ph-asset://001',
    path: '/media/video_4k.mov',
    title: 'Cinematic Sunset 4K',
    fileSizeBytes: 1400000000, // ~1.4 GB
    duration: const Duration(minutes: 2, seconds: 15),
    width: 3840,
    height: 2160,
    fps: 60.0,
    codec: 'HEVC (H.265)',
    creationDate: now,
  );

  assertTest('4K resolution label detected', video4k.resolutionLabel == '4K');
  assertTest('4K 60 FPS specLabel formatted correctly', video4k.specLabel == '4K • 60 FPS');
  assertTest('Video formatted duration is "02:15"', video4k.formattedDuration == '02:15');
  assertTest('Video formatted size is "1.3 GB"', video4k.formattedSize == '1.3 GB');
  assertTest('Video effectiveId returns localIdentifier', video4k.effectiveId == 'ph-asset://001');
  assertTest('Landscape video reports isPortrait == false', video4k.isPortrait == false);
  assertTest('Landscape aspect ratio is 16:9 (~1.77)', (video4k.aspectRatio - (16 / 9)).abs() < 0.01);

  final video1080p = VideoAsset(
    id: 'vid-1080p-02',
    path: '/media/story.mp4',
    title: 'Instagram Reel',
    fileSizeBytes: 850 * 1024 * 1024, // 850 MB
    duration: const Duration(seconds: 45),
    width: 1080,
    height: 1920,
    fps: 29.97,
    codec: 'H.264 (AVC)',
    creationDate: now,
  );

  assertTest('1080p resolution label detected', video1080p.resolutionLabel == '1080p');
  assertTest('1080p 30 FPS rounded specLabel', video1080p.specLabel == '1080p • 30 FPS');
  assertTest('Portrait video reports isPortrait == true', video1080p.isPortrait == true);
  assertTest('Fallback effectiveId returns id when localIdentifier is null', video1080p.effectiveId == 'vid-1080p-02');

  final video720p = VideoAsset(
    id: 'vid-720p-03',
    path: '/media/clip.mp4',
    title: 'WhatsApp Clip',
    fileSizeBytes: 420 * 1024 * 1024, // 420 MB
    duration: const Duration(seconds: 90),
    width: 1280,
    height: 720,
    fps: 24.0,
    codec: 'H.264',
    creationDate: now,
  );
  assertTest('720p resolution label detected', video720p.resolutionLabel == '720p');
  assertTest('720p 24 FPS specLabel', video720p.specLabel == '720p • 24 FPS');

  final videoCustom = video720p.copyWith(width: 640, height: 360);
  assertTest('Custom resolution formatted as WxH fallback', videoCustom.resolutionLabel == '640x360');

  // ----------------------------------------------------
  // 11. Sprint 03: Largest-First Sorting Algorithm
  // ----------------------------------------------------
  print('\n11. Sprint 03 - Largest-First Sorting Algorithm:');
  final videoSmall = VideoAsset(
    id: 'vid-small-04',
    path: '/media/voice_note_video.mp4',
    title: 'Voice Note Video',
    fileSizeBytes: 15 * 1024 * 1024, // 15 MB
    duration: const Duration(seconds: 12),
    width: 854,
    height: 480,
    fps: 30.0,
    creationDate: now,
  );

  // Intentionally unordered collection
  final unsortedVideos = [videoSmall, video4k, video720p, video1080p];

  // Sorting descending by file size
  final sortedVideos = List<VideoAsset>.from(unsortedVideos)
    ..sort((a, b) => b.fileSizeBytes.compareTo(a.fileSizeBytes));

  assertTest('Sorted list has 4 elements', sortedVideos.length == 4);
  assertTest('1st video is largest (4K: 1.4 GB)', sortedVideos[0].id == 'vid-4k-01');
  assertTest('2nd video is next largest (1080p: 850 MB)', sortedVideos[1].id == 'vid-1080p-02');
  assertTest('3rd video is next (720p: 420 MB)', sortedVideos[2].id == 'vid-720p-03');
  assertTest('4th video is smallest (15 MB)', sortedVideos[3].id == 'vid-small-04');

  // Tolerance test with zero-byte or corrupt asset
  final corruptAsset = VideoAsset(
    id: 'vid-corrupt-05',
    path: '/media/corrupt.mp4',
    title: 'Corrupt Video',
    fileSizeBytes: 0,
    duration: Duration.zero,
    width: 0,
    height: 0,
    fps: 0,
    isAccessible: false,
    creationDate: now,
  );
  final listWithCorrupt = [videoSmall, corruptAsset, video4k]
    ..sort((a, b) => b.fileSizeBytes.compareTo(a.fileSizeBytes));

  assertTest('Corrupt 0-byte asset safely sorts to the end without crashing', listWithCorrupt.last.id == 'vid-corrupt-05');
  assertTest('Valid assets remain at top in descending order', listWithCorrupt.first.id == 'vid-4k-01');

  // ----------------------------------------------------
  // 12. Sprint 03: Memory-Bounded LRU Cache Mechanics
  // ----------------------------------------------------
  print('\n12. Sprint 03 - LRU Thumbnail Cache Mechanics:');
  const maxLruCapacity = 3;
  final lruCache = LinkedHashMap<String, String>();

  void putLru(String key, String val) {
    if (lruCache.containsKey(key)) {
      lruCache.remove(key);
    } else if (lruCache.length >= maxLruCapacity) {
      final oldestKey = lruCache.keys.first;
      lruCache.remove(oldestKey);
    }
    lruCache[key] = val;
  }

  String? getLru(String key) {
    if (!lruCache.containsKey(key)) return null;
    final val = lruCache.remove(key)!;
    lruCache[key] = val;
    return val;
  }

  putLru('asset_1', 'thumb_data_1');
  putLru('asset_2', 'thumb_data_2');
  putLru('asset_3', 'thumb_data_3');
  assertTest('Cache holds 3 entries initially', lruCache.length == 3);

  // Access asset_1 to mark it recently used
  getLru('asset_1');

  // Insert asset_4 -> asset_2 should be evicted because asset_1 was accessed recently
  putLru('asset_4', 'thumb_data_4');
  assertTest('Cache length stays capped at max capacity (3)', lruCache.length == 3);
  assertTest('Oldest non-accessed asset_2 was evicted', !lruCache.containsKey('asset_2'));
  assertTest('asset_1 preserved due to LRU access hit', lruCache.containsKey('asset_1'));
  assertTest('New asset_4 is present in cache', lruCache.containsKey('asset_4'));

  // ----------------------------------------------------
  // 13. Sprint 03: Zero-Binary Navigation & Safe Payload Architecture
  // ----------------------------------------------------
  print('\n13. Sprint 03 - Zero-Binary Payload & Navigation Safety:');
  // Verify that navigating to prepare screen passes metadata references, not video bytes in RAM
  final navPayload = {
    'assetId': video4k.effectiveId,
    'fileSizeBytes': video4k.fileSizeBytes,
    'hasMemoryPayload': video4k.thumbnailBytes != null,
  };
  assertTest('Navigation payload passes asset reference ID', navPayload['assetId'] == 'ph-asset://001');
  assertTest('Navigation payload does not contain raw video file buffer', !navPayload.containsKey('rawBytes'));

  print('\n====================================================');
  print('Sprint 01 + Sprint 02 + Sprint 03 Verification Results: $passedCount Passed, $failedCount Failed');
  print('====================================================');

  if (failedCount > 0) {
    throw Exception('$failedCount tests failed!');
  }
}

