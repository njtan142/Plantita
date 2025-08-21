/// Application-wide constants
class AppConstants {
  // App Information
  static const String appName = 'Plantita Uploader';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Media management and upload application';

  // API Configuration
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3001',
  );

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';

  // File Upload
  static const int maxFileSize = 50 * 1024 * 1024; // 50MB
  static const List<String> allowedImageTypes = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp'
  ];
  static const List<String> allowedVideoTypes = [
    'mp4',
    'mov',
    'avi',
    'mkv'
  ];
  static const List<String> allowedDocumentTypes = [
    'pdf',
    'doc',
    'docx',
    'txt',
    'rtf'
  ];

  // UI Constants
  static const double borderRadius = 8.0;
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  static const double paddingExtraLarge = 32.0;

  // Animation Constants
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // Grid Layout
  static const int mobileCrossAxisCount = 2;
  static const int tabletCrossAxisCount = 3;
  static const int desktopCrossAxisCount = 4;

  // Cache Configuration
  static const Duration cacheDuration = Duration(hours: 24);
  static const int maxCacheSize = 100 * 1024 * 1024; // 100MB
}