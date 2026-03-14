/// Analytics event types for consistent naming
class AnalyticsEvents {
  static const String userAction = 'user_action';
  static const String uploadEvent = 'upload_event';
  static const String pwaEvent = 'pwa_event';
  static const String errorOccurred = 'error_occurred';
  static const String webVitals = 'web_vitals';
  static const String appPerformance = 'app_performance';
  static const String sessionStart = 'session_start';
  static const String sessionEnd = 'session_end';
}

/// Analytics parameter names for consistent naming
class AnalyticsParams {
  static const String action = 'action';
  static const String status = 'status';
  static const String fileSize = 'file_size';
  static const String fileType = 'file_type';
  static const String success = 'success';
  static const String errorMessage = 'error_message';
  static const String errorType = 'error_type';
  static const String context = 'context';
  static const String metric = 'metric';
  static const String value = 'value';
  static const String rating = 'rating';
  static const String timestamp = 'timestamp';
  static const String environment = 'environment';
  static const String platform = 'platform';
  static const String duration = 'duration';
}

/// Analytics event data for custom tracking
class AnalyticsEventData {
  final String name;
  final Map<String, Object?>? parameters;

  const AnalyticsEventData({
    required this.name,
    this.parameters,
  });
}
