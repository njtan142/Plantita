import 'package:flutter_test/flutter_test.dart';
import 'package:uploader_app/services/analytics_service.dart';

class TestAnalyticsService extends AnalyticsService {
  TestAnalyticsService() : super.internal();

  @override
  bool get shouldInitialize => true;

  @override
  Future<void> initFirebase() async {
    throw Exception('Mock Error');
  }
}

void main() {
  group('AnalyticsService Tests', () {
    test('initialization catches errors, returns false, and sets isEnabled to false', () async {
      // Arrange
      final service = TestAnalyticsService();

      // Act
      final result = await service.initialize();

      // Assert
      expect(result, isFalse, reason: 'Expected initialize to return false on error');
      expect(service.isEnabled, isFalse, reason: 'Expected isEnabled to be false after failure');
      expect(service.isInitialized, isFalse, reason: 'Expected isInitialized to remain false');
    });
  });
}
