import 'dart:async';

import 'package:kasseta/data/datasources/local/html_store.dart';
import 'package:kasseta/data/datasources/remote/receipt_api.dart';

/// Repository for fetching and storing receipt landing HTML.
///
/// This abstracts the data flow away from controllers and widgets.
abstract class ReceiptRepository {
  /// Fetches landing HTML for [qrUrl] and stores it as a .html file.
  ///
  /// Returns the URI of the saved file.
  Future<Uri> fetchAndSaveLandingHtml(Uri qrUrl);

  /// Shares a previously saved file by URI.
  Future<void> shareSavedHtml(Uri fileUri);
}

/// Default implementation using [ReceiptApi] and [HtmlStore].
class ReceiptRepositoryImpl implements ReceiptRepository {
  /// Creates a repository with a remote API and local store.
  ReceiptRepositoryImpl({required this.api, required this.store});

  /// Remote API client.
  final ReceiptApi api;

  /// Local HTML store.
  final HtmlStore store;

  @override
  Future<Uri> fetchAndSaveLandingHtml(Uri qrUrl) async {
    final html = await api.fetchLandingHtml(qrUrl);
    final uri = await store.saveHtml(html);
    return uri;
  }

  @override
  Future<void> shareSavedHtml(Uri fileUri) => store.shareFile(fileUri);
}
