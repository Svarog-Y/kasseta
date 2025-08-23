import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasseta/app/di.dart';
import 'package:kasseta/services/permissions_service.dart';

/// Immutable UI state for the Scan feature.
sealed class ScanState {
  /// Creates a new [ScanState].
  const ScanState();
}

/// Initial state before we know camera permission.
class ScanIdle extends ScanState {
  /// Creates a new [ScanIdle] state.
  const ScanIdle();
}

/// We need to ask the user for camera permission.
class ScanNeedsPermission extends ScanState {
  /// Creates a new [ScanNeedsPermission] state.
  const ScanNeedsPermission();
}

/// We are currently prompting the user.
class ScanRequestingPermission extends ScanState {
  /// Creates a new [ScanRequestingPermission] state.
  const ScanRequestingPermission();
}

/// Camera permission is available and we can start the scanner.
class ScanReady extends ScanState {
  /// Creates a new [ScanReady] state.
  const ScanReady();
}

/// User permanently denied camera permission (needs system settings).
class ScanPermissionPermanentlyDenied extends ScanState {
  /// Creates a new [ScanPermissionPermanentlyDenied] state.
  const ScanPermissionPermanentlyDenied();
}

/// Generic error surfaced to the UI.
class ScanError extends ScanState {
  /// Creates a new [ScanError] state with the given message.
  const ScanError(this.message);
  
  /// The error message to display to the user.
  final String message;
}

/// Global Riverpod provider for the Scan feature.
///
/// Exposes the [ScanController] and its current [ScanState].
/// Can be overridden in tests to inject fakes or stubs.
final scanControllerProvider =
    NotifierProvider<ScanController, ScanState>(ScanController.new);

/// Orchestrates permission checks and (soon) scanning.
class ScanController extends Notifier<ScanState> {
  /// Creates a new [ScanController].
  ScanController();

  @override
  ScanState build() => const ScanIdle();
  
  /// Returns the [PermissionsService] instance.
  PermissionsService get _permissions =>
      ref.read(permissionsServiceProvider);

  /// Check current camera permission and set the appropriate state.
  Future<void> initialize() async {
    final status = await _permissions.checkCamera();
    switch (status) {
      case CameraPermissionStatus.granted:
        state = const ScanReady();
      case CameraPermissionStatus.permanentlyDenied:
      case CameraPermissionStatus.restricted:
        state = const ScanPermissionPermanentlyDenied();
      case CameraPermissionStatus.denied:
      case CameraPermissionStatus.limited:
      case CameraPermissionStatus.unknown:
        state = const ScanNeedsPermission();
    }
  }

  /// Request camera permission from the user.
  Future<void> requestPermission() async {
    state = const ScanRequestingPermission();
    final status = await _permissions.requestCamera();
    switch (status) {
      case CameraPermissionStatus.granted:
        state = const ScanReady();
      case CameraPermissionStatus.permanentlyDenied:
      case CameraPermissionStatus.restricted:
        state = const ScanPermissionPermanentlyDenied();
      case CameraPermissionStatus.denied:
      case CameraPermissionStatus.limited:
      case CameraPermissionStatus.unknown:
        state = const ScanNeedsPermission();
    }
  }
}
