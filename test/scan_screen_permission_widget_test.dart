import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasseta/features/scan/application/scan_controller.dart';
import 'package:kasseta/features/scan/presentation/scan_screen.dart';

void main() {
  testWidgets('shows button when ScanNeedsPermission', (tester) async {
    final container = ProviderContainer(
      overrides: [
        scanControllerProvider.overrideWith(
          () => _StubController(const ScanNeedsPermission()),
        ),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ScanScreen()),
      ),
    );

    expect(find.text('Camera permission required.'), findsOneWidget);
    expect(find.text('Grant camera permission'), findsOneWidget);
  });
}

/// Minimal test double that returns a fixed initial [ScanState].
class _StubController extends ScanController {
  _StubController(this._initial);

  final ScanState _initial;

  @override
  ScanState build() => _initial;

  @override
  Future<void> initialize() async {}
}
