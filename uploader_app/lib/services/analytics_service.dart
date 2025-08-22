import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import '../config/environment_config.dart';

/// Analytics and Monitoring Service for the Plantita Uploader app
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  // Firebase instances
  FirebaseAnalytics? _analytics;
  FirebaseCrashlytics? _crashlytics;
  FirebasePerformance? _performance;

  // Initialization state
  bool _isInitialized = false;
  bool _isEnabled = false;

  // Performance traces
  final Map<String, Trace> _activeTraces = {};

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isEnabled => _isEnabled && EnvironmentConfig.enableAnalytics;
  FirebaseAnalytics? get analytics => _analytics;

  /// Initialize analytics and monitoring services
  Future<void> initialize() async {
    if (!kIsWeb || !EnvironmentConfig.enableAnalytics) {
      debugPrint('Analytics: Disabled or not running on web platform');
      return;
    }

    try {
      await _initializeFirebaseAnalytics();
      await _initializeCrashlytics();
      await _initializePerformanceMonitoring();

      _isInitialized = true;
      _isEnabled = true;

      debugPrint('Analytics: Initialized successfully');
    } catch (e) {
      debugPrint('Analytics: Initialization failed: $e');
      _isEnabled = false;
    }
  }

  /// Initialize Firebase Analytics
  Future<void> _initializeFirebaseAnalytics() async {
    try {
      if (!EnvironmentConfig.enableAnalytics) return;

      _analytics = FirebaseAnalytics.instance;

      // Set user properties
      await _analytics?.setUserProperty(
        name: 'environment',
        value: EnvironmentConfig.currentEnvironment,
      );

      await _analytics?.setUserProperty(
        name: 'platform',
        value: kIsWeb ? 'web' : 'mobile',
      );

      debugPrint('Analytics: Firebase Analytics initialized');
    } catch (e) {
      debugPrint('Analytics: Firebase Analytics initialization failed: $e');
    }
  }

  /// Initialize Firebase Crashlytics
  Future<void> _initializeCrashlytics() async {
    try {
      if (!EnvironmentConfig.enableCrashlytics) return;

      _crashlytics = FirebaseCrashlytics.instance;

      // Enable crash collection
      await _crashlytics?.setCrashlyticsCollectionEnabled(true);

      // Set user information
      await _crashlytics?.setUserId('anonymous-user');

      // Set custom keys
      await _crashlytics?.setCustomKey('environment', EnvironmentConfig.currentEnvironment);
      await _crashlytics?.setCustomKey('platform', kIsWeb ? 'web' : 'mobile');
      await _crashlytics?.setCustomKey('app_version', '1.0.0');

      debugPrint('Analytics: Firebase Crashlytics initialized');
    } catch (e) {
      debugPrint('Analytics: Firebase Crashlytics initialization failed: $e');
    }
  }

  /// Initialize Firebase Performance Monitoring
  Future<void> _initializePerformanceMonitoring() async {
    try {
      if (!EnvironmentConfig.enablePerformanceMonitoring) return;

      _performance = FirebasePerformance.instance;

      // Enable performance collection
      await _performance?.setPerformanceCollectionEnabled(true);

      debugPrint('Analytics: Firebase Performance initialized');
    } catch (e) {
      debugPrint('Analytics: Firebase Performance initialization failed: $e');
    }
  }

  /// Log event
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {
    if (!isEnabled || _analytics == null) return;

    try {
      await _analytics?.logEvent(
        name: name,
        parameters: parameters,
      );

      debugPrint('Analytics: Event logged: $name');
    } catch (e) {
      debugPrint('Analytics: Failed to log event: $e');
    }
  }

  /// Log screen view
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {
    if (!isEnabled || _analytics == null) return;

    try {
      await _analytics?.logScreenView(
        screenName: screenName,
        screenClass: screenClass,
      );

      debugPrint('Analytics: Screen view logged: $screenName');
    } catch (e) {
      debugPrint('Analytics: Failed to log screen view: $e');
    }
  }

  /// Log user action
  Future<void> logUserAction(String action, {Map<String, Object?>? parameters}) async {
    await logEvent(
      name: 'user_action',
      parameters: {
        'action': action,
        ...?parameters,
      },
    );
  }

  /// Log upload event
  Future<void> logUploadEvent({
    required String action,
    required int fileSize,
    required String fileType,
    bool success = false,
    String? errorMessage,
  }) async {
    await logEvent(
      name: 'upload_event',
      parameters: {
        'action': action,
        'file_size': fileSize,
        'file_type': fileType,
        'success': success,
        'error_message': errorMessage,
      },
    );
  }

  /// Log PWA event
  Future<void> logPWAEvent({
    required String action,
    String? status,
    Map<String, Object?>? parameters,
  }) async {
    await logEvent(
      name: 'pwa_event',
      parameters: {
        'action': action,
        'status': status,
        ...?parameters,
      },
    );
  }

  /// Start performance trace
  Future<void> startTrace(String traceName) async {
    if (!isEnabled || _performance == null) return;

    try {
      final trace = _performance!.newTrace(traceName);
      await trace.start();
      _activeTraces[traceName] = trace;

      debugPrint('Analytics: Trace started: $traceName');
    } catch (e) {
      debugPrint('Analytics: Failed to start trace: $e');
    }
  }

  /// Stop performance trace
  Future<void> stopTrace(String traceName) async {
    if (!isEnabled || !_activeTraces.containsKey(traceName)) return;

    try {
      final trace = _activeTraces[traceName]!;
      await trace.stop();
      _activeTraces.remove(traceName);

      debugPrint('Analytics: Trace stopped: $traceName');
    } catch (e) {
      debugPrint('Analytics: Failed to stop trace: $e');
    }
  }

  /// Add trace metric
  Future<void> addTraceMetric(String traceName, String metricName, int value) async {
    if (!isEnabled || !_activeTraces.containsKey(traceName)) return;

    try {
      final trace = _activeTraces[traceName]!;
      trace.setMetric(metricName, value);

      debugPrint('Analytics: Metric added to trace: $metricName = $value');
    } catch (e) {
      debugPrint('Analytics: Failed to add trace metric: $e');
    }
  }

  /// Log error
  Future<void> logError(
    dynamic error,
    StackTrace? stackTrace, {
    String? context,
    Map<String, Object?>? parameters,
  }) async {
    if (!isEnabled) return;

    try {
      // Log to Crashlytics
      if (_crashlytics != null) {
        await _crashlytics?.recordError(
          error,
          stackTrace,
          reason: context,
        );
      }

      // Log as analytics event
      await logEvent(
        name: 'error_occurred',
        parameters: {
          'error_type': error.runtimeType.toString(),
          'error_message': error.toString(),
          'context': context,
          ...?parameters,
        },
      );

      debugPrint('Analytics: Error logged: $error');
    } catch (e) {
      debugPrint('Analytics: Failed to log error: $e');
    }
  }

  /// Set user ID
  Future<void> setUserId(String userId) async {
    if (!isEnabled) return;

    try {
      await _analytics?.setUserId(id: userId);
      await _crashlytics?.setUserId(userId);

      debugPrint('Analytics: User ID set: $userId');
    } catch (e) {
      debugPrint('Analytics: Failed to set user ID: $e');
    }
  }

  /// Set user property
  Future<void> setUserProperty({
    required String name,
    required String? value,
  }) async {
    if (!isEnabled || _analytics == null) return;

    try {
      await _analytics?.setUserProperty(name: name, value: value);

      debugPrint('Analytics: User property set: $name = $value');
    } catch (e) {
      debugPrint('Analytics: Failed to set user property: $e');
    }
  }

  /// Log web vitals
  Future<void> logWebVitals({
    required String metric,
    required double value,
    String? rating,
  }) async {
    if (!isEnabled) return;

    await logEvent(
      name: 'web_vitals',
      parameters: {
        'metric': metric,
        'value': value,
        'rating': rating,
      },
    );
  }

  /// Log app performance
  Future<void> logAppPerformance({
    required String metric,
    required double value,
    Map<String, Object?>? context,
  }) async {
    if (!isEnabled) return;

    await logEvent(
      name: 'app_performance',
      parameters: {
        'metric': metric,
        'value': value,
        'context': jsonEncode(context),
      },
    );
  }

  /// Enable/disable analytics collection
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {
    if (_analytics == null) return;

    try {
      await _analytics?.setAnalyticsCollectionEnabled(enabled);
      _isEnabled = enabled;

      debugPrint('Analytics: Collection enabled: $enabled');
    } catch (e) {
      debugPrint('Analytics: Failed to set analytics collection: $e');
    }
  }

  /// Track session
  Future<void> trackSessionStart() async {
    await logEvent(
      name: 'session_start',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
        'environment': EnvironmentConfig.currentEnvironment,
        'platform': kIsWeb ? 'web' : 'mobile',
      },
    );
  }

  /// Track session end
  Future<void> trackSessionEnd() async {
    await logEvent(
      name: 'session_end',
      parameters: {
        'timestamp': DateTime.now().toIso8601String(),
        'duration': 0, // Would need to track actual duration
      },
    );
  }

  /// Dispose resources
  void dispose() {
    // Stop all active traces
    for (final trace in _activeTraces.values) {
      trace.stop();
    }
    _activeTraces.clear();
  }
}