import 'package:flutter_test/flutter_test.dart';
import 'package:kasseta/domain/parsing/receipt_landing_parser.dart';

void main() {
  group('ReceiptLandingParser.parse', () {
    test('returns both values when present (DOM + script)', () {
      const html = '''
<!DOCTYPE html><html><body>
  <span id="invoiceNumberLabel">
    K8UBE2HN-K8UBE2HN-111060
  </span>
  <script>
    viewModel.Token('fa2406dd-a0fc-4418-be1c-ebc95d8b90f0');
  </script>
</body></html>
''';
      final p = ReceiptLandingParser();
      final tokens = p.parse(html);

      expect(tokens.invoiceNumber, 'K8UBE2HN-K8UBE2HN-111060');
      expect(tokens.token, 'fa2406dd-a0fc-4418-be1c-ebc95d8b90f0');
    });

    test('throws when either token or invoice is missing', () {
      const htmlMissingToken = '''
<!DOCTYPE html><html><body>
  <span id="invoiceNumberLabel">A1B2C3D4-A1B2C3D4-12345</span>
</body></html>
''';
      final p = ReceiptLandingParser();

      expect(() => p.parse(htmlMissingToken),
          throwsA(isA<FormatException>()));
    });
  });
}
