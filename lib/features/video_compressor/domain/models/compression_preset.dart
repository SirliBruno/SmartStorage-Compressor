enum PresetType {
  whatsAppFast,
  emailReady,
  maxSpaceSaver,
  customSize,
}

/// Domain configuration detailing exact video compression parameters.
class CompressionConfig {
  final PresetType presetType;
  final int targetResolutionWidth;
  final int targetResolutionHeight;
  final int targetBitrateBps;
  final bool useHevc;
  final int? customTargetSizeBytes;
  final bool isProOnly;

  const CompressionConfig({
    required this.presetType,
    required this.targetResolutionWidth,
    required this.targetResolutionHeight,
    required this.targetBitrateBps,
    this.useHevc = false,
    this.customTargetSizeBytes,
    this.isProOnly = false,
  });

  /// Factory helper for WhatsApp Fast Preset (720p, dynamic bitrate for 16MB or 64MB).
  factory CompressionConfig.whatsAppFast({
    required int targetBitrateBps,
    int targetBytes = 16 * 1024 * 1024,
  }) {
    return CompressionConfig(
      presetType: PresetType.whatsAppFast,
      targetResolutionWidth: 1280,
      targetResolutionHeight: 720,
      targetBitrateBps: targetBitrateBps,
      useHevc: false,
      customTargetSizeBytes: targetBytes,
      isProOnly: false,
    );
  }

  /// Factory helper for Email Ready Preset (24.5 MB ceiling).
  factory CompressionConfig.emailReady({
    required int targetBitrateBps,
    required int width,
    required int height,
  }) {
    return CompressionConfig(
      presetType: PresetType.emailReady,
      targetResolutionWidth: width,
      targetResolutionHeight: height,
      targetBitrateBps: targetBitrateBps,
      useHevc: false,
      customTargetSizeBytes: (24.5 * 1024 * 1024).toInt(),
      isProOnly: false,
    );
  }

  /// Factory helper for Maximum Space Saver Preset (1080p HEVC/H.265, 60-80% savings).
  factory CompressionConfig.maxSpaceSaver({
    required int targetBitrateBps,
  }) {
    return CompressionConfig(
      presetType: PresetType.maxSpaceSaver,
      targetResolutionWidth: 1920,
      targetResolutionHeight: 1080,
      targetBitrateBps: targetBitrateBps,
      useHevc: true, // Hardware H.265 mandatory
      isProOnly: true, // Pro feature
    );
  }

  /// Factory helper for Custom Size Slider Preset.
  factory CompressionConfig.custom({
    required int customTargetSizeBytes,
    required int targetBitrateBps,
    required int width,
    required int height,
    bool useHevc = false,
  }) {
    return CompressionConfig(
      presetType: PresetType.customSize,
      targetResolutionWidth: width,
      targetResolutionHeight: height,
      targetBitrateBps: targetBitrateBps,
      useHevc: useHevc,
      customTargetSizeBytes: customTargetSizeBytes,
      isProOnly: true, // Pro feature
    );
  }
}
