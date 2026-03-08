import 'dart:io';
import 'package:flutter/foundation.dart';

/// Environment configuration utility
class EnvConfig {
  static final Map<String, String> _envVars = {};

  /// Initialize environment configuration
  static Future<void> initialize() async {
    if (kReleaseMode) {
      // In release mode, use compile-time constants
      _envVars.addAll(_getDefaultValues());
      return;
    }

    try {
      final file = File('.env');
      if (await file.exists()) {
        final contents = await file.readAsString();
        final lines = contents.split('\n');

        for (var line in lines) {
          line = line.trim();
          if (line.isEmpty || line.startsWith('#')) continue;

          final parts = line.split('=');
          if (parts.length >= 2) {
            final key = parts[0].trim();
            final value = parts.sublist(1).join('=').trim();
            _envVars[key] = value;
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading .env file: $e');
    }

    // Fill in missing values with defaults
    _envVars.addAll(_getDefaultValues()..removeWhere((key, value) => _envVars.containsKey(key)));
  }

  /// Get default environment values
  static Map<String, String> _getDefaultValues() {
    return {
      'API_BASE_URL': 'http://localhost:3001',
      'API_TIMEOUT': '30000',
      'DEBUG': 'true',
      'LOG_LEVEL': 'info',
      'PWA_NAME': 'Plantita Uploader',
      'PWA_SHORT_NAME': 'Plantita',
      'PWA_DESCRIPTION': 'Media management and upload application',
      'PWA_THEME_COLOR': '#1976d2',
      'PWA_BACKGROUND_COLOR': '#ffffff',
      'PWA_DISPLAY': 'standalone',
      'PWA_ORIENTATION': 'portrait-primary',
      'PWA_START_URL': '/',
      'PWA_SCOPE': '/',
      'BUILD_WEB_RENDERER': 'html',
      'BUILD_WEB_CANVASKIT': 'false',
      'CACHE_DURATION': '24',
      'MAX_CACHE_SIZE': '104857600',
    };
  }

  /// Get environment variable value
  static String get(String key, {String? defaultValue}) {
    return _envVars[key] ?? defaultValue ?? '';
  }

  /// Get environment variable as integer
  static int getInt(String key, {int defaultValue = 0}) {
    final value = get(key);
    return int.tryParse(value) ?? defaultValue;
  }

  /// Get environment variable as boolean
  static bool getBool(String key, {bool defaultValue = false}) {
    final value = get(key).toLowerCase();
    if (value == 'true' || value == '1' || value == 'yes') {
      return true;
    }
    if (value == 'false' || value == '0' || value == 'no') {
      return false;
    }
    return defaultValue;
  }

  /// Check if debug mode is enabled
  static bool get isDebug => getBool('DEBUG');

  /// Get API base URL
  static String get apiBaseUrl => get('API_BASE_URL');

  /// Get API timeout
  static Duration get apiTimeout => Duration(milliseconds: getInt('API_TIMEOUT'));

  /// Get PWA configuration
  static Map<String, String> get pwaConfig => {
    'name': get('PWA_NAME'),
    'short_name': get('PWA_SHORT_NAME'),
    'description': get('PWA_DESCRIPTION'),
    'theme_color': get('PWA_THEME_COLOR'),
    'background_color': get('PWA_BACKGROUND_COLOR'),
    'display': get('PWA_DISPLAY'),
    'orientation': get('PWA_ORIENTATION'),
    'start_url': get('PWA_START_URL'),
    'scope': get('PWA_SCOPE'),
  };

  /// Get all environment variables
  static Map<String, String> get all => Map.unmodifiable(_envVars);
}