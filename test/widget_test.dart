import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kasseta/app/app.dart';

void main() {
  testWidgets('Initial route shows Scan screen', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: KassetaApp()));
    expect(find.text('Kasseta — Scan'), findsOneWidget);
    expect(
      find.text('Scan screen ready. (Camera coming next)'),
      findsOneWidget,
    );
  });
}
