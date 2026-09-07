import 'package:photo_manager/photo_manager.dart';
import '../../core/utils/logger.dart';
import '../../features/onboarding/domain/models/permission_models.dart';

export '../../features/onboarding/domain/models/permission_models.dart';

/// Service abstraction managing media access permissions for iOS and Android.
abstract class PermissionService {
  Future<MediaPermissionState> checkMediaPermission();
  Future<MediaPermissionState> requestMediaPermission();
  Future<void> openAppSettings();
}

class PhotoManagerPermissionService implements PermissionService {
  @override
  Future<MediaPermissionState> checkMediaPermission() async {
    try {
      final state = await PhotoManager.requestPermissionExtend();
      return _mapPermissionState(state);
    } catch (e, stack) {
      AppLogger.error('Error checking media permissions', e, stack);
      return MediaPermissionState.denied;
    }
  }

  @override
  Future<MediaPermissionState> requestMediaPermission() async {
    try {
      final state = await PhotoManager.requestPermissionExtend();
      return _mapPermissionState(state);
    } catch (e, stack) {
      AppLogger.error('Error requesting media permissions', e, stack);
      return MediaPermissionState.denied;
    }
  }

  @override
  Future<void> openAppSettings() async {
    try {
      await PhotoManager.openSetting();
    } catch (e, stack) {
      AppLogger.error('Error opening system settings', e, stack);
    }
  }

  MediaPermissionState _mapPermissionState(PermissionState state) {
    if (state.isAuth) return MediaPermissionState.granted;
    if (state.hasAccess) return MediaPermissionState.limited;
    // iOS Device restricted (e.g. Screen Time / MDM restrictions)
    if (state == PermissionState.restricted) return MediaPermissionState.restricted;
    if (state == PermissionState.notDetermined) return MediaPermissionState.unknown;
    return MediaPermissionState.denied;
  }
}
