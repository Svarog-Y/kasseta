import 'package:flutter_test/flutter_test.dart';
import 'package:kasseta/data/datasources/local/html_store.dart';
import 'package:kasseta/data/datasources/remote/receipt_api.dart';
import 'package:kasseta/data/repositories/receipt_repository.dart';
import 'package:mocktail/mocktail.dart';

class _MockApi extends Mock implements ReceiptApi {}
class _MockStore extends Mock implements HtmlStore {}

void main() {
  test('fetchAndSaveLandingHtml fetches and persists file', () async {
    final api = _MockApi();
    final store = _MockStore();
    final repo = ReceiptRepositoryImpl(api: api, store: store);

    final url = Uri.parse('https://suf.purs.gov.rs/v/?vl=abc');
    when(() => api.fetchLandingHtml(url))
        .thenAnswer((_) async => '<html>demo</html>');

    final fakeUri = Uri.parse('file:///tmp/receipt-demo.html');
    when(() => store.saveHtml('<html>demo</html>'))
        .thenAnswer((_) async => fakeUri);

    final uri = await repo.fetchAndSaveLandingHtml(url);

    expect(uri, fakeUri);
    verify(() => api.fetchLandingHtml(url)).called(1);
    verify(() => store.saveHtml('<html>demo</html>')).called(1);
    verifyNoMoreInteractions(api);
    verifyNoMoreInteractions(store);
  });
}
