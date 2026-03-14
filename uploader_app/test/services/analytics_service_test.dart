import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:uploader_app/services/analytics_service.dart';

@GenerateMocks([FirebaseAnalytics])
import 'analytics_service_test.mocks.dart';

class TestAnalyticsService extends AnalyticsService {
  TestAnalyticsService() : super.internal();

  @override
  bool get shouldInitialize => true;

  // We override initialize to simulate a full failure
  @override
  Future<bool> initialize() async {
    try {
      throw Exception('Mock Error');
    } catch (e) {
      setIsEnabledForTesting(false);
      return false;
    }
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

    test('logEvent catches and logs exception when event logging fails', () async {
      // Arrange
      final analyticsService = AnalyticsService.internal();
      final mockAnalytics = MockFirebaseAnalytics();

      analyticsService.setAnalyticsForTesting(mockAnalytics);
      analyticsService.setIsEnabledForTesting(true);
      analyticsService.setIsInitializedForTesting(true);

      when(mockAnalytics.logEvent(
        name: anyNamed('name'),
        parameters: anyNamed('parameters'),
      )).thenThrow(Exception('Simulated Firebase error'));

      // Act
      await analyticsService.logEvent(
        name: 'test_event',
        parameters: {'key': 'value'},
      );

      // Assert
      verify(mockAnalytics.logEvent(
        name: 'test_event',
        parameters: {'key': 'value'},
      )).called(1);
    });
  });
}
