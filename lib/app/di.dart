import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasseta/data/datasources/local/html_store.dart';
import 'package:kasseta/data/datasources/remote/receipt_api.dart';
import 'package:kasseta/data/repositories/receipt_repository.dart';
import 'package:kasseta/domain/parsing/receipt_url_parser.dart';
import 'package:kasseta/services/permissions_service.dart';

/// Global provider that exposes the concrete [PermissionsService].
///
/// In tests we override this with fakes to simulate different OS states.
final permissionsServiceProvider = Provider<PermissionsService>(
  (ref) => PermissionsServiceImpl(),
);

/// Global provider for the SUF receipt URL parser.
final receiptUrlParserProvider = Provider<ReceiptUrlParser>(
  (ref) => ReceiptUrlParser(),
);

/// Provides a configured Dio client.
///
/// Follows redirects and accepts HTML responses.
final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(
    BaseOptions(
      followRedirects: true,
      validateStatus: (code) => code != null && code < 500,
      headers: <String, String>{
        'accept': 'text/html,application/xhtml+xml',
        'accept-language': 'sr-RS,sr;q=0.9,en;q=0.8',
        'cache-control': 'no-cache',
      },
    ),
  );
  return dio;
});

/// Remote API for fetching landing HTML.
final receiptApiProvider = Provider<ReceiptApi>((ref) {
  final dio = ref.watch(dioProvider);
  return ReceiptApi(dio: dio);
});

/// Local store for saving HTML files and sharing them.
final htmlStoreProvider = Provider<HtmlStore>((ref) {
  return HtmlStoreImpl(AppFilesDirProviderImpl());
});

/// Repository that fetches and saves landing HTML.
final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  final api = ref.watch(receiptApiProvider);
  final store = ref.watch(htmlStoreProvider);
  return ReceiptRepositoryImpl(api: api, store: store);
});
