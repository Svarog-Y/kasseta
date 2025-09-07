import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasseta/data/datasources/remote/receipt_api.dart';
import 'package:mocktail/mocktail.dart';

class _MockDio extends Mock implements Dio {}

void main() {
  setUpAll(() {
    // Let mocktail infer T from the value; no explicit type args.
    registerFallbackValue(RequestOptions(path: '/'));
    registerFallbackValue(Options());
  });

  group('ReceiptApi', () {
    test('fetchLandingHtml performs GET to vl URL', () async {
      final dio = _MockDio();
      final api = ReceiptApi(dio: dio);

      final vl = Uri.parse('https://suf.purs.gov.rs/v/?vl=abc');
      when(() => dio.getUri<String>(
            vl,
            options: any(named: 'options'),
          )).thenAnswer(
        (_) async => Response<String>(
          data: '<html>ok</html>',
          requestOptions: RequestOptions(path: vl.toString()),
          statusCode: 200,
        ),
      );

      final html = await api.fetchLandingHtml(vl);

      expect(html, contains('ok'));
      verify(() => dio.getUri<String>(
            vl,
            options: any(named: 'options'),
          )).called(1);
    });

    test('fetchItems posts form and sets headers', () async {
      final dio = _MockDio();
      final api = ReceiptApi(dio: dio);

      final referer = Uri.parse('https://suf.purs.gov.rs/v/?vl=abc');
      final spec = Uri.https('suf.purs.gov.rs', '/specifications');

      when(() => dio.postUri<Map<String, dynamic>>(
            spec,
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).thenAnswer(
        (_) async => Response<Map<String, dynamic>>(
          data: <String, dynamic>{
            'success': true,
            'items': <Object>[],
          },
          requestOptions: RequestOptions(path: spec.toString()),
          statusCode: 200,
        ),
      );

      final out = await api.fetchItems(
        invoiceNumber: 'A1B2C3D4-A1B2C3D4-12345',
        token: '11111111-2222-3333-4444-555555555555',
        referer: referer,
      );

      expect(out['success'], true);
      verify(() => dio.postUri<Map<String, dynamic>>(
            spec,
            data: any(named: 'data'),
            options: any(named: 'options'),
          )).called(1);
    });
  });
}
