import 'package:flutter_test/flutter_test.dart';
import 'package:uploader_app/providers/error_provider.dart';
import 'package:flutter/foundation.dart';

void main() {
  setUp(() {
    debugPrint = (String? message, {int? wrapWidth}) {};
  });

  test('Benchmark addNetworkError', () {
    final provider = ErrorProvider();

    // Warm up
    for (int i = 0; i < 10000; i++) {
      provider.addNetworkError('operation_$i', error: 'Sample error message $i');
    }
    provider.clearErrors();

    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < 100000; i++) {
      provider.addNetworkError('operation_$i', error: 'Sample error message $i');
    }

    stopwatch.stop();
    print('Time taken for 100000 calls addNetworkError: ${stopwatch.elapsedMilliseconds} ms');
  });

  test('Benchmark addUploadError', () {
    final provider = ErrorProvider();

    // Warm up
    for (int i = 0; i < 10000; i++) {
      provider.addUploadError('file_$i', error: 'Sample error message $i');
    }
    provider.clearErrors();

    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < 100000; i++) {
      provider.addUploadError('file_$i', error: 'Sample error message $i');
    }

    stopwatch.stop();
    print('Time taken for 100000 calls addUploadError: ${stopwatch.elapsedMilliseconds} ms');
  });
}
