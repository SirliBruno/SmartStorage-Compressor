import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_storage_compressor/core/localization/app_localizations.dart';
import 'package:smart_storage_compressor/features/video_compressor/domain/models/compression_result.dart';
import 'package:smart_storage_compressor/features/video_compressor/domain/models/compression_session.dart';
import 'package:smart_storage_compressor/features/video_compressor/domain/models/video_asset.dart';
import 'package:smart_storage_compressor/features/video_compressor/presentation/screens/compression_comparison_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CompressionComparisonScreen Widget Tests', () {
    late CompressionSession testSession;

    setUp(() {
      final video = VideoAsset(
        id: 'widget_test_1',
        localIdentifier: 'widget_test_1',
        path: '/dummy/path.mp4',
        title: 'WidgetTestVideo',
        fileSizeBytes: 200 * 1024 * 1024, // 200 MB
        duration: const Duration(seconds: 60),
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
        outputPath: '/dummy/out.mp4',
        originalSize: 200 * 1024 * 1024,
        compressedSize: 50 * 1024 * 1024, // 50 MB (75% savings)
        duration: const Duration(seconds: 60),
        processingTime: const Duration(seconds: 10),
        targetResolutionWidth: 1280,
        targetResolutionHeight: 720,
        targetCodec: 'H.264 (AVC)',
      );

      testSession = CompressionSession.fromResult(
        originalAsset: video,
        result: result,
      );
    });

    Widget createTestWidget() {
      return ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: CompressionComparisonScreen(session: testSession),
        ),
      );
    }

    testWidgets('Renders comparison stats card and savings badge correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Check savings badge exists with ~75.0%
      expect(find.textContaining('75.0%'), findsOneWidget);

      // Check Original and Compressed sizes are formatted
      expect(find.textContaining('200.0 MB'), findsOneWidget);
      expect(find.text('50.0 MB'), findsOneWidget);

      // Check resolutions are shown
      expect(find.text('1920x1080'), findsOneWidget);
      expect(find.text('1280x720'), findsOneWidget);
    });

    testWidgets('Renders action buttons and opens replace confirmation dialog', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Find Save as Copy and Replace Original buttons
      final saveCopyButton = find.text('Save as Copy');
      final replaceButton = find.text('Replace Original');

      expect(saveCopyButton, findsOneWidget);
      expect(replaceButton, findsOneWidget);

      // Tap Replace Original button
      await tester.ensureVisible(replaceButton);
      await tester.tap(replaceButton);
      await tester.pump(const Duration(milliseconds: 200));

      // Verify confirmation dialog appears
      expect(find.text('Replace Original Video?'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
