import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/main.dart';
import 'package:user_app/config/environment_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  setUp(() {
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://api.example.com');
    getIt.reset();
    getIt.registerSingleton<EnvironmentConfig>(EnvironmentConfig.development());
    setupLocator();
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Basic verification that the app starts.
    // It should redirect to login since it's not authenticated.
    await tester.pumpAndSettle();
    
    // Check for login related text
    expect(find.text('Login'), findsWidgets);
  });
}
