/// Core Application Constants adhering to the PRD specifications.
abstract class AppConstants {
  // Free Tier Quota Limits
  static const int freeTierLifetimeCompressions = 3;
  static const int freeTierMaxScreenshots = 25;

  // Video Target Sizes in Bytes
  static const int bytesPerMb = 1024 * 1024;
  static const int whatsAppFast16MbBytes = 16 * bytesPerMb;
  static const int whatsAppFast64MbBytes = 64 * bytesPerMb;
  // 24.5 MB in bytes = 25,690,112 bytes
  static const int emailReadyTargetBytes = (245 * bytesPerMb) ~/ 10;

  // Audio Bitrate constant from PRD formula:
  // Bitrate (bps) = (Target Size (bits) / Duration (seconds)) - Audio Bitrate (128 kbps)
  static const int defaultAudioBitrateBps = 128 * 1000; // 128 kbps in bps
  static const int minVideoBitrateBps = 250 * 1000;    // 250 kbps floor to preserve intelligibility

  // Target Memory Ceiling from PRD (Section 5.3)
  static const int maxRamCeilingBytes = 150 * bytesPerMb; // 150 MB ceiling

  // Monetization Pricing
  static const double annualPriceUsd = 19.99;
  static const double lifetimePriceUsd = 29.99;
  static const double exitDiscountLifetimeUsd = 17.99; // 40% OFF
  static const double annualPriceSar = 74.99;
  static const double lifetimePriceSar = 99.99;
  static const double exitDiscountLifetimeSar = 59.99;

  // Storage Thresholds
  static const int minFreeStorageForCompression = 200 * bytesPerMb; // 200 MB buffer required
}
