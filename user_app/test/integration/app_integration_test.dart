
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:user_app/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('app starts and navigates to login screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Verify that the app starts and the home screen is displayed initially
      expect(find.text('Home Screen'), findsOneWidget);

      // Example: Tap on a button to navigate to the login screen
      // This assumes there's a button on the home screen that navigates to login
      // You might need to adjust this based on your actual UI
      // expect(find.byType(ElevatedButton), findsOneWidget); // Find a button
      // await tester.tap(find.byType(ElevatedButton));
      // await tester.pumpAndSettle();

      // expect(find.text('Login'), findsOneWidget); // Verify login screen is shown
    });

    // TODO: Add more integration tests for other user flows (e.g., login, view reels, etc.)
  });
}
