// This file intentionally ignores some lints:
//
// - `one_member_abstracts`:
//   We keep `AppFilesDirProvider` and `HtmlStore` as abstract seams even
//   though they currently have only one member.
//   Reason: they make it possible to inject fakes in tests and to swap
//   implementations (e.g. move from in-memory to SQLite) without touching
//   controllers/UI.
//
// - `avoid_slow_async_io`:
//   This file uses `dart:io` operations (`Directory.exists`,
//   `File.writeAsString`) which are flagged as "slow".
//   Reason: these operations are necessary for writing HTML to disk and are
//   acceptable in this I/O-specific infrastructure layer.
//
// ignore_for_file: one_member_abstracts, avoid_slow_async_io

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Provides a writable app files directory.
///
/// Abstracted for tests so we can inject a temp folder.
abstract class AppFilesDirProvider {
  /// Returns the directory used for app documents / files.
  Future<Directory> getAppFilesDir();
}

/// Production impl using path_provider.
class AppFilesDirProviderImpl implements AppFilesDirProvider {
  @override
  Future<Directory> getAppFilesDir() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir;
  }
}

/// Stores HTML files locally and provides sharing helpers.
abstract class HtmlStore {
  /// Saves the HTML text to a timestamped .html file and returns its URI.
  Future<Uri> saveHtml(String html);

  /// Shares an already saved file at [fileUri].
  Future<void> shareFile(Uri fileUri);
}

/// Implementation that writes to the app's documents directory.
class HtmlStoreImpl implements HtmlStore {
  /// Creates an instance with an [AppFilesDirProvider].
  HtmlStoreImpl(this.dirProvider);

  /// Provider of the base directory to store files.
  final AppFilesDirProvider dirProvider;

  @override
  Future<Uri> saveHtml(String html) async {
    final base = await dirProvider.getAppFilesDir();
    final folder = Directory('${base.path}/receipts');
    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }
    final ts = DateTime.now().toIso8601String().replaceAll(':', '-');
    final file = File('${folder.path}/receipt-$ts.html');
    await file.writeAsString(html, flush: true);
    return file.uri;
  }

  @override
  Future<void> shareFile(Uri fileUri) async {
    // Use XFile(path) — fromUri is not available on all platforms.
    final path = fileUri.toFilePath();
    final xf = XFile(
      path,
      mimeType: 'text/html',
      name: path.split(Platform.pathSeparator).last,
    );
    await Share.shareXFiles(<XFile>[xf], text: 'SUF receipt HTML');
  }
}
