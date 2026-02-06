import 'package:flutter_test/flutter_test.dart';
import 'package:truemed_user/main.dart';

void main() {
  testWidgets('App starts and shows home view', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TrueMedUserApp());

    // Verify that our app name is shown in the app bar.
    expect(find.text('TrueMed'), findsOneWidget);
    
    // Verify that the search bar is present.
    expect(find.text('Search medicines...'), findsOneWidget);
  });
}
