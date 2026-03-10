import 'dart:async';
import 'package:flutter/foundation.dart';
import 'logger.dart';

/// Error severity levels
enum ErrorSeverity { low, medium, high, critical }

/// App error types
enum AppErrorType {
  network,
  authentication,
  validation,
  fileSystem,
  camera,
  upload,
  permission,
  unknown,
}

/// Application error with context and recovery suggestions
class AppError {
  final String message;
  final Object? originalError;
  final StackTrace? stackTrace;
  final AppErrorType type;
  final ErrorSeverity severity;
  final String? userMessage;
  final String? recoverySuggestion;
  final Map<String, dynamic>? context;

  const AppError({
    required this.message,
    this.originalError,
    this.stackTrace,
    required this.type,
    this.severity = ErrorSeverity.medium,
    this.userMessage,
    this.recoverySuggestion,
    this.context,
  });

  /// Get user-friendly error message
  String get displayMessage => userMessage ?? _getDefaultUserMessage();

  /// Get recovery suggestion
  String get recoveryMessage =>
      recoverySuggestion ?? _getDefaultRecoverySuggestion();

  /// Check if error is recoverable
  bool get isRecoverable => severity != ErrorSeverity.critical;

  /// Create error from network exception
  factory AppError.network(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
      type: AppErrorType.network,
      severity: ErrorSeverity.medium,
      userMessage: 'Connection issue',
      recoverySuggestion:
          'Please check your internet connection and try again.',
      context: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  /// Create error from authentication exception
  factory AppError.authentication(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
      type: AppErrorType.authentication,
      severity: ErrorSeverity.high,
      userMessage: 'Authentication required',
      recoverySuggestion: 'Please log in again to continue.',
      context: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  /// Create error from validation exception
  factory AppError.validation(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
    String? field,
  }) {
    return AppError(
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
      type: AppErrorType.validation,
      severity: ErrorSeverity.low,
      userMessage: 'Invalid input',
      recoverySuggestion: 'Please check your input and try again.',
      context: {'timestamp': DateTime.now().toIso8601String(), 'field': field},
    );
  }

  /// Create error from file system exception
  factory AppError.fileSystem(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
    String? filePath,
  }) {
    return AppError(
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
      type: AppErrorType.fileSystem,
      severity: ErrorSeverity.medium,
      userMessage: 'File access error',
      recoverySuggestion: 'Please check file permissions and try again.',
      context: {
        'timestamp': DateTime.now().toIso8601String(),
        'file_path': filePath,
      },
    );
  }

  /// Create error from camera exception
  factory AppError.camera(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
      type: AppErrorType.camera,
      severity: ErrorSeverity.medium,
      userMessage: 'Camera access error',
      recoverySuggestion: 'Please check camera permissions and try again.',
      context: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  /// Create error from upload exception
  factory AppError.upload(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
    String? fileName,
  }) {
    return AppError(
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
      type: AppErrorType.upload,
      severity: ErrorSeverity.medium,
      userMessage: 'Upload failed',
      recoverySuggestion:
          'Please check your connection and try uploading again.',
      context: {
        'timestamp': DateTime.now().toIso8601String(),
        'file_name': fileName,
      },
    );
  }

