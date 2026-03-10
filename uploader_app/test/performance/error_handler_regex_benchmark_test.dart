import 'package:test/test.dart';

void main() {
  test('Benchmark contains vs RegExp', () {
    final errors = [
      'Exception: network connection failed',
      'Exception: auth unauthorized 401 error',
      'Exception: permission denied',
      'Exception: camera media error',
      'Exception: upload file failed',
      'Exception: some other generic unknown error',
      'Exception: another network connect error',
      'Exception: random error',
    ];

    final networkErrorPattern = RegExp(r'network|connect', caseSensitive: false);
    final authErrorPattern = RegExp(r'auth|unauthorized|401', caseSensitive: false);
    final permissionErrorPattern = RegExp(r'permission|denied', caseSensitive: false);
    final cameraErrorPattern = RegExp(r'camera|media', caseSensitive: false);
    final uploadErrorPattern = RegExp(r'upload|file', caseSensitive: false);

    // Warmup contains
    for (int i = 0; i < 1000; i++) {
      for (final errorString in errors) {
        final lower = errorString.toLowerCase();
        if (lower.contains('network') || lower.contains('connect')) {}
        else if (lower.contains('auth') || lower.contains('unauthorized') || lower.contains('401')) {}
        else if (lower.contains('permission') || lower.contains('denied')) {}
        else if (lower.contains('camera') || lower.contains('media')) {}
        else if (lower.contains('upload') || lower.contains('file')) {}
      }
    }

    // Benchmark contains
    final swContains = Stopwatch()..start();
    const iterations = 10000;

    for (int i = 0; i < iterations; i++) {
      for (final errorString in errors) {
        final lower = errorString.toLowerCase();
        if (lower.contains('network') || lower.contains('connect')) {}
        else if (lower.contains('auth') || lower.contains('unauthorized') || lower.contains('401')) {}
        else if (lower.contains('permission') || lower.contains('denied')) {}
        else if (lower.contains('camera') || lower.contains('media')) {}
        else if (lower.contains('upload') || lower.contains('file')) {}
      }
    }

    swContains.stop();
    print('Contains time: ${swContains.elapsedMilliseconds}ms');

    // Warmup RegExp
    for (int i = 0; i < 1000; i++) {
      for (final errorString in errors) {
        if (networkErrorPattern.hasMatch(errorString)) {}
        else if (authErrorPattern.hasMatch(errorString)) {}
        else if (permissionErrorPattern.hasMatch(errorString)) {}
        else if (cameraErrorPattern.hasMatch(errorString)) {}
        else if (uploadErrorPattern.hasMatch(errorString)) {}
      }
    }

    // Benchmark RegExp
    final swRegex = Stopwatch()..start();
    for (int i = 0; i < iterations; i++) {
      for (final errorString in errors) {
        if (networkErrorPattern.hasMatch(errorString)) {}
        else if (authErrorPattern.hasMatch(errorString)) {}
        else if (permissionErrorPattern.hasMatch(errorString)) {}
        else if (cameraErrorPattern.hasMatch(errorString)) {}
        else if (uploadErrorPattern.hasMatch(errorString)) {}
      }
    }
    swRegex.stop();
    print('RegExp time: ${swRegex.elapsedMilliseconds}ms');
  });
}
