import 'package:dio/dio.dart';

/// API client for SUF receipt pages and items endpoint.
class ReceiptApi {
  /// Creates a new [ReceiptApi] with a configured [dio].
  const ReceiptApi({required this.dio});

  /// Underlying HTTP client.
  final Dio dio;

  /// Fetches landing HTML for the given `vl` URL.
  ///
  /// Returns the raw HTML string. Caller may parse it to extract tokens.
  Future<String> fetchLandingHtml(Uri vlUrl) async {
    final res = await dio.getUri<String>(
      vlUrl,
      options: Options(
        responseType: ResponseType.plain,
        headers: <String, String>{
          'accept': 'text/html,application/xhtml+xml',
          'accept-language': 'sr-RS,sr;q=0.9,en;q=0.8',
          'cache-control': 'no-cache',
        },
      ),
    );
    return res.data ?? '';
  }

  /// Calls `/specifications` with `invoiceNumber` and `token`.
  ///
  /// The `referer` must be the landing page URL (the `vl` page).
  /// Returns the decoded JSON map from SUF.
  Future<Map<String, dynamic>> fetchItems({
    required String invoiceNumber,
    required String token,
    required Uri referer,
    String localization = 'sr-Cyrl-RS',
  }) async {
    final uri = Uri.https('suf.purs.gov.rs', '/specifications');

    final body = <String, String>{
      'invoiceNumber': invoiceNumber,
      'token': token,
    };

    final res = await dio.postUri<Map<String, dynamic>>(
      uri,
      data: body, // x-www-form-urlencoded
      options: Options(
        contentType: 'application/x-www-form-urlencoded; charset=UTF-8',
        responseType: ResponseType.json,
        headers: <String, String>{
          'accept': '*/*',
          'origin': 'https://suf.purs.gov.rs',
          'referer': referer.toString(),
          'x-requested-with': 'XMLHttpRequest',
          'cookie': 'localization=$localization',
        },
      ),
    );

    final data = res.data;
    if (data != null) return data;

    throw const FormatException('Unexpected items response shape.');
  }
}
