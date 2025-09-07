import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasseta/app/di.dart';
import 'package:kasseta/data/repositories/receipt_repository.dart';
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

/// QR found; contains the decoded URI.
class ScanFound extends ScanState {
  /// Creates a [ScanFound] state.
  const ScanFound(this.uri);

  /// The QR as a [Uri].
  final Uri uri;
}

/// We are fetching and saving the landing HTML locally.
class ScanSavingHtml extends ScanState {
  /// Creates a [ScanSavingHtml] state.
  const ScanSavingHtml(this.uri);

  /// The QR as a [Uri].
  final Uri uri;
}

/// Landing HTML was saved to a local file (app docs directory).
class ScanSavedHtml extends ScanState {
  /// Creates a [ScanSavedHtml] state.
  const ScanSavedHtml({
    required this.qrUri,
    required this.fileUri,
  });

  /// The QR as a [Uri].
  final Uri qrUri;

  /// The saved file location (file:// URI).
  final Uri fileUri;
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

/// Orchestrates permission checks, scanning, and saving landing HTML.
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

  /// Handle a raw QR payload from the scanner.
  ///
  /// Flow:
  ///  - Parse raw → [Uri]
  ///  - Validate via [receiptUrlParserProvider]
  ///  - Emit [ScanFound]
  ///  - Fetch landing HTML and save → [ScanSavingHtml] → [ScanSavedHtml]
  Future<void> onQrFound(String raw) async {
    Uri? uri;
    try {
      uri = Uri.tryParse(raw);
    } on FormatException {
      uri = null;
    }
    if (uri == null) {
      state = const ScanError('Invalid QR content.');
      return;
    }

    // Validate SUF URL and extract tokens (used later).
    final parser = ref.read(receiptUrlParserProvider);
    final tokens = parser.parse(uri);
    if (tokens == null) {
      state = const ScanError('Not a valid SUF URL.');
      return;
    }

    // Announce the QR first.
    state = ScanFound(uri);

    // Fetch and save the landing HTML file.
    state = ScanSavingHtml(uri);
    try {
      final repo = ref.read(receiptRepositoryProvider);
      final fileUri = await repo.fetchAndSaveLandingHtml(uri);
      state = ScanSavedHtml(qrUri: uri, fileUri: fileUri);
    } catch (e) {
      state = ScanError('Failed to save HTML: $e');
    }
  }

  /// Share a previously saved landing HTML file with the platform share
  /// sheet. No-op if repository throws; errors should be handled by UI.
  Future<void> shareSavedHtml(Uri fileUri) async {
    final repo = ref.read(receiptRepositoryProvider);
    await repo.shareSavedHtml(fileUri);
  }
}
