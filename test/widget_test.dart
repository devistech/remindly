import 'package:flutter_test/flutter_test.dart';
import 'package:remindly/app.dart';

void main() {
  testWidgets('App should render', (WidgetTester tester) async {
    await tester.pumpWidget(const RemindlyApp());
    await tester.pumpAndSettle();
    expect(find.byType(RemindlyApp), findsOneWidget);
  });
}
