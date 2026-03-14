import 'package:flutter_test/flutter_test.dart';
import 'package:uploader_app/utils/error_handler.dart';
import 'package:uploader_app/models/error_models.dart';

void main() {
  group('AppError', () {
    test('network factory creates correct error', () {
      final error = AppError.network('Connection failed');
      expect(error.type, equals(AppErrorType.network));
      expect(error.message, equals('Connection failed'));
      expect(error.severity, equals(ErrorSeverity.medium));
      expect(error.userMessage, equals('Connection issue'));
      expect(error.context, isNotNull);
      expect(error.context?['timestamp'], isNotNull);
    });

    test('authentication factory creates correct error', () {
      final error = AppError.authentication('Invalid token');
      expect(error.type, equals(AppErrorType.authentication));
      expect(error.message, equals('Invalid token'));
      expect(error.severity, equals(ErrorSeverity.high));
    });

    test('validation factory creates correct error', () {
      final error = AppError.validation('Invalid input');
      expect(error.type, equals(AppErrorType.validation));
      expect(error.message, equals('Invalid input'));
      expect(error.severity, equals(ErrorSeverity.low));
    });

    test('fileSystem factory creates correct error', () {
      final error = AppError.fileSystem('Cannot read file');
      expect(error.type, equals(AppErrorType.fileSystem));
      expect(error.message, equals('Cannot read file'));
      expect(error.severity, equals(ErrorSeverity.medium));
    });

    test('camera factory creates correct error', () {
      final error = AppError.camera('Camera not found');
      expect(error.type, equals(AppErrorType.camera));
      expect(error.message, equals('Camera not found'));
      expect(error.severity, equals(ErrorSeverity.medium));
    });

    test('upload factory creates correct error', () {
      final error = AppError.upload('Upload failed', fileName: 'test.jpg');
      expect(error.type, equals(AppErrorType.upload));
      expect(error.message, equals('Upload failed'));
      expect(error.severity, equals(ErrorSeverity.medium));
      expect(error.context?['file_name'], equals('test.jpg'));
    });

    test('permission factory creates correct error', () {
      final error = AppError.permission('Location denied');
      expect(error.type, equals(AppErrorType.permission));
      expect(error.message, equals('Location denied'));
      expect(error.severity, equals(ErrorSeverity.medium));
    });

    test('generic factory creates correct error', () {
      final error = AppError.generic('Unknown error');
      expect(error.type, equals(AppErrorType.unknown));
      expect(error.message, equals('Unknown error'));
      expect(error.severity, equals(ErrorSeverity.medium));
    });

    test('toString returns properly formatted string', () {
      final error = AppError.generic('Unknown error');
      expect(
        error.toString(),
        equals('AppError(type: AppErrorType.unknown, severity: ErrorSeverity.medium, message: Unknown error)'),
      );
    });
  });

  group('ErrorHandler', () {
    setUp(() {
      ErrorHandler.clearErrorHistory();
    });

    test('handleError adds error to history', () {
      ErrorHandler.handleError(Exception('Test error'));
      expect(ErrorHandler.errorHistory.length, equals(1));
      expect(ErrorHandler.errorHistory.first.message, contains('Test error'));
    });

    test('handleError maps string patterns to specific error types', () {
      ErrorHandler.handleError(Exception('network connection failed'));
      expect(ErrorHandler.errorHistory.last.type, equals(AppErrorType.network));

      ErrorHandler.handleError(Exception('unauthorized access'));
      expect(ErrorHandler.errorHistory.last.type, equals(AppErrorType.authentication));

      ErrorHandler.handleError(Exception('permission denied'));
      expect(ErrorHandler.errorHistory.last.type, equals(AppErrorType.permission));

      ErrorHandler.handleError(Exception('camera not found'));
      expect(ErrorHandler.errorHistory.last.type, equals(AppErrorType.camera));

      ErrorHandler.handleError(Exception('upload timeout'));
      expect(ErrorHandler.errorHistory.last.type, equals(AppErrorType.upload));

      ErrorHandler.handleError(Exception('something random'));
      expect(ErrorHandler.errorHistory.last.type, equals(AppErrorType.unknown));
    });

    test('handleError limits history size', () {
      for (int i = 0; i < 110; i++) {
        ErrorHandler.handleError(Exception('Error $i'));
      }
      expect(ErrorHandler.errorHistory.length, equals(100));
      expect(ErrorHandler.errorHistory.last.message, contains('Error 109'));
    });

    test('errorStream emits errors', () async {
      final expectedError = AppError.generic('Stream error');

      // Use expectLater to verify stream emissions
      expectLater(
        ErrorHandler.errorStream,
        emitsThrough(isA<AppError>().having((e) => e.message, 'message', 'Stream error')),
      );

      ErrorHandler.handleError(expectedError);
    });

    test('getErrorsByType returns filtered errors', () {
      ErrorHandler.handleError(AppError.network('Net error'));
      ErrorHandler.handleError(AppError.authentication('Auth error'));
      ErrorHandler.handleError(AppError.network('Another net error'));

      final netErrors = ErrorHandler.getErrorsByType(AppErrorType.network);
      expect(netErrors.length, equals(2));
      expect(netErrors.every((e) => e.type == AppErrorType.network), isTrue);
    });

    test('getErrorsBySeverity returns filtered errors', () {
      ErrorHandler.handleError(AppError.validation('Low error')); // low severity
      ErrorHandler.handleError(AppError.authentication('High error')); // high severity

      final highErrors = ErrorHandler.getErrorsBySeverity(ErrorSeverity.high);
      expect(highErrors.length, equals(1));
      expect(highErrors.first.type, equals(AppErrorType.authentication));
    });

    test('getErrorStats computes correct statistics', () {
      ErrorHandler.handleError(AppError.network('Net error 1'));
      ErrorHandler.handleError(AppError.network('Net error 2'));
      ErrorHandler.handleError(AppError.authentication('Auth error'));

      final stats = ErrorHandler.getErrorStats();
      expect(stats.totalErrors, equals(3));
      expect(stats.errorsByType[AppErrorType.network], equals(2));
      expect(stats.errorsByType[AppErrorType.authentication], equals(1));
      expect(stats.mostCommonErrorType, equals(AppErrorType.network));

      // Check highest severity (auth = high, network = medium)
      expect(stats.highestSeverity, equals(ErrorSeverity.high));
    });
  });

  group('ErrorStats', () {
    test('mostCommonErrorType returns null for empty stats', () {
      const stats = ErrorStats(totalErrors: 0, errorsByType: {}, errorsBySeverity: {});
      expect(stats.mostCommonErrorType, isNull);
    });

    test('highestSeverity returns null for empty stats', () {
      const stats = ErrorStats(totalErrors: 0, errorsByType: {}, errorsBySeverity: {});
      expect(stats.highestSeverity, isNull);
    });

    test('toString formats correctly', () {
      const stats = ErrorStats(
        totalErrors: 1,
        errorsByType: {AppErrorType.network: 1},
        errorsBySeverity: {ErrorSeverity.medium: 1},
      );
      expect(
        stats.toString(),
        equals('ErrorStats(total: 1, types: {AppErrorType.network: 1}, severities: {ErrorSeverity.medium: 1})'),
      );
    });
  });
}
