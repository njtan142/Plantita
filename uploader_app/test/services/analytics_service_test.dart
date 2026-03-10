import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:uploader_app/services/analytics_service.dart';

@GenerateMocks([
  FirebaseAnalytics,
  FirebaseCrashlytics,
  FirebasePerformance,
])
import 'analytics_service_test.mocks.dart';

void main() {
  group('AnalyticsService Tests', () {
    late AnalyticsService analyticsService;
    late MockFirebaseAnalytics mockAnalytics;

    setUp(() {
      analyticsService = AnalyticsService();
      mockAnalytics = MockFirebaseAnalytics();

      analyticsService.setAnalyticsForTesting(mockAnalytics);
      analyticsService.setIsEnabledForTesting(true);
      analyticsService.setIsInitializedForTesting(true);
      // We must explicitly ensure it runs during test because EnvironmentConfig
      // might think analytics is disabled in test mode unless we mock it or
      // it just passes the isEnabled check inside logEvent:
      // if (!isEnabled || _analytics == null) return;
    });

    test('logEvent catches and logs exception when event logging fails', () async {
      // Arrange
      when(mockAnalytics.logEvent(
        name: anyNamed('name'),
        parameters: anyNamed('parameters'),
      )).thenThrow(Exception('Simulated Firebase error'));

      // Act
      // We pass a valid map to avoid the type cast error during filter
      await analyticsService.logEvent(
        name: 'test_event',
        parameters: {'key': 'value'},
      );

      // Assert
      // The test passes if the exception is caught and no error is thrown by logEvent
      verify(mockAnalytics.logEvent(
        name: 'test_event',
        parameters: {'key': 'value'},
      )).called(1);
    });
  });
}
