import 'compression_result.dart';
import 'video_asset.dart';

/// Lifecycle status for an active compression session.
enum CompressionSessionStatus {
  comparing,
  saving,
  saved,
  confirmingReplace,
  replacing,
  replaced,
  failed,
  cancelled,
}

/// Domain model encapsulating the end-to-end lifecycle of a compressed video session.
/// Bridges native compression output with comparison and gallery save flows.
class CompressionSession {
  final String sessionId;
  final VideoAsset originalAsset;
  final String compressedPath;
  final CompressionResult result;
  final DateTime createdAt;
  final CompressionSessionStatus status;
  final String? errorMessage;

  const CompressionSession({
    required this.sessionId,
    required this.originalAsset,
    required this.compressedPath,
    required this.result,
    required this.createdAt,
    this.status = CompressionSessionStatus.comparing,
    this.errorMessage,
  });

  /// Factory constructor to initialize a session from a successful compression result.
  factory CompressionSession.fromResult({
    required VideoAsset originalAsset,
    required CompressionResult result,
    String? sessionId,
  }) {
    return CompressionSession(
      sessionId: sessionId ?? 'session_${DateTime.now().millisecondsSinceEpoch}_${originalAsset.id}',
      originalAsset: originalAsset,
      compressedPath: result.compressedPath,
      result: result,
      createdAt: DateTime.now(),
      status: CompressionSessionStatus.comparing,
    );
  }

  /// Create a modified copy of the session.
  CompressionSession copyWith({
    String? sessionId,
    VideoAsset? originalAsset,
    String? compressedPath,
    CompressionResult? result,
    DateTime? createdAt,
    CompressionSessionStatus? status,
    String? errorMessage,
  }) {
    return CompressionSession(
      sessionId: sessionId ?? this.sessionId,
      originalAsset: originalAsset ?? this.originalAsset,
      compressedPath: compressedPath ?? this.compressedPath,
      result: result ?? this.result,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  // --- Real Metadata Getters (Zero Fake Data) ---

  /// Original video file size in bytes
  int get originalSizeBytes => result.originalSizeBytes > 0
      ? result.originalSizeBytes
      : originalAsset.fileSizeBytes;

  /// Compressed video file size in bytes
  int get compressedSizeBytes => result.compressedSizeBytes;

  /// Total storage space saved in bytes
  int get savedBytes => result.savedBytes;

  /// Space saved as a percentage (e.g. 78.4%)
  double get savedPercentage => result.savedPercentage;

  /// Original duration
  Duration get originalDuration => originalAsset.duration;

  /// Compressed duration (falls back to original if not recorded separately)
  Duration get compressedDuration => result.duration ?? originalAsset.duration;

  /// Original resolution formatted string (e.g. 1920x1080)
  String get originalResolution => '${originalAsset.width}x${originalAsset.height}';

  /// Original codec name
  String get originalCodec => originalAsset.codec;

  /// Whether the session is currently performing a persistent operation
  bool get isProcessingSave =>
      status == CompressionSessionStatus.saving ||
      status == CompressionSessionStatus.replacing;

  /// Whether the session has successfully saved or replaced
  bool get isFinalized =>
      status == CompressionSessionStatus.saved ||
      status == CompressionSessionStatus.replaced;
}
