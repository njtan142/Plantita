import 'package:flutter_test/flutter_test.dart';
import 'package:uploader_app/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PlantitaUploaderApp());

    // Basic verification that the app starts. 
    // Since it starts at LoginScreen, we check for login text.
    expect(find.text('Login'), findsWidgets);
  });
}
