import 'package:permission_handler/permission_handler.dart';

/// App-level camera permission status used across the UI and controller.
enum CameraPermissionStatus {
  /// Permission was granted by the user.
  granted,

  /// Permission is currently denied, but may be requested again.
  denied,

  /// User selected “Don’t ask again” / permanently denied.
  permanentlyDenied,

  /// iOS parental controls or MDM restrictions.
  restricted,

  /// iOS limited access state (not typical for camera).
  limited,

  /// Fallback when we can’t map the platform status (should not appear).
  unknown,
}

/// Abstraction around camera permission so it’s easy to mock in tests.
abstract class PermissionsService {
  /// Returns the current camera permission status without prompting the user.
  Future<CameraPermissionStatus> checkCamera();

  /// Prompts the user for camera permission and returns the new status.
  Future<CameraPermissionStatus> requestCamera();
}

/// Real implementation using package:permission_handler.
class PermissionsServiceImpl implements PermissionsService {
  @override
  Future<CameraPermissionStatus> checkCamera() async {
    final status = await Permission.camera.status;
    return _map(status);
  }

  @override
  Future<CameraPermissionStatus> requestCamera() async {
    final status = await Permission.camera.request();
    return _map(status);
  }

  CameraPermissionStatus _map(PermissionStatus s) {
    switch (s) {
      case PermissionStatus.granted:
        return CameraPermissionStatus.granted;
      case PermissionStatus.denied:
        return CameraPermissionStatus.denied;
      case PermissionStatus.permanentlyDenied:
        return CameraPermissionStatus.permanentlyDenied;
      case PermissionStatus.restricted:
        return CameraPermissionStatus.restricted;
      case PermissionStatus.limited:
        return CameraPermissionStatus.limited;
      case PermissionStatus.provisional:
        return CameraPermissionStatus.unknown;
    }
  }
}
