import 'package:flutter_test/flutter_test.dart';
import 'package:mausam/main.dart';

void main() {
  testWidgets('App smoke test renders onboarding', (WidgetTester tester) async {
    await tester.pumpWidget(const MausamApp());
    expect(find.text('MAUSAM'), findsWidgets);
    expect(find.text('CONTINUE'), findsOneWidget);
  });
}
