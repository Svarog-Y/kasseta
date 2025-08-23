import 'package:flutter_test/flutter_test.dart';
import 'package:kasseta/main.dart';

void main() {
  testWidgets('Phase 2 placeholder renders', (tester) async {
    await tester.pumpWidget(const KassetaApp());
    expect(find.text('Kasseta — Phase 2 OK'), findsOneWidget);
  });
}