  /// Create error from permission exception
  factory AppError.permission(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
    String? permission,
  }) {
    return AppError(
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
      type: AppErrorType.permission,
      severity: ErrorSeverity.medium,
      userMessage: 'Permission denied',
      recoverySuggestion:
          'Please grant the required permissions and try again.',
      context: {
        'timestamp': DateTime.now().toIso8601String(),
        'permission': permission,
      },
    );
  }

  /// Create generic error
  factory AppError.generic(
    String message, {
    Object? originalError,
    StackTrace? stackTrace,
  }) {
    return AppError(
      message: message,
      originalError: originalError,
      stackTrace: stackTrace,
      type: AppErrorType.unknown,
      severity: ErrorSeverity.medium,
      userMessage: 'Something went wrong',
      recoverySuggestion:
          'Please try again or contact support if the problem persists.',
      context: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  /// Get default user message based on error type
  String _getDefaultUserMessage() {
    switch (type) {
      case AppErrorType.network:
        return 'Connection issue';
      case AppErrorType.authentication:
        return 'Authentication required';
      case AppErrorType.validation:
        return 'Invalid input';
      case AppErrorType.fileSystem:
        return 'File access error';
      case AppErrorType.camera:
        return 'Camera access error';
      case AppErrorType.upload:
        return 'Upload failed';
      case AppErrorType.permission:
        return 'Permission denied';
      case AppErrorType.unknown:
        return 'Something went wrong';
    }
  }

  /// Get default recovery suggestion based on error type
  String _getDefaultRecoverySuggestion() {
    switch (type) {
      case AppErrorType.network:
        return 'Please check your internet connection and try again.';
      case AppErrorType.authentication:
        return 'Please log in again to continue.';
      case AppErrorType.validation:
        return 'Please check your input and try again.';
      case AppErrorType.fileSystem:
        return 'Please check file permissions and try again.';
      case AppErrorType.camera:
        return 'Please check camera permissions and try again.';
      case AppErrorType.upload:
        return 'Please check your connection and try uploading again.';
      case AppErrorType.permission:
        return 'Please grant the required permissions and try again.';
      case AppErrorType.unknown:
        return 'Please try again or contact support if the problem persists.';
    }
  }

  @override
  String toString() {
    return 'AppError(type: $type, severity: $severity, message: $message)';
  }
}

/// Error handler for managing and reporting errors across the app
class ErrorHandler {
  static final StreamController<AppError> _errorController =
      StreamController<AppError>.broadcast();
  static final List<AppError> _errorHistory = [];
  static const int _maxHistorySize = 100;

  static final RegExp _networkErrorPattern = RegExp(
    r'network|connect',
    caseSensitive: false,
  );
  static final RegExp _authErrorPattern = RegExp(
    r'auth|unauthorized|401',
    caseSensitive: false,
  );
  static final RegExp _permissionErrorPattern = RegExp(
    r'permission|denied',
    caseSensitive: false,
  );
  static final RegExp _cameraErrorPattern = RegExp(
    r'camera|media',
    caseSensitive: false,
  );
  static final RegExp _uploadErrorPattern = RegExp(
    r'upload|file',
    caseSensitive: false,
  );

  /// Stream of errors for reactive error handling
  static Stream<AppError> get errorStream => _errorController.stream;

  /// Get error history
  static List<AppError> get errorHistory => List.unmodifiable(_errorHistory);

  /// Handle error with logging and user notification
  static void handleError(
    Object error, {
    StackTrace? stackTrace,
    String? context,
    bool showToUser = true,
  }) {
    final appError = _createAppError(error, stackTrace, context);

    // Add to history
    _errorHistory.add(appError);
    if (_errorHistory.length > _maxHistorySize) {
      _errorHistory.removeAt(0);
    }

    // Log error
    Logger.error(
      appError.message,
      error: appError.originalError,
      stackTrace: appError.stackTrace,
      tag: 'ERROR_HANDLER',
    );

    // Emit to stream for UI handling
    _errorController.add(appError);

    // Log additional context
    if (context != null) {
      Logger.debug('Error context: $context', tag: 'ERROR_HANDLER');
    }

    // Log error details
    Logger.debug(
      'Error details - Type: ${appError.type}, Severity: ${appError.severity}, Recoverable: ${appError.isRecoverable}',
      tag: 'ERROR_HANDLER',
    );
  }

  /// Handle async errors
  static void handleAsyncError(
    Object error,
    StackTrace stackTrace, {
    String? context,
  }) {
    handleError(error, stackTrace: stackTrace, context: context);
  }

  /// Create Flutter error handler
  static void setupFlutterErrorHandling() {
    FlutterError.onError = (FlutterErrorDetails details) {
      handleError(
        details.exception,
        stackTrace: details.stack,
        context: 'Flutter Error: ${details.summary}',
      );
    };

    // Handle platform errors
    PlatformDispatcher.instance.onError = (error, stack) {
      handleError(error, stackTrace: stack, context: 'Platform Error');
      return true; // Prevent the error from being handled again
    };
  }

  /// Clear error history
  static void clearErrorHistory() {
    _errorHistory.clear();
  }

  /// Get errors by type
  static List<AppError> getErrorsByType(AppErrorType type) {
    return _errorHistory.where((error) => error.type == type).toList();
  }

  /// Get errors by severity
  static List<AppError> getErrorsBySeverity(ErrorSeverity severity) {
    return _errorHistory.where((error) => error.severity == severity).toList();
  }

  /// Get error statistics
  static ErrorStats getErrorStats() {
    final total = _errorHistory.length;
    final byType = <AppErrorType, int>{};
    final bySeverity = <ErrorSeverity, int>{};

    for (final error in _errorHistory) {
      byType[error.type] = (byType[error.type] ?? 0) + 1;
      bySeverity[error.severity] = (bySeverity[error.severity] ?? 0) + 1;
    }

    return ErrorStats(
      totalErrors: total,
      errorsByType: byType,
      errorsBySeverity: bySeverity,
    );
  }

  /// Convert any error to AppError
  static AppError _createAppError(
    Object error,
    StackTrace? stackTrace,
    String? context,
  ) {
    if (error is AppError) {
      return error;
    }

    // Handle specific error types
    final errorString = error.toString();

    if (_networkErrorPattern.hasMatch(errorString)) {
      return AppError.network(
        'Network error occurred',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (_authErrorPattern.hasMatch(errorString)) {
      return AppError.authentication(
        'Authentication failed',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (_permissionErrorPattern.hasMatch(errorString)) {
      return AppError.permission(
        'Permission denied',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (_cameraErrorPattern.hasMatch(errorString)) {
      return AppError.camera(
        'Camera error occurred',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (_uploadErrorPattern.hasMatch(errorString)) {
      return AppError.upload(
        'Upload error occurred',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    // Generic error
    return AppError.generic(
      error.toString(),
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Dispose error handler
  static void dispose() {
    _errorController.close();
  }
}

/// Error statistics model
class ErrorStats {
  final int totalErrors;
  final Map<AppErrorType, int> errorsByType;
  final Map<ErrorSeverity, int> errorsBySeverity;

  const ErrorStats({
    required this.totalErrors,
    required this.errorsByType,
    required this.errorsBySeverity,
  });

  /// Get most common error type
  AppErrorType? get mostCommonErrorType {
    if (errorsByType.isEmpty) return null;
    return errorsByType.entries.reduce((a, b) => a.value > b.value ? a : b).key;
  }

  /// Get highest severity error
  ErrorSeverity? get highestSeverity {
    if (errorsBySeverity.isEmpty) return null;
    return errorsBySeverity.keys.reduce((a, b) => a.index > b.index ? a : b);
  }

  @override
  String toString() {
    return 'ErrorStats(total: $totalErrors, types: $errorsByType, severities: $errorsBySeverity)';
  }
}
