import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../services/permissions/permission_service.dart';

/// Riverpod StateNotifier driving media permission requests and state.
class PermissionNotifier extends StateNotifier<MediaPermissionState> {
  final PermissionService _permissionService;

  PermissionNotifier(this._permissionService) : super(MediaPermissionState.unknown);

  /// Checks current permission without prompting system dialog.
  Future<MediaPermissionState> checkPermission() async {
    final state = await _permissionService.checkMediaPermission();
    this.state = state;
    return state;
  }

  /// Prompts the system permission dialog.
  Future<MediaPermissionState> requestPermission() async {
    final state = await _permissionService.requestMediaPermission();
    this.state = state;
    return state;
  }

  /// Opens the device settings for the app.
  Future<void> openSettings() async {
    await _permissionService.openAppSettings();
  }

  /// Explicit state setter (useful for unit testing).
  void setPermissionForTesting(MediaPermissionState state) {
    this.state = state;
  }
}

/// Global provider for PermissionService.
final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PhotoManagerPermissionService();
});

/// Global provider for permission state.
final permissionProvider = StateNotifierProvider<PermissionNotifier, MediaPermissionState>((ref) {
  final service = ref.watch(permissionServiceProvider);
  return PermissionNotifier(service);
});
