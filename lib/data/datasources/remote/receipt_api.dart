import 'package:dio/dio.dart';

/// Simple API for fetching the landing HTML for a SUF receipt page.
class ReceiptApi {
  /// Creates an instance backed by Dio.
  const ReceiptApi({required this.dio});

  /// The underlying HTTP client.
  final Dio dio;

  /// Fetch the landing HTML for the given QR URL.
  ///
  /// The server may redirect; Dio is configured to follow redirects.
  Future<String> fetchLandingHtml(Uri url) async {
    final res = await dio.getUri<String>(url);
    return res.data ?? '';
  }
}
