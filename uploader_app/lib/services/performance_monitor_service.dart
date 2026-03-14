import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/performance_monitor_models.dart';

export '../models/performance_monitor_models.dart' show PerformanceEventType;

/// Performance monitoring service for tracking app metrics
class PerformanceMonitorService {
  final Map<String, MetricTracker> _trackers = {};
  final StreamController<PerformanceEvent> _eventController = StreamController.broadcast();

  // Performance thresholds
  final Duration _slowRequestThreshold;
  final Duration _slowImageProcessingThreshold;
  final int _highMemoryUsageThreshold; // MB
  final double _lowBatteryThreshold;

  // Metrics storage
  final Queue<PerformanceEvent> _eventHistory = Queue();
  final int _maxEventHistory;

  PerformanceMonitorService({
    Duration slowRequestThreshold = const Duration(seconds: 2),
    Duration slowImageProcessingThreshold = const Duration(seconds: 5),
    int highMemoryUsageThreshold = 100, // MB
    double lowBatteryThreshold = 0.2, // 20%
    int maxEventHistory = 1000,
  })  : _slowRequestThreshold = slowRequestThreshold,
        _slowImageProcessingThreshold = slowImageProcessingThreshold,
        _highMemoryUsageThreshold = highMemoryUsageThreshold,
        _lowBatteryThreshold = lowBatteryThreshold,
        _maxEventHistory = maxEventHistory;

  /// Stream of performance events
  Stream<PerformanceEvent> get eventStream => _eventController.stream;

  /// Start tracking a metric
  void startTracking(String metricName, {Map<String, dynamic>? metadata}) {
    _trackers[metricName] = MetricTracker(
      name: metricName,
      startTime: DateTime.now(),
      metadata: metadata,
    );
  }

  /// End tracking a metric and record the result
  void endTracking(String metricName, {Map<String, dynamic>? result}) {
    final tracker = _trackers.remove(metricName);
    if (tracker != null) {
      final duration = DateTime.now().difference(tracker.startTime);
      _recordEvent(
        PerformanceEvent(
          type: PerformanceEventType.metric,
          name: metricName,
          duration: duration,
          metadata: {
            ...?tracker.metadata,
            ...?result,
            'startTime': tracker.startTime,
            'endTime': DateTime.now(),
          },
        ),
      );
    }
  }

