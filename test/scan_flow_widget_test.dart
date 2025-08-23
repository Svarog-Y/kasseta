import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasseta/app/di.dart';
import 'package:kasseta/domain/parsing/receipt_url_parser.dart';
import 'package:kasseta/features/scan/application/scan_controller.dart';
import 'package:kasseta/features/scan/presentation/scan_screen.dart';

class _ParserOk extends ReceiptUrlParser {
  @override
  ReceiptUrlTokens? parse(Uri uri) =>
      const ReceiptUrlTokens(vl: 'ok');
}

void main() {
  testWidgets('scan -> onQrFound -> shows ScanFound', (tester) async {
    final container = ProviderContainer(
      overrides: [
        // Ready to scan
        scanControllerProvider.overrideWith(
          () => _StubController(const ScanReady()),
        ),
        // Deterministic parser
        receiptUrlParserProvider.overrideWithValue(_ParserOk()),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(home: ScanScreen()),
      ),
    );

    // Drive the controller as if scanner emitted a value.
    final ctrl = container.read(scanControllerProvider.notifier);
    await ctrl.onQrFound('https://suf.purs.gov.rs/v/?vl=test');

    await tester.pump();

    expect(find.text('QR captured.'), findsOneWidget);
  });
}

class _StubController extends ScanController {
  _StubController(this._initial);

  final ScanState _initial;

  @override
  ScanState build() => _initial;

  @override
  Future<void> initialize() async {}
}
