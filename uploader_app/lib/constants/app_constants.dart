class AppConstants {
  // App Information
  static const String appName = 'Plantita Uploader';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Social media media uploader app';

  // API Configuration
  static const String baseUrl = 'http://localhost:3000';
  static const String apiVersion = '/api/v1';

  // Routes
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String homeRoute = '/home';
  static const String cameraRoute = '/camera';
  static const String uploadRoute = '/upload';
  static const String userSelectionRoute = '/user-selection';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';

  // File Upload
  static const int maxFileSize = 100 * 1024 * 1024; // 100MB
  static const List<String> supportedImageTypes = [
    'image/jpeg',
    'image/png',
    'image/gif',
    'image/webp'
  ];
  static const List<String> supportedVideoTypes = [
    'video/mp4',
    'video/mpeg',
    'video/quicktime',
    'video/x-msvideo'
  ];

  // UI Constants
  static const double borderRadius = 12.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double elevation = 4.0;

  // Animation Duration
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration pageTransitionDuration = Duration(milliseconds: 500);

  // Camera Settings
  static const int cameraResolution = 1080;
  static const double videoQuality = 0.8;

  // Retry Configuration
  static const int maxRetryAttempts = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}