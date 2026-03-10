import 'package:test/test.dart';
import 'package:uploader_app/utils/error_handler.dart';

void main() {
  test('Benchmark ErrorHandler._createAppError', () {
    final errors = [
      Exception('network connection failed'),
      Exception('auth unauthorized 401 error'),
      Exception('permission denied'),
      Exception('camera media error'),
      Exception('upload file failed'),
      Exception('some other generic unknown error'),
      Exception('another network connect error'),
      Exception('random error'),
    ];

    // Warmup
    for (int i = 0; i < 1000; i++) {
      for (final error in errors) {
        ErrorHandler.handleError(error, showToUser: false);
      }
    }

    // Benchmark
    final stopwatch = Stopwatch()..start();
    const iterations = 10000;

    for (int i = 0; i < iterations; i++) {
      for (final error in errors) {
        ErrorHandler.handleError(error, showToUser: false);
      }
    }

    stopwatch.stop();
    print('Baseline time for ${iterations * errors.length} calls: ${stopwatch.elapsedMilliseconds}ms');
  });
}
