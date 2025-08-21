import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import '../services/services.dart';
import 'providers.dart';

class AppProvider {
  static List<SingleChildWidget> getProviders() {
    // Initialize services first
    final httpClient = HttpClientService();
    final authService = AuthService(httpClient: httpClient);
    final userService = UserService(httpClient: httpClient);
    final uploadService = UploadService(httpClient: httpClient);
    final fileSelectionService = FileSelectionService();
    final webCameraService = WebCameraService();

    // Initialize providers with their dependencies
    final authProvider = AuthProvider(authService);
    final userSelectionProvider = UserSelectionProvider(userService);
    final uploadProvider = UploadProvider(
      uploadService,
      fileSelectionService,
      userSelectionProvider,
    );
    final errorProvider = ErrorProvider();

    return [
      // Services as providers for access throughout the app
      Provider<HttpClientService>.value(value: httpClient),
      Provider<AuthService>.value(value: authService),
      Provider<UserService>.value(value: userService),
      Provider<UploadService>.value(value: uploadService),
      Provider<FileSelectionService>.value(value: fileSelectionService),
      Provider<WebCameraService>.value(value: webCameraService),

      // State management providers
      ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ChangeNotifierProvider<UserSelectionProvider>.value(value: userSelectionProvider),
      ChangeNotifierProvider<UploadProvider>.value(value: uploadProvider),
      ChangeNotifierProvider<ErrorProvider>.value(value: errorProvider),
    ];
  }

  static Future<void> initializeProviders() async {
    // Initialize providers that need async setup
    // This can be called in main() before runApp()
    try {
      // Any global initialization can go here
      debugPrint('Initializing app providers...');
    } catch (e) {
      debugPrint('Error initializing providers: $e');
    }
  }
}