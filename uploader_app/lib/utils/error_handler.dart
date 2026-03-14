import 'dart:async';
import 'package:flutter/foundation.dart';
import 'logger.dart';
import '../models/error_models.dart';

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
