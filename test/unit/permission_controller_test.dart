import 'package:smart_storage_compressor/services/permissions/permission_service.dart';
import 'package:smart_storage_compressor/features/onboarding/presentation/controllers/permission_controller.dart';
import 'package:test/test.dart';

class MockPermissionService implements PermissionService {
  MediaPermissionState stubbedState = MediaPermissionState.unknown;
  bool openSettingsCalled = false;

  @override
  Future<MediaPermissionState> checkMediaPermission() async => stubbedState;

  @override
  Future<MediaPermissionState> requestMediaPermission() async => stubbedState;

  @override
  Future<void> openAppSettings() async {
    openSettingsCalled = true;
  }
}

void main() {
  group('PermissionController Tests', () {
    late MockPermissionService mockService;
    late PermissionNotifier notifier;

    setUp(() {
      mockService = MockPermissionService();
      notifier = PermissionNotifier(mockService);
    });

    test('Initial permission state is unknown', () {
      expect(notifier.state, equals(MediaPermissionState.unknown));
    });

    test('requestPermission() updates state to granted when accepted', () async {
      mockService.stubbedState = MediaPermissionState.granted;
      final result = await notifier.requestPermission();

      expect(result, equals(MediaPermissionState.granted));
      expect(notifier.state, equals(MediaPermissionState.granted));
    });

    test('requestPermission() updates state to limited when user selects limited photos', () async {
      mockService.stubbedState = MediaPermissionState.limited;
      final result = await notifier.requestPermission();

      expect(result, equals(MediaPermissionState.limited));
      expect(notifier.state, equals(MediaPermissionState.limited));
    });

    test('requestPermission() updates state to denied when rejected', () async {
      mockService.stubbedState = MediaPermissionState.denied;
      final result = await notifier.requestPermission();

      expect(result, equals(MediaPermissionState.denied));
      expect(notifier.state, equals(MediaPermissionState.denied));
    });

    test('requestPermission() updates state to restricted when parental/MDM profile active', () async {
      mockService.stubbedState = MediaPermissionState.restricted;
      final result = await notifier.requestPermission();

      expect(result, equals(MediaPermissionState.restricted));
      expect(notifier.state, equals(MediaPermissionState.restricted));
    });

    test('openSettings() invokes openAppSettings on service', () async {
      await notifier.openSettings();
      expect(mockService.openSettingsCalled, isTrue);
    });
  });
}
