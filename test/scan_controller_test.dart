import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasseta/app/di.dart';
import 'package:kasseta/features/scan/application/scan_controller.dart';
import 'package:kasseta/services/permissions_service.dart';

class _FakePermissionsGranted implements PermissionsService {
  @override
  Future<CameraPermissionStatus> checkCamera() async =>
      CameraPermissionStatus.granted;
  @override
  Future<CameraPermissionStatus> requestCamera() async =>
      CameraPermissionStatus.granted;
}

class _FakePermissionsDeniedOnce implements PermissionsService {
  bool _requested = false;

  @override
  Future<CameraPermissionStatus> checkCamera() async =>
      CameraPermissionStatus.denied;

  @override
  Future<CameraPermissionStatus> requestCamera() async {
    if (_requested) return CameraPermissionStatus.denied;
    _requested = true;
    return CameraPermissionStatus.granted;
  }
}

class _FakePermissionsPermanentlyDenied implements PermissionsService {
  @override
  Future<CameraPermissionStatus> checkCamera() async =>
      CameraPermissionStatus.permanentlyDenied;
  @override
  Future<CameraPermissionStatus> requestCamera() async =>
      CameraPermissionStatus.permanentlyDenied;
}

void main() {
  test('initialize -> granted -> ScanReady', () async {
    final container = ProviderContainer(
      overrides: [
        permissionsServiceProvider.overrideWithValue(
          _FakePermissionsGranted(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final ctrl = container.read(scanControllerProvider.notifier);
    await ctrl.initialize();
    expect(container.read(scanControllerProvider), isA<ScanReady>());
  });

  test('denied -> request -> granted -> ScanReady', () async {
    final container = ProviderContainer(
      overrides: [
        permissionsServiceProvider.overrideWithValue(
          _FakePermissionsDeniedOnce(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final ctrl = container.read(scanControllerProvider.notifier);
    await ctrl.initialize();
    expect(container.read(scanControllerProvider), isA<ScanNeedsPermission>());

    await ctrl.requestPermission();
    expect(container.read(scanControllerProvider), isA<ScanReady>());
  });

  test('permanently denied -> ScanPermissionPermanentlyDenied', () async {
    final container = ProviderContainer(
      overrides: [
        permissionsServiceProvider.overrideWithValue(
          _FakePermissionsPermanentlyDenied(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final ctrl = container.read(scanControllerProvider.notifier);
    await ctrl.initialize();
    expect(
      container.read(scanControllerProvider),
      isA<ScanPermissionPermanentlyDenied>(),
    );
  });
}
