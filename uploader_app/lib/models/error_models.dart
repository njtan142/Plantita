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
