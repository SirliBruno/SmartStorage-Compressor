import 'package:smart_storage_compressor/services/media/media_scanner.dart';
import 'package:smart_storage_compressor/features/onboarding/presentation/controllers/scan_controller.dart';
import 'package:test/test.dart';

class MockMediaScanner implements MediaScanner {
  final List<ScanProgressUpdate> simulatedUpdates;

  MockMediaScanner({required this.simulatedUpdates});

  @override
  Stream<ScanProgressUpdate> scanLibrary({ScanCancellationToken? cancellationToken}) async* {
    for (final update in simulatedUpdates) {
      if (cancellationToken?.isCancelled == true) {
        return;
      }
      yield update;
    }
  }
}

void main() {
  group('MediaScanner & ScanController Tests', () {
    test('ScanResultData.empty correctly flags hasMedia as false', () {
      const data = ScanResultData.empty;
      expect(data.hasMedia, isFalse);
      expect(data.videoCount, equals(0));
      expect(data.screenshotCount, equals(0));
      expect(data.estimatedRecoverableBytes, equals(0));
    });

    test('ScanResultData with discovered media correctly flags hasMedia as true', () {
      const data = ScanResultData(
        videoCount: 12,
        screenshotCount: 45,
        totalScannedBytes: 1500000000,
        estimatedRecoverableBytes: 950000000,
        isCompleted: true,
      );

      expect(data.hasMedia, isTrue);
      expect(data.videoCount, equals(12));
      expect(data.screenshotCount, equals(45));
      expect(data.estimatedRecoverableBytes, equals(950000000));
      expect(data.isCompleted, isTrue);
    });

    test('ScanNotifier progresses from scanning to success with simulated scanner', () async {
      final mockScanner = MockMediaScanner(
        simulatedUpdates: [
          const ScanProgressUpdate(
            progress: 0.25,
            currentTaskKey: 'taskVideos',
            partialResult: ScanResultData(videoCount: 5),
          ),
          const ScanProgressUpdate(
            progress: 0.65,
            currentTaskKey: 'taskScreenshots',
            partialResult: ScanResultData(videoCount: 5, screenshotCount: 10),
          ),
          const ScanProgressUpdate(
            progress: 1.0,
            currentTaskKey: 'scanResultHeader',
            partialResult: ScanResultData(
              videoCount: 5,
              screenshotCount: 10,
              totalScannedBytes: 500000000,
              estimatedRecoverableBytes: 300000000,
              isCompleted: true,
            ),
          ),
        ],
      );

      final notifier = ScanNotifier(mockScanner);
      expect(notifier.state.status, equals(ScanStatus.idle));

      notifier.startScan();
      expect(notifier.state.status, equals(ScanStatus.scanning));

      // Wait for stream to deliver events
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(notifier.state.status, equals(ScanStatus.success));
      expect(notifier.state.progress, equals(1.0));
      expect(notifier.state.result.videoCount, equals(5));
      expect(notifier.state.result.screenshotCount, equals(10));
      expect(notifier.state.result.estimatedRecoverableBytes, equals(300000000));
    });

    test('cancelScan() halts in-progress scanning and updates status to cancelled', () async {
      final mockScanner = MockMediaScanner(
        simulatedUpdates: [
          const ScanProgressUpdate(
            progress: 0.25,
            currentTaskKey: 'taskVideos',
            partialResult: ScanResultData(videoCount: 2),
          ),
        ],
      );

      final notifier = ScanNotifier(mockScanner);
      notifier.startScan();
      expect(notifier.state.isScanning, isTrue);

      notifier.cancelScan();
      expect(notifier.state.status, equals(ScanStatus.cancelled));
      expect(notifier.state.isCancelled, isTrue);
      expect(notifier.state.currentTaskKey, equals('scanCancelledTitle'));
    });
  });
}
