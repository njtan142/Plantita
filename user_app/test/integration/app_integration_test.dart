
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:user_app/main.dart' as app;
import 'package:user_app/ui/widgets/touch_friendly_button.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await dotenv.load(fileName: ".env.test");
  });

  group('end-to-end test', () {
    testWidgets('app starts and shows login screen initially (since not authenticated)', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify that the app starts and the login screen is displayed initially
      expect(find.text('Login'), findsWidgets);
    });

    testWidgets('user can login and navigate to home screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Enter username and password
      await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.pump();

      // Tap login button
      await tester.tap(find.widgetWithText(TouchFriendlyButton, 'Login'));
      await tester.pumpAndSettle();

      // Verify navigation to home screen
      expect(find.text('Plantita App'), findsOneWidget);
    });

    testWidgets('user can navigate to reels view and view a reel', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Ensure we are on home screen first (if not, login again for this test context or rely on state)
      // Since it's a new test, state might be reset, so let's log in again
      await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'testuser');
      await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.tap(find.widgetWithText(TouchFriendlyButton, 'Login'));
      await tester.pumpAndSettle();

      // Tap on Reels tab in BottomNavigationBar
      await tester.tap(find.text('Reels'));
      await tester.pumpAndSettle();

      // Verify we are on the Reels view
      expect(find.text('Reels'), findsWidgets);
    });
  });
}
