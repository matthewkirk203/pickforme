import 'package:flutter_test/flutter_test.dart';

import 'package:pick_for_me/main.dart';

void main() {
  testWidgets('App builds and shows category cards', (WidgetTester tester) async {
    await tester.pumpWidget(const PickForMeApp());
    await tester.pumpAndSettle();

    expect(find.text('Pick For Me'), findsWidgets);
    expect(find.text('Outside'), findsOneWidget);
    expect(find.text('Creative'), findsOneWidget);
    expect(find.text('Relaxing'), findsOneWidget);
    expect(find.text('Physical'), findsOneWidget);
  });
}