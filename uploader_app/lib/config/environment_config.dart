import 'dart:convert';
import 'package:flutter/foundation.dart';

/// Environment configuration for the Plantita Uploader app
class EnvironmentConfig {
  static const String _devEnvironment = 'development';
  static const String _stagingEnvironment = 'staging';
  static const String _prodEnvironment = 'production';

  // Current environment - set by build flags or default to development
  static const String currentEnvironment =
      String.fromEnvironment('ENVIRONMENT', defaultValue: _devEnvironment);

  // Environment-specific configurations
  static bool get isDevelopment => currentEnvironment == _devEnvironment;
  static bool get isStaging => currentEnvironment == _stagingEnvironment;
  static bool get isProduction => currentEnvironment == _prodEnvironment;

  // API Configuration
  static String get apiBaseUrl {
    switch (currentEnvironment) {
      case _devEnvironment:
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'http://localhost:3000/api',
        );
      case _stagingEnvironment:
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://api-staging.plantita.app',
        );
      case _prodEnvironment:
        return const String.fromEnvironment(
          'API_BASE_URL',
          defaultValue: 'https://api.plantita.app',
        );
      default:
        return 'http://localhost:3000/api';
    }
  }

  // Analytics Configuration
  static bool get enableAnalytics {
    return const bool.fromEnvironment('ENABLE_ANALYTICS',
        defaultValue: kReleaseMode);
  }

  static bool get enableCrashlytics {
    return const bool.fromEnvironment('ENABLE_CRASHLYTICS',
        defaultValue: kReleaseMode);
  }

  static bool get enablePerformanceMonitoring {
    return const bool.fromEnvironment('ENABLE_PERFORMANCE_MONITORING',
        defaultValue: kReleaseMode);
  }

  // Firebase Configuration
  static String get firebaseApiKey {
    return const String.fromEnvironment('FIREBASE_API_KEY',
        defaultValue: '');
  }

  static String get firebaseAuthDomain {
    return const String.fromEnvironment('FIREBASE_AUTH_DOMAIN',
        defaultValue: '');
  }

  static String get firebaseProjectId {
    return const String.fromEnvironment('FIREBASE_PROJECT_ID',
        defaultValue: 'plantita-uploader');
  }

  static String get firebaseStorageBucket {
    return const String.fromEnvironment('FIREBASE_STORAGE_BUCKET',
        defaultValue: '');
  }

  static String get firebaseMessagingSenderId {
    return const String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID',
        defaultValue: '');
  }

  static String get firebaseAppId {
    return const String.fromEnvironment('FIREBASE_APP_ID',
        defaultValue: '');
  }

  // PWA Configuration
  static bool get enablePWA {
    return const bool.fromEnvironment('ENABLE_PWA',
        defaultValue: true);
  }

  static bool get enableServiceWorker {
    return const bool.fromEnvironment('ENABLE_SERVICE_WORKER',
        defaultValue: kIsWeb && kReleaseMode);
  }

  static bool get enableBackgroundSync {
    return const bool.fromEnvironment('ENABLE_BACKGROUND_SYNC',
        defaultValue: kIsWeb && kReleaseMode);
  }

  static bool get enablePushNotifications {
    return const bool.fromEnvironment('ENABLE_PUSH_NOTIFICATIONS',
        defaultValue: kIsWeb && kReleaseMode);
  }

  // Security Configuration
  static bool get enableHttpsOnly {
    return const bool.fromEnvironment('ENABLE_HTTPS_ONLY',
        defaultValue: kReleaseMode);
  }

  static bool get enableContentSecurityPolicy {
    return const bool.fromEnvironment('ENABLE_CSP',
        defaultValue: kIsWeb && kReleaseMode);
  }

  // Performance Configuration
  static int get maxBundleSizeKB {
    return const int.fromEnvironment('MAX_BUNDLE_SIZE_KB',
        defaultValue: 2048); // 2MB
  }

  static int get connectionTimeoutMs {
    return const int.fromEnvironment('CONNECTION_TIMEOUT_MS',
        defaultValue: 30000); // 30 seconds
  }

  static int get uploadTimeoutMs {
    return const int.fromEnvironment('UPLOAD_TIMEOUT_MS',
        defaultValue: 120000); // 2 minutes
  }

  // Feature Flags
  static bool get enableImageCompression {
    return const bool.fromEnvironment('ENABLE_IMAGE_COMPRESSION',
        defaultValue: true);
  }

  static bool get enableOfflineMode {
    return const bool.fromEnvironment('ENABLE_OFFLINE_MODE',
        defaultValue: true);
  }

  static bool get enableAutoBackup {
    return const bool.fromEnvironment('ENABLE_AUTO_BACKUP',
        defaultValue: kReleaseMode);
  }

  // Debug Configuration
  static bool get enableDebugLogging {
    return const bool.fromEnvironment('ENABLE_DEBUG_LOGGING',
        defaultValue: kDebugMode);
  }

  static bool get enablePerformanceOverlay {
    return const bool.fromEnvironment('ENABLE_PERFORMANCE_OVERLAY',
        defaultValue: kDebugMode);
  }

  // CDN Configuration
  static List<String> get cdnUrls {
    final cdnConfig = const String.fromEnvironment('CDN_URLS',
        defaultValue: 'https://cdn.plantita.app');
    return cdnConfig.split(',');
  }

  // Monitoring Configuration
  static String get monitoringEndpoint {
    return const String.fromEnvironment('MONITORING_ENDPOINT',
        defaultValue: 'https://monitoring.plantita.app/api');
  }

  static int get monitoringIntervalMs {
    return const int.fromEnvironment('MONITORING_INTERVAL_MS',
        defaultValue: 60000); // 1 minute
  }

  // Cache Configuration
  static int get cacheMaxAgeDays {
    switch (currentEnvironment) {
      case _devEnvironment:
        return 1;
      case _stagingEnvironment:
        return 7;
      case _prodEnvironment:
        return 30;
      default:
        return 7;
    }
  }

  static int get maxCacheSizeMB {
    return const int.fromEnvironment('MAX_CACHE_SIZE_MB',
        defaultValue: 100); // 100MB
  }

  /// Get environment-specific configuration as JSON
  static Map<String, dynamic> toJson() {
    return {
      'environment': currentEnvironment,
      'isDevelopment': isDevelopment,
      'isStaging': isStaging,
      'isProduction': isProduction,
      'apiBaseUrl': apiBaseUrl,
      'enableAnalytics': enableAnalytics,
      'enableCrashlytics': enableCrashlytics,
      'enablePerformanceMonitoring': enablePerformanceMonitoring,
      'enablePWA': enablePWA,
      'enableServiceWorker': enableServiceWorker,
      'enableBackgroundSync': enableBackgroundSync,
      'enablePushNotifications': enablePushNotifications,
      'enableHttpsOnly': enableHttpsOnly,
      'enableContentSecurityPolicy': enableContentSecurityPolicy,
      'maxBundleSizeKB': maxBundleSizeKB,
      'connectionTimeoutMs': connectionTimeoutMs,
      'uploadTimeoutMs': uploadTimeoutMs,
      'enableImageCompression': enableImageCompression,
      'enableOfflineMode': enableOfflineMode,
      'enableAutoBackup': enableAutoBackup,
      'enableDebugLogging': enableDebugLogging,
      'enablePerformanceOverlay': enablePerformanceOverlay,
      'cacheMaxAgeDays': cacheMaxAgeDays,
      'maxCacheSizeMB': maxCacheSizeMB,
    };
  }

  /// Get formatted environment information for debugging
  static String get debugInfo {
    return jsonEncode(toJson());
  }

  /// Validate configuration for current environment
  static List<String> validate() {
    final errors = <String>[];

    if (apiBaseUrl.isEmpty) {
      errors.add('API base URL is not configured');
    }

    if (isProduction) {
      if (firebaseApiKey.isEmpty) {
        errors.add('Firebase API key is required for production');
      }

      if (firebaseProjectId.isEmpty) {
        errors.add('Firebase project ID is required for production');
      }
    }

    if (enableAnalytics && !isProduction) {
      errors.add('Analytics should only be enabled in production');
    }

    if (enableCrashlytics && !isProduction) {
      errors.add('Crashlytics should only be enabled in production');
    }

    return errors;
  }
}