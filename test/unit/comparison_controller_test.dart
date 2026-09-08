import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_storage_compressor/core/utils/temp_file_manager.dart';
import 'package:smart_storage_compressor/features/video_compressor/domain/models/compression_result.dart';
import 'package:smart_storage_compressor/features/video_compressor/domain/models/compression_session.dart';
import 'package:smart_storage_compressor/features/video_compressor/domain/models/video_asset.dart';
import 'package:smart_storage_compressor/features/video_compressor/presentation/controllers/comparison_controller.dart';
import 'package:smart_storage_compressor/services/media/media_save_service.dart';

class FakeMediaSaveService implements MediaSaveService {
  bool shouldSucceed = true;
  bool shouldDenyPermission = false;
  int saveCallCount = 0;
  int replaceCallCount = 0;

  @override
  Future<MediaSaveResult> saveAsCopy({
    required String compressedPath,
    required String title,
  }) async {
    saveCallCount++;
    if (shouldDenyPermission) {
      return const MediaSaveResult(
        outcome: SaveOutcome.permissionDenied,
        errorMessage: 'Permission denied',
      );
    }
    if (!shouldSucceed) {
      return const MediaSaveResult(
        outcome: SaveOutcome.failed,
        errorMessage: 'Disk error',
      );
    }
    return const MediaSaveResult(
      outcome: SaveOutcome.success,
      savedAssetId: 'new_saved_asset_999',
    );
  }

  @override
  Future<MediaSaveResult> replaceOriginal({
    required String originalAssetId,
    required String compressedPath,
    required String title,
  }) async {
    replaceCallCount++;
    if (!shouldSucceed) {
      return const MediaSaveResult(
        outcome: SaveOutcome.failed,
        errorMessage: 'Failed to write copy, original untouched.',
      );
    }
    return const MediaSaveResult(
      outcome: SaveOutcome.success,
      savedAssetId: 'new_saved_asset_999',
      originalDeleted: true,
    );
  }

  @override
  Future<bool> verifySavedAsset(String assetId) async {
    return shouldSucceed;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ComparisonNotifier State Machine & Atomic Save Tests', () {
    late CompressionSession sampleSession;
    late FakeMediaSaveService fakeSaveService;
    late ProviderContainer container;

    setUp(() {
      fakeSaveService = FakeMediaSaveService();

      final video = VideoAsset(
        id: 'asset_orig_1',
        localIdentifier: 'asset_orig_1',
        path: '/mock/original.mp4',
        title: 'OriginalVideo',
        fileSizeBytes: 100 * 1024 * 1024,
        duration: const Duration(seconds: 30),
        width: 1920,
        height: 1080,
        fps: 30,
        codec: 'H.264',
        isAccessible: true,
        mimeType: 'video/mp4',
        creationDate: DateTime(2026, 1, 1),
      );

      final result = CompressionResult.successResult(
        originalPath: video.path,
        outputPath: '/mock/compressed.mp4',
        originalSize: 100 * 1024 * 1024,
        compressedSize: 30 * 1024 * 1024,
        duration: const Duration(seconds: 30),
        processingTime: const Duration(seconds: 5),
      );

      sampleSession = CompressionSession.fromResult(
        originalAsset: video,
        result: result,
      );

      container = ProviderContainer(
        overrides: [
          mediaSaveServiceProvider.overrideWithValue(fakeSaveService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial state is idle with session intact', () {
      final notifier = ComparisonNotifier(
        initialSession: sampleSession,
        saveService: fakeSaveService,
        tempFileManager: TempFileManager(),
        ref: container.read(Provider((ref) => ref)),
      );

      expect(notifier.state.saveStatus, SaveStatus.idle);
      expect(notifier.state.isProcessing, isFalse);
      expect(notifier.state.isSuccess, isFalse);
      expect(notifier.state.originalSizeBytes, 100 * 1024 * 1024);
      expect(notifier.state.compressedSizeBytes, 30 * 1024 * 1024);
      expect(notifier.state.savedBytes, 70 * 1024 * 1024);
    });

    test('saveAsCopy success transitions to SaveStatus.saved', () async {
      final notifier = ComparisonNotifier(
        initialSession: sampleSession,
        saveService: fakeSaveService,
        tempFileManager: TempFileManager(),
        ref: container.read(Provider((ref) => ref)),
      );

      final success = await notifier.saveAsCopy();

      expect(success, isTrue);
      expect(fakeSaveService.saveCallCount, 1);
      expect(notifier.state.saveStatus, SaveStatus.saved);
      expect(notifier.state.isSuccess, isTrue);
      expect(notifier.state.session.status, CompressionSessionStatus.saved);
    });

    test('Double-save prevention: concurrent calls do not duplicate operations', () async {
      final notifier = ComparisonNotifier(
        initialSession: sampleSession,
        saveService: fakeSaveService,
        tempFileManager: TempFileManager(),
        ref: container.read(Provider((ref) => ref)),
      );

      // Trigger first save
      final first = notifier.saveAsCopy();
      // Concurrently trigger second save while first is processing
      final second = notifier.saveAsCopy();

      final results = await Future.wait([first, second]);

      expect(results[0], isTrue);
      expect(results[1], isFalse); // Blocked by guard
      expect(fakeSaveService.saveCallCount, 1); // Only called once!
    });

    test('Replace confirmation dialog flow (confirm -> replace)', () async {
      final notifier = ComparisonNotifier(
        initialSession: sampleSession,
        saveService: fakeSaveService,
        tempFileManager: TempFileManager(),
        ref: container.read(Provider((ref) => ref)),
      );

      notifier.showReplaceConfirmation();
      expect(notifier.state.saveStatus, SaveStatus.confirmingReplace);

      notifier.cancelReplaceConfirmation();
      expect(notifier.state.saveStatus, SaveStatus.idle);

      notifier.showReplaceConfirmation();
      expect(notifier.state.saveStatus, SaveStatus.confirmingReplace);

      final success = await notifier.confirmReplaceOriginal();
      expect(success, isTrue);
      expect(fakeSaveService.replaceCallCount, 1);
      expect(notifier.state.saveStatus, SaveStatus.replaced);
      expect(notifier.state.originalDeleted, isTrue);
    });

    test('Failure handling sets SaveStatus.failed without crashing', () async {
      fakeSaveService.shouldSucceed = false;

      final notifier = ComparisonNotifier(
        initialSession: sampleSession,
        saveService: fakeSaveService,
        tempFileManager: TempFileManager(),
        ref: container.read(Provider((ref) => ref)),
      );

      final success = await notifier.saveAsCopy();

      expect(success, isFalse);
      expect(notifier.state.saveStatus, SaveStatus.failed);
      expect(notifier.state.errorMessage, isNotNull);
      expect(notifier.state.isSuccess, isFalse);
    });
  });
}
