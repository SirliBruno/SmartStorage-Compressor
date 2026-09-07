import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/logger.dart';
import '../../features/video_compressor/domain/models/compression_request.dart';
import '../../features/video_compressor/domain/models/compression_result.dart';
import '../../features/video_compressor/domain/models/compression_status.dart';

/// Clean abstraction for the Hardware Video Compression Engine.
/// Decouples Flutter Presentation/Domain layers completely from native AVFoundation/MediaCodec.
abstract class VideoCompressionService {
  /// Initiates hardware video compression asynchronously.
  Future<CompressionResult> compressVideo(CompressionRequest request);

  /// Immediately aborts any ongoing compression and cleans up temporary resources.
  Future<bool> cancelCompression(String jobId);

  /// Real-time progress stream (0.0 to 1.0, ETA, bytes processed).
  Stream<CompressionProgress> get progressStream;

  /// Checks if hardware HEVC / H.265 is supported on the current device.
  Future<bool> isHevcSupported();
}

/// Concrete Platform Channel implementation communicating with Android MediaCodec and iOS AVFoundation.
class PlatformChannelVideoCompressionService implements VideoCompressionService {
  static const MethodChannel _methodChannel = MethodChannel('com.smartstorage.compressor/video_compression');
  static const EventChannel _eventChannel = EventChannel('com.smartstorage.compressor/compression_progress');

  Stream<CompressionProgress>? _broadcastStream;

  @override
  Stream<CompressionProgress> get progressStream {
    _broadcastStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((dynamic event) => _parseProgressEvent(event))
        .asBroadcastStream();
    return _broadcastStream!;
  }

  CompressionProgress _parseProgressEvent(dynamic event) {
    if (event is Map) {
      final progress = (event['progress'] as num?)?.toDouble() ?? 0.0;
      final remainingMs = (event['estimatedRemainingMs'] as num?)?.toInt();
      final bytes = (event['bytesProcessed'] as num?)?.toInt() ?? 0;
      final statusStr = event['status'] as String? ?? 'compressing';
      final isCancelled = (event['isCancelled'] as bool?) ?? false;

      CompressionStatus status = CompressionStatus.compressing;
      if (isCancelled || statusStr == 'cancelled') {
        status = CompressionStatus.cancelled;
      } else if (statusStr == 'completed') {
        status = CompressionStatus.completed;
      } else if (statusStr == 'failed') {
        status = CompressionStatus.failed;
      } else if (statusStr == 'preparing') {
        status = CompressionStatus.preparing;
      }

      return CompressionProgress(
        progress: progress,
        estimatedRemaining: remainingMs != null ? Duration(milliseconds: remainingMs) : null,
        bytesProcessed: bytes,
        status: status,
        isCancelled: isCancelled,
      );
    }
    return CompressionProgress.initial;
  }

  @override
  Future<CompressionResult> compressVideo(CompressionRequest request) async {
    try {
      AppLogger.info('Dispatching native compression: jobId=, input=');
      final stopwatch = Stopwatch()..start();

      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'startCompression',
        request.toPlatformMap(),
      );

      stopwatch.stop();

      if (result == null) {
        return CompressionResult.failure(
          errorCode: 'UNKNOWN_ERROR',
          errorMessage: 'Native engine returned null response.',
          originalPath: request.inputPath,
        );
      }

      final success = result['success'] as bool? ?? false;
      if (success) {
        final outputPath = result['outputPath'] as String? ?? request.outputPath;
        final originalSize = (result['originalSize'] as num?)?.toInt() ?? 0;
        final compressedSize = (result['compressedSize'] as num?)?.toInt() ?? 0;
        final durationMs = (result['durationMs'] as num?)?.toInt() ?? 0;

        return CompressionResult.successResult(
          originalPath: request.inputPath,
          outputPath: outputPath,
          originalSize: originalSize,
          compressedSize: compressedSize,
          duration: Duration(milliseconds: durationMs),
          processingTime: stopwatch.elapsed,
        );
      } else {
        final isCancelled = result['isCancelled'] as bool? ?? false;
        if (isCancelled) {
          return CompressionResult.cancelled(originalPath: request.inputPath);
        }
        return CompressionResult.failure(
          errorCode: result['errorCode'] as String? ?? 'COMPRESSION_FAILED',
          errorMessage: result['errorMessage'] as String? ?? 'Native compression failed.',
          originalPath: request.inputPath,
        );
      }
    } on PlatformException catch (e, stack) {
      AppLogger.error('PlatformException during video compression', e, stack);
      if (e.code == 'CANCELLED') {
        return CompressionResult.cancelled(originalPath: request.inputPath);
      }
      return CompressionResult.failure(
        errorCode: e.code,
        errorMessage: e.message ?? 'Platform compression failed',
        originalPath: request.inputPath,
      );
    } catch (e, stack) {
      AppLogger.error('Unexpected error during video compression', e, stack);
      return CompressionResult.failure(
        errorCode: 'UNKNOWN_ERROR',
        errorMessage: e.toString(),
        originalPath: request.inputPath,
      );
    }
  }

  @override
  Future<bool> cancelCompression(String jobId) async {
    try {
      AppLogger.info('Requesting native cancellation for jobId=');
      final result = await _methodChannel.invokeMethod<bool>(
        'cancelCompression',
        {'jobId': jobId},
      );
      return result ?? false;
    } catch (e, stack) {
      AppLogger.error('Error cancelling native compression', e, stack);
      return false;
    }
  }

  @override
  Future<bool> isHevcSupported() async {
    try {
      final supported = await _methodChannel.invokeMethod<bool>(
        'isCodecSupported',
        {'codec': 'hevc'},
      );
      return supported ?? true;
    } catch (e) {
      AppLogger.warn('Could not query HEVC codec support, falling back to true: ');
      return true;
    }
  }
}

/// Global provider for VideoCompressionService
final videoCompressionServiceProvider = Provider<VideoCompressionService>((ref) {
  return PlatformChannelVideoCompressionService();
});
