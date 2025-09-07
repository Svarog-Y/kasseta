import 'package:flutter_test/flutter_test.dart';
import 'package:kasseta/domain/parsing/receipt_landing_parser.dart';

void main() {
  group('ReceiptLandingParser.extractInvoice', () {
    test('reads invoice from DOM span #invoiceNumberLabel', () {
      const html = '''
<!DOCTYPE html><html><body>
  <div>
    <span id="invoiceNumberLabel">
      K8UBE2HN-K8UBE2HN-111060
    </span>
  </div>
</body></html>
''';
      final p = ReceiptLandingParser();
      final invoice = p.extractInvoice(html);
      expect(invoice, 'K8UBE2HN-K8UBE2HN-111060');
    });

    test('falls back to script when DOM node is missing', () {
      const html = '''
<!DOCTYPE html><html><body>
  <script type="text/javascript">
    viewModel.InvoiceNumber("A1B2C3D4-A1B2C3D4-12345");
  </script>
</body></html>
''';
      final p = ReceiptLandingParser();
      final invoice = p.extractInvoice(html);
      expect(invoice, 'A1B2C3D4-A1B2C3D4-12345');
    });

    test('throws when invoice is missing', () {
      const html = '''
<!DOCTYPE html><html><body>
  <script>/* no invoice here */</script>
</body></html>
''';
      final p = ReceiptLandingParser();
      expect(() => p.extractInvoice(html), throwsA(isA<FormatException>()));
    });

    test('throws when invoice format is invalid', () {
      const html = '''
<!DOCTYPE html><html><body>
  <span id="invoiceNumberLabel">BAD-FORMAT</span>
</body></html>
''';
      final p = ReceiptLandingParser();
      expect(() => p.extractInvoice(html), throwsA(isA<FormatException>()));
    });
  });
}
