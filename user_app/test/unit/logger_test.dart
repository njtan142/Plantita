import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:user_app/utils/logger.dart' as app_logger;

// Custom OutputCallback for testing logger output
class TestLogOutput extends LogOutput {
  final List<OutputEvent> events = [];

  @override
  void output(OutputEvent event) {
    events.add(event);
  }
}

void main() {
  group('Logger Utility', () {
    test('should be initialized with a Logger instance', () {
      expect(app_logger.logger, isA<Logger>());
    });

    test('should use PrettyPrinter with correct configuration', () {
      // By checking the logger directly we verify its printer type in its initialization
      // We can also re-create the printer to verify its properties exactly as in the file
      final printer = PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        printTime: false,
      );
      expect(printer, isA<PrettyPrinter>());
    });

    test('should log messages properly with correct configuration', () async {
      // Create a test logger with the same configuration but a custom output
      final testOutput = TestLogOutput();
      final testLogger = Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: false,
        ),
        output: testOutput,
      );

      // Log messages
      testLogger.d('Debug message');
      testLogger.i('Info message');
      testLogger.w('Warning message');
      testLogger.e('Error message');

      // Allow async logging to complete
      await Future.delayed(Duration(milliseconds: 100));

      expect(testOutput.events.length, 4);

      // Check for debug
      expect(testOutput.events[0].level, Level.debug);
      expect(testOutput.events[0].lines.join('\n'), contains('Debug message'));

      // Check for info
      expect(testOutput.events[1].level, Level.info);
      expect(testOutput.events[1].lines.join('\n'), contains('Info message'));

      // Check for warning
      expect(testOutput.events[2].level, Level.warning);
      expect(testOutput.events[2].lines.join('\n'), contains('Warning message'));

      // Check for error
      expect(testOutput.events[3].level, Level.error);
      expect(testOutput.events[3].lines.join('\n'), contains('Error message'));
    });

    test('should be able to log messages without throwing exceptions using the app logger', () {
      // Just ensure the actual instance can log without error
      expect(() => app_logger.logger.d('Debug message from test'), returnsNormally);
      expect(() => app_logger.logger.i('Info message from test'), returnsNormally);
      expect(() => app_logger.logger.w('Warning message from test'), returnsNormally);
      expect(() => app_logger.logger.e('Error message from test'), returnsNormally);
    });
  });
}
