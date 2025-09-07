import 'package:flutter_test/flutter_test.dart';
import 'package:kasseta/domain/parsing/receipt_landing_parser.dart';

void main() {
  group('ReceiptLandingParser.extractToken', () {
    test('extracts token from inline script (single quotes)', () {
      const html = '''
<!DOCTYPE html><html><head></head><body>
<script>
  viewModel = new ViewModel();
  viewModel.Token('fa2406dd-a0fc-4418-be1c-ebc95d8b90f0');
</script>
</body></html>
''';
      final p = ReceiptLandingParser();
      final token = p.extractToken(html);
      expect(token, 'fa2406dd-a0fc-4418-be1c-ebc95d8b90f0');
    });

    test('extracts token with double quotes and whitespace', () {
      const html = '''
<html><body>
<script type="text/javascript">
  viewModel.Token(   "11111111-2222-3333-4444-555555555555"   );
</script>
</body></html>
''';
      final p = ReceiptLandingParser();
      final token = p.extractToken(html);
      expect(token, '11111111-2222-3333-4444-555555555555');
    });

    test('throws when token is missing', () {
      const html = '''
<html><body>
<script> /* no token here */ </script>
</body></html>
''';
      final p = ReceiptLandingParser();
      expect(() => p.extractToken(html), throwsA(isA<FormatException>()));
    });
  });
}
