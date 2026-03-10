import 'package:flutter/foundation.dart';
import 'base_provider.dart';

class AppError {
  final String message;
  final String? code;
  final DateTime timestamp;
  final ErrorSeverity severity;

  const AppError({
    required this.message,
    this.code,
    required this.timestamp,
    this.severity = ErrorSeverity.medium,
  });
}

enum ErrorSeverity {
  low,
  medium,
  high,
  critical,
}

class ErrorProvider extends BaseProvider {
  final List<AppError> _errors = [];
  bool _showErrorDialog = false;

  List<AppError> get errors => _errors;
  bool get hasErrors => _errors.isNotEmpty;
  bool get showErrorDialog => _showErrorDialog;

  void addError(String message, {String? code, ErrorSeverity severity = ErrorSeverity.medium}) {
    final error = AppError(
      message: message,
      code: code,
      timestamp: DateTime.now(),
      severity: severity,
    );

    _errors.add(error);
    notifyListeners();

    // Log error for debugging
    debugPrint('Error added: $message (severity: $severity)');

    // For high/critical errors, show dialog
    if (severity == ErrorSeverity.high || severity == ErrorSeverity.critical) {
      _showErrorDialog = true;
      notifyListeners();
    }
  }

  void addNetworkError(String operation, {dynamic error}) {
    final String message = error != null
        ? 'Network error during $operation: ${error.toString()}'
        : 'Network error during $operation';

    addError(message, code: 'NETWORK_ERROR', severity: ErrorSeverity.high);
  }

  void addValidationError(String field, String message) {
    addError('Validation error for $field: $message',
      code: 'VALIDATION_ERROR',
      severity: ErrorSeverity.medium,
    );
  }

  void addAuthenticationError({String? message}) {
    addError(message ?? 'Authentication failed. Please login again.',
      code: 'AUTH_ERROR',
      severity: ErrorSeverity.high,
    );
  }

  void addUploadError(String fileName, {String? error}) {
    final String message = error != null
        ? 'Failed to upload $fileName: $error'
        : 'Failed to upload $fileName';

    addError(message, code: 'UPLOAD_ERROR', severity: ErrorSeverity.medium);
  }

  void removeError(int index) {
    if (index >= 0 && index < _errors.length) {
      _errors.removeAt(index);
      notifyListeners();
    }
  }

  void clearErrors() {
    _errors.clear();
    notifyListeners();
  }

  void dismissErrorDialog() {
    _showErrorDialog = false;
    notifyListeners();
  }

  void retryLastAction(VoidCallback action) {
    try {
      action();
      clearErrors();
    } catch (e) {
      addError('Retry failed: ${e.toString()}', severity: ErrorSeverity.medium);
    }
  }

  // Get errors by severity
  List<AppError> getErrorsBySeverity(ErrorSeverity severity) {
    return _errors.where((error) => error.severity == severity).toList();
  }

  // Get recent errors (last N errors)
  List<AppError> getRecentErrors({int count = 10}) {
    final sorted = List<AppError>.from(_errors)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sorted.take(count).toList();
  }

  @override
  void onDispose() {
    clearErrors();
    super.onDispose();
  }
}