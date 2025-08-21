import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

/// Log levels for different types of messages
enum LogLevel {
  debug,
  info,
  warning,
  error,
  critical,
}

/// Logger utility for structured logging across the application
class Logger {
  static LogLevel _minimumLevel = LogLevel.info;
  static bool _enableColors = true;
  static bool _enableStackTrace = true;

  /// Configure logger settings
  static void configure({
    LogLevel minimumLevel = LogLevel.info,
    bool enableColors = true,
    bool enableStackTrace = true,
  }) {
    _minimumLevel = minimumLevel;
    _enableColors = enableColors && !kIsWeb; // Colors don't work well on web
    _enableStackTrace = enableStackTrace;
  }

  /// Log debug message
  static void debug(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    _log(LogLevel.debug, message, error: error, stackTrace: stackTrace, tag: tag);
  }

  /// Log info message
  static void info(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    _log(LogLevel.info, message, error: error, stackTrace: stackTrace, tag: tag);
  }

  /// Log warning message
  static void warning(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    _log(LogLevel.warning, message, error: error, stackTrace: stackTrace, tag: tag);
  }

  /// Log error message
  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    _log(LogLevel.error, message, error: error, stackTrace: stackTrace, tag: tag);
  }

  /// Log critical message
  static void critical(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    _log(LogLevel.critical, message, error: error, stackTrace: stackTrace, tag: tag);
  }

  /// Log HTTP request
  static void logHttpRequest(String method, String url, {Map<String, String>? headers, dynamic body}) {
    if (_shouldLog(LogLevel.debug)) {
      final coloredMethod = _colorize(method, _getMethodColor(method));
      debug('HTTP Request: $coloredMethod $url');
      if (headers != null && headers.isNotEmpty) {
        debug('Headers: $headers');
      }
      if (body != null) {
        debug('Body: ${body.toString()}');
      }
    }
  }

  /// Log HTTP response
  static void logHttpResponse(int statusCode, String url, {String? body, Duration? duration}) {
    if (_shouldLog(LogLevel.debug)) {
      final coloredStatus = _colorize(statusCode.toString(), _getStatusColor(statusCode));
      final durationText = duration != null ? ' (${duration.inMilliseconds}ms)' : '';
      debug('HTTP Response: $coloredStatus $url$durationText');
      if (body != null && body.isNotEmpty) {
        debug('Response Body: $body');
      }
    }
  }

  /// Log authentication event
  static void logAuthEvent(String event, {String? userId, String? details}) {
    info('Auth Event: $event', tag: 'AUTH', error: details);
  }

  /// Log upload event
  static void logUploadEvent(String event, String fileName, {int? fileSize, String? details}) {
    info('Upload Event: $event - $fileName${fileSize != null ? ' (${_formatBytes(fileSize)})' : ''}',
         tag: 'UPLOAD', error: details);
  }

  /// Log user action
  static void logUserAction(String action, {String? userId, String? details}) {
    debug('User Action: $action${userId != null ? ' (User: $userId)' : ''}',
          tag: 'USER', error: details);
  }

  /// Internal logging method
  static void _log(LogLevel level, String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    if (!_shouldLog(level)) return;

    final timestamp = DateTime.now().toIso8601String();
    final levelText = _getLevelText(level);
    final tagText = tag != null ? '[$tag] ' : '';
    final errorText = error != null ? '\nError: $error' : '';
    final stackTraceText = _enableStackTrace && stackTrace != null ? '\nStackTrace: $stackTrace' : '';

    final logMessage = '$timestamp $levelText $tagText$message$errorText$stackTraceText';

    // Use developer.log for structured logging
    developer.log(
      logMessage,
      level: _getLevelValue(level),
      name: tag ?? 'APP',
      error: error,
      stackTrace: _enableStackTrace ? stackTrace : null,
    );

    // Also print to console in debug mode
    if (kDebugMode) {
      print(logMessage);
    }
  }

  /// Check if message should be logged based on minimum level
  static bool _shouldLog(LogLevel level) {
    return level.index >= _minimumLevel.index;
  }

  /// Get text representation of log level
  static String _getLevelText(LogLevel level) {
    if (!_enableColors) {
      return '[${level.name.toUpperCase()}]';
    }

    const colors = {
      LogLevel.debug: '\x1B[36m',    // Cyan
      LogLevel.info: '\x1B[32m',     // Green
      LogLevel.warning: '\x1B[33m',  // Yellow
      LogLevel.error: '\x1B[31m',    // Red
      LogLevel.critical: '\x1B[35m', // Magenta
    };

    final color = colors[level] ?? '';
    return '$color[${level.name.toUpperCase()}]\x1B[0m';
  }

  /// Get numeric value for log level
  static int _getLevelValue(LogLevel level) {
    switch (level) {
      case LogLevel.debug: return 500;
      case LogLevel.info: return 800;
      case LogLevel.warning: return 900;
      case LogLevel.error: return 1000;
      case LogLevel.critical: return 1200;
    }
  }

  /// Colorize text if colors are enabled
  static String _colorize(String text, String color) {
    return _enableColors ? '$color$text\x1B[0m' : text;
  }

  /// Get color for HTTP method
  static String _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET': return '\x1B[32m';    // Green
      case 'POST': return '\x1B[34m';   // Blue
      case 'PUT': return '\x1B[33m';    // Yellow
      case 'DELETE': return '\x1B[31m'; // Red
      case 'PATCH': return '\x1B[35m';  // Magenta
      default: return '\x1B[37m';       // White
    }
  }

  /// Get color for HTTP status code
  static String _getStatusColor(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return '\x1B[32m';  // Green for success
    } else if (statusCode >= 300 && statusCode < 400) {
      return '\x1B[33m';  // Yellow for redirection
    } else if (statusCode >= 400 && statusCode < 500) {
      return '\x1B[31m';  // Red for client error
    } else if (statusCode >= 500) {
      return '\x1B[35m';  // Magenta for server error
    }
    return '\x1B[37m';     // White for unknown
  }

  /// Format bytes to human readable format
  static String _formatBytes(int bytes) {
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = bytes.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }
}