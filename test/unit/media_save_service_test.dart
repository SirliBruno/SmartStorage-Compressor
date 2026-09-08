import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_storage_compressor/services/media/media_save_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MediaSaveService Tests', () {
    late PhotoManagerMediaSaveService service;

    setUp(() {
      service = PhotoManagerMediaSaveService();
    });

    test('saveAsCopy rejects non-existent compressed file', () async {
      final result = await service.saveAsCopy(
        compressedPath: '/non/existent/path/video.mp4',
        title: 'Test',
      );

      expect(result.isSuccess, isFalse);
      expect(result.outcome, SaveOutcome.failed);
      expect(result.errorMessage, contains('not found'));
    });

    test('replaceOriginal preserves original when compressed file does not exist', () async {
      final result = await service.replaceOriginal(
        originalAssetId: 'orig_123',
        compressedPath: '/non/existent/path/video.mp4',
        title: 'Test',
      );

      expect(result.isSuccess, isFalse);
      expect(result.outcome, SaveOutcome.failed);
      expect(result.originalDeleted, isFalse);
      expect(result.errorMessage, contains('Original file preserved'));
    });

    test('verifySavedAsset returns false for invalid asset id', () async {
      final verified = await service.verifySavedAsset('non_existent_asset_id');
      expect(verified, isFalse);
    });
  });
}
