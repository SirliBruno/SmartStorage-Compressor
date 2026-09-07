/// Available video compression presets defined by PRD Section 5.1.
enum CompressionPreset {
  whatsappFast,
  emailReady,
  maximumSpaceSaver,
  customTargetSize;

  // Compatibility aliases
  static const CompressionPreset whatsAppFast = CompressionPreset.whatsappFast;
  static const CompressionPreset maxSpaceSaver = CompressionPreset.maximumSpaceSaver;
  static const CompressionPreset customSize = CompressionPreset.customTargetSize;
  static const CompressionPreset custom = CompressionPreset.customTargetSize;
}

/// Backwards compatibility type aliases
typedef PresetType = CompressionPreset;
typedef CompressionPresetType = CompressionPreset;

/// Domain configuration detailing exact video compression parameters.
class CompressionConfig {
  final CompressionPreset presetType;
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
      presetType: CompressionPreset.whatsappFast,
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
      presetType: CompressionPreset.emailReady,
      targetResolutionWidth: width,
      targetResolutionHeight: height,
      targetBitrateBps: targetBitrateBps,
      useHevc: false,
      customTargetSizeBytes: (24.5 * 1024 * 1024).toInt(),
      isProOnly: false,
    );
  }

  /// Factory helper for Maximum Space Saver Preset (HEVC, 1080p target).
  factory CompressionConfig.maxSpaceSaver({
    required int targetBitrateBps,
    required int width,
    required int height,
    bool useHevc = true,
  }) {
    return CompressionConfig(
      presetType: CompressionPreset.maximumSpaceSaver,
      targetResolutionWidth: width,
      targetResolutionHeight: height,
      targetBitrateBps: targetBitrateBps,
      useHevc: useHevc,
      isProOnly: true,
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
      presetType: CompressionPreset.customTargetSize,
      targetResolutionWidth: width,
      targetResolutionHeight: height,
      targetBitrateBps: targetBitrateBps,
      useHevc: useHevc,
      customTargetSizeBytes: customTargetSizeBytes,
      isProOnly: true,
    );
  }
}
