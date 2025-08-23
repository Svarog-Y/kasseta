import 'package:flutter_test/flutter_test.dart';
import 'package:kasseta/domain/parsing/receipt_url_parser.dart';

void main() {
  group('ReceiptUrlParser', () {
    final p = ReceiptUrlParser();

    test('parses valid SUF URL with vl', () {
      final uri = Uri.parse(
        'https://suf.purs.gov.rs/v/?vl=a%2Fb%3D1',
      );
      final t = p.parse(uri);
      expect(t, isNotNull);
      expect(t!.vl, 'a/b=1');
    });

    test('rejects wrong host', () {
      final uri = Uri.parse('https://example.com/v/?vl=x');
      expect(p.parse(uri), isNull);
    });

    test('rejects missing vl', () {
      final uri = Uri.parse('https://suf.purs.gov.rs/v/?nope=y');
      expect(p.parse(uri), isNull);
    });
  });
}
