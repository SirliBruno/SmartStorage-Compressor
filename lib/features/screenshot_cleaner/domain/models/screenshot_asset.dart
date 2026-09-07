import 'dart:typed_data';

enum ScreenshotAction { unreviewed, keep, delete }

/// Domain model representing a photoScreenshot asset detected exclusively on the device.
class ScreenshotAsset {
  final String id;
  final String path;
  final int fileSizeBytes;
  final int width;
  final int height;
  final DateTime creationDate;
  final Uint8List? thumbnailBytes;
  final ScreenshotAction action;

  const ScreenshotAsset({
    required this.id,
    required this.path,
    required this.fileSizeBytes,
    required this.width,
    required this.height,
    required this.creationDate,
    this.thumbnailBytes,
    this.action = ScreenshotAction.unreviewed,
  });

  /// Grouping key formatted by Year-Month (e.g. "2026-08") for chronological grouping.
  String get monthGroupKey => '${creationDate.year}-${creationDate.month.toString().padLeft(2, '0')}';

  ScreenshotAsset copyWith({
    String? id,
    String? path,
    int? fileSizeBytes,
    int? width,
    int? height,
    DateTime? creationDate,
    Uint8List? thumbnailBytes,
    ScreenshotAction? action,
  }) {
    return ScreenshotAsset(
      id: id ?? this.id,
      path: path ?? this.path,
      fileSizeBytes: fileSizeBytes ?? this.fileSizeBytes,
      width: width ?? this.width,
      height: height ?? this.height,
      creationDate: creationDate ?? this.creationDate,
      thumbnailBytes: thumbnailBytes ?? this.thumbnailBytes,
      action: action ?? this.action,
    );
  }
}
