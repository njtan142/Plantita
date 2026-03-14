import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/main.dart';
import 'package:user_app/config/environment_config.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:user_app/services/api_service.dart';
import 'package:user_app/services/auth_service.dart';
import 'package:user_app/services/cache_service.dart';
import 'package:user_app/services/video_player_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    // Reset GetIt
    await getIt.reset();
    
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    
    // Mock dotenv
    dotenv.testLoad(fileInput: 'API_BASE_URL=https://api.example.com');
    
    // Register necessary singletons
    getIt.registerSingleton<EnvironmentConfig>(EnvironmentConfig.development());
    
    // Register services
    final apiService = ApiService();
    getIt.registerSingleton<ApiService>(apiService);
    getIt.registerSingleton<AuthService>(AuthService(apiService));
    
    final cacheService = CacheService();
    getIt.registerSingleton<CacheService>(cacheService);
    await cacheService.init();
    
    getIt.registerSingleton<VideoPlayerService>(VideoPlayerService());
  });

  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    // Use runAsync to handle any async initialization in MyApp
    await tester.runAsync(() async {
      await tester.pumpWidget(const MyApp());
      await tester.pump(const Duration(milliseconds: 500));
    });

    // Check for MyApp related widget
    expect(find.byType(MyApp), findsOneWidget);
  });
}
