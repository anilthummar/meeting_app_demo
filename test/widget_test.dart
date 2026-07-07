import 'package:flutter_test/flutter_test.dart';

import 'package:meeting_app/core/app.dart';

void main() {
  testWidgets('Home screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const MeetingApp());

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Create Meeting'), findsOneWidget);
    expect(find.text('Join Meeting'), findsOneWidget);
  });
}
