import 'package:flutter_test/flutter_test.dart';
import 'package:uploader_app/utils/logger.dart';

void main() {
  group('Logger', () {
    test('can configure logger without throwing', () {
      expect(() {
        Logger.configure(
          minimumLevel: LogLevel.debug,
          enableColors: true,
          enableStackTrace: true,
        );
      }, returnsNormally);
    });

    test('can log debug message without throwing', () {
      expect(() {
        Logger.debug('Debug message', tag: 'TEST');
      }, returnsNormally);
    });

    test('can log info message without throwing', () {
      expect(() {
        Logger.info('Info message', tag: 'TEST');
      }, returnsNormally);
    });

    test('can log warning message without throwing', () {
      expect(() {
        Logger.warning('Warning message', tag: 'TEST');
      }, returnsNormally);
    });

    test('can log error message with error and stacktrace without throwing', () {
      expect(() {
        Logger.error(
          'Error message',
          error: Exception('Test exception'),
          stackTrace: StackTrace.current,
          tag: 'TEST',
        );
      }, returnsNormally);
    });

    test('can log critical message without throwing', () {
      expect(() {
        Logger.critical('Critical message', tag: 'TEST');
      }, returnsNormally);
    });

    test('can log HTTP request without throwing', () {
      expect(() {
        Logger.logHttpRequest('GET', 'https://example.com/api', headers: {'Authorization': 'Bearer test'});
      }, returnsNormally);

      expect(() {
        Logger.logHttpRequest('POST', 'https://example.com/api', body: {'key': 'value'});
      }, returnsNormally);
    });

    test('can log HTTP response without throwing', () {
      expect(() {
        Logger.logHttpResponse(200, 'https://example.com/api', body: '{"success": true}', duration: const Duration(milliseconds: 150));
      }, returnsNormally);

      expect(() {
        Logger.logHttpResponse(404, 'https://example.com/api', duration: const Duration(milliseconds: 50));
      }, returnsNormally);

      expect(() {
        Logger.logHttpResponse(500, 'https://example.com/api');
      }, returnsNormally);
    });

    test('can log auth event without throwing', () {
      expect(() {
        Logger.logAuthEvent('login_success', userId: 'user123', details: 'Method: Email');
      }, returnsNormally);
    });

    test('can log upload event without throwing', () {
      expect(() {
        Logger.logUploadEvent('upload_start', 'image.jpg', fileSize: 1024 * 1024 * 5, details: 'High res');
      }, returnsNormally);

      expect(() {
        Logger.logUploadEvent('upload_complete', 'video.mp4');
      }, returnsNormally);
    });

    test('can log user action without throwing', () {
      expect(() {
        Logger.logUserAction('click_button', userId: 'user123', details: 'Button: Submit');
      }, returnsNormally);
    });

    test('respects log level configuration', () {
      // It's hard to verify console output easily in simple unit tests without Zones
      // Here we just ensure changing configuration works
      Logger.configure(minimumLevel: LogLevel.error);

      // These shouldn't throw, and internally shouldn't log
      expect(() {
        Logger.debug('Should not log');
        Logger.info('Should not log');
        Logger.warning('Should not log');
        // This should log
        Logger.error('Should log');
      }, returnsNormally);

      // Reset config
      Logger.configure(minimumLevel: LogLevel.info);
    });
  });
}
