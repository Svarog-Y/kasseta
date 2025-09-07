// This test file intentionally ignores `avoid_slow_async_io`.
//
// - `avoid_slow_async_io`:
//   Tests use `Directory.systemTemp` and `File.readAsString` to validate
//   that `HtmlStoreImpl` really writes files to disk.
//   These I/O calls are slow compared to in-memory ops, but here they are
//   deliberate to assert correctness of file persistence.
//
// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kasseta/data/datasources/local/html_store.dart';

/// Fake dir provider that points to a temp directory on the host.
class _TempDirProvider implements AppFilesDirProvider {
  _TempDirProvider(this.tempRoot);

  final Directory tempRoot;

  @override
  Future<Directory> getAppFilesDir() async {
    if (!await tempRoot.exists()) {
      await tempRoot.create(recursive: true);
    }
    return tempRoot;
  }
}

void main() {
  test('HtmlStoreImpl saves html to a timestamped file', () async {
    final root =
        await Directory.systemTemp.createTemp('kasseta_html_store_test_');
    addTearDown(() => root.delete(recursive: true));

    final store = HtmlStoreImpl(_TempDirProvider(root));
    final uri = await store.saveHtml('<html><body>ok</body></html>');

    final saved = File.fromUri(uri);
    expect(await saved.exists(), isTrue);
    final content = await saved.readAsString();
    expect(content, contains('ok'));

    // Checks folder convention.
    expect(saved.path, contains('${root.path}${Platform.pathSeparator}'));
    expect(saved.path, contains('receipts'));
    expect(saved.path, contains('.html'));
  });
}