  /// Track network request performance
  Future<T> trackNetworkRequest<T>(
    String requestName,
    Future<T> Function() request, {
    Map<String, dynamic>? metadata,
  }) async {
    startTracking('network_$requestName', metadata: metadata);

    try {
      final result = await request();
      endTracking('network_$requestName', result: {'success': true});
      return result;
    } catch (e) {
      endTracking('network_$requestName', result: {
        'success': false,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Track image processing performance
  Future<T> trackImageProcessing<T>(
    String operationName,
    Future<T> Function() operation, {
    Map<String, dynamic>? metadata,
  }) async {
    startTracking('image_$operationName', metadata: metadata);

    try {
      final result = await operation();
      endTracking('image_$operationName', result: {'success': true});
      return result;
    } catch (e) {
      endTracking('image_$operationName', result: {
        'success': false,
        'error': e.toString(),
      });
      rethrow;
    }
  }

  /// Record a custom performance event
  void recordEvent(
    String name,
    PerformanceEventType type, {
    Duration? duration,
    Map<String, dynamic>? metadata,
  }) {
    _recordEvent(PerformanceEvent(
      type: type,
      name: name,
      duration: duration,
      metadata: metadata,
    ));
  }

  /// Record memory usage
  void recordMemoryUsage(int bytesUsed, {Map<String, dynamic>? metadata}) {
    final mbUsed = bytesUsed / (1024 * 1024);
    _recordEvent(PerformanceEvent(
      type: PerformanceEventType.memory,
      name: 'memory_usage',
      metadata: {
        ...?metadata,
        'bytesUsed': bytesUsed,
        'mbUsed': mbUsed,
        'highUsage': mbUsed > _highMemoryUsageThreshold,
      },
    ));
  }

  /// Record battery level
  void recordBatteryLevel(double level, {Map<String, dynamic>? metadata}) {
    _recordEvent(PerformanceEvent(
      type: PerformanceEventType.battery,
      name: 'battery_level',
      metadata: {
        ...?metadata,
        'level': level,
        'lowBattery': level < _lowBatteryThreshold,
      },
    ));
  }

  /// Record connectivity change
  void recordConnectivityChange(ConnectivityResult connectivity) {
    _recordEvent(PerformanceEvent(
      type: PerformanceEventType.connectivity,
      name: 'connectivity_change',
      metadata: {'connectivity': connectivity.name},
    ));
  }

  /// Get performance statistics
  PerformanceMonitorStats getStats() {
    final events = _eventHistory.toList();

    final networkEvents = events.where((e) => e.type == PerformanceEventType.metric && e.name.startsWith('network_'));
    final imageEvents = events.where((e) => e.type == PerformanceEventType.metric && e.name.startsWith('image_'));
    final memoryEvents = events.where((e) => e.type == PerformanceEventType.memory);
    final errorEvents = events.where((e) => e.metadata?['success'] == false);

    final avgNetworkTime = networkEvents.isEmpty
        ? Duration.zero
        : Duration(
            milliseconds: (networkEvents.map((e) => e.duration?.inMilliseconds ?? 0).reduce((a, b) => a + b) / networkEvents.length).round(),
          );

    final avgImageTime = imageEvents.isEmpty
        ? Duration.zero
        : Duration(
            milliseconds: (imageEvents.map((e) => e.duration?.inMilliseconds ?? 0).reduce((a, b) => a + b) / imageEvents.length).round(),
          );

    final avgMemoryUsage = memoryEvents.isEmpty
        ? 0.0
        : memoryEvents.map((e) => e.metadata?['mbUsed'] as double? ?? 0.0).reduce((a, b) => a + b) / memoryEvents.length;

    return PerformanceMonitorStats(
      totalEvents: events.length,
      networkRequests: networkEvents.length,
      imageOperations: imageEvents.length,
      averageNetworkTime: avgNetworkTime,
      averageImageProcessingTime: avgImageTime,
      averageMemoryUsage: avgMemoryUsage,
      errorCount: errorEvents.length,
      slowNetworkRequests: networkEvents.where((e) => (e.duration ?? Duration.zero) > _slowRequestThreshold).length,
      slowImageOperations: imageEvents.where((e) => (e.duration ?? Duration.zero) > _slowImageProcessingThreshold).length,
    );
  }

  /// Get recent events
  List<PerformanceEvent> getRecentEvents({int limit = 50}) {
    return _eventHistory.toList().reversed.take(limit).toList().reversed.toList();
  }

  /// Clear event history
  void clearHistory() {
    _eventHistory.clear();
  }

  /// Internal method to record events
  void _recordEvent(PerformanceEvent event) {
    final eventWithTimestamp = event.copyWith(
      metadata: {
        ...?event.metadata,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );

    _eventHistory.add(eventWithTimestamp);
    if (_eventHistory.length > _maxEventHistory) {
      _eventHistory.removeFirst();
    }

    _eventController.add(eventWithTimestamp);

    _checkPerformanceThresholds(eventWithTimestamp);
  }

  /// Check performance thresholds and log warnings
  void _checkPerformanceThresholds(PerformanceEvent event) {
    if (event.type == PerformanceEventType.metric) {
      if (event.name.startsWith('network_') && (event.duration ?? Duration.zero) > _slowRequestThreshold) {
        debugPrint('🚨 Slow network request detected: ${event.name} took ${event.duration?.inMilliseconds}ms');
      } else if (event.name.startsWith('image_') && (event.duration ?? Duration.zero) > _slowImageProcessingThreshold) {
        debugPrint('🚨 Slow image processing detected: ${event.name} took ${event.duration?.inMilliseconds}ms');
      }
    } else if (event.type == PerformanceEventType.memory) {
      final mbUsed = event.metadata?['mbUsed'] as double? ?? 0.0;
      if (mbUsed > _highMemoryUsageThreshold) {
        debugPrint('🚨 High memory usage detected: ${mbUsed.toStringAsFixed(2)}MB');
      }
    }
  }

  /// Dispose resources
  void dispose() {
    _eventController.close();
    _trackers.clear();
    _eventHistory.clear();
  }
}
