/// Metric tracker for timing operations
class MetricTracker {
  final String name;
  final DateTime startTime;
  final Map<String, dynamic>? metadata;

  const MetricTracker({
    required this.name,
    required this.startTime,
    this.metadata,
  });
}

/// Performance event types
enum PerformanceEventType {
  metric,
  memory,
  battery,
  connectivity,
  error,
}

/// Performance event data
class PerformanceEvent {
  final PerformanceEventType type;
  final String name;
  final Duration? duration;
  final Map<String, dynamic>? metadata;

  const PerformanceEvent({
    required this.type,
    required this.name,
    this.duration,
    this.metadata,
  });

  PerformanceEvent copyWith({
    PerformanceEventType? type,
    String? name,
    Duration? duration,
    Map<String, dynamic>? metadata,
  }) {
    return PerformanceEvent(
      type: type ?? this.type,
      name: name ?? this.name,
      duration: duration ?? this.duration,
      metadata: metadata ?? this.metadata,
    );
  }
}

/// Performance statistics
class PerformanceMonitorStats {
  final int totalEvents;
  final int networkRequests;
  final int imageOperations;
  final Duration averageNetworkTime;
  final Duration averageImageProcessingTime;
  final double averageMemoryUsage;
  final int errorCount;
  final int slowNetworkRequests;
  final int slowImageOperations;

  const PerformanceMonitorStats({
    required this.totalEvents,
    required this.networkRequests,
    required this.imageOperations,
    required this.averageNetworkTime,
    required this.averageImageProcessingTime,
    required this.averageMemoryUsage,
    required this.errorCount,
    required this.slowNetworkRequests,
    required this.slowImageOperations,
  });

  double get errorRate => networkRequests > 0 ? errorCount / networkRequests : 0;
  double get slowNetworkRate => networkRequests > 0 ? slowNetworkRequests / networkRequests : 0;
  double get slowImageRate => imageOperations > 0 ? slowImageOperations / imageOperations : 0;

  @override
  String toString() {
    return 'PerformanceMonitorStats('
        'events: $totalEvents, '
        'network: $networkRequests (${averageNetworkTime.inMilliseconds}ms avg), '
        'images: $imageOperations (${averageImageProcessingTime.inMilliseconds}ms avg), '
        'memory: ${averageMemoryUsage.toStringAsFixed(1)}MB, '
        'errors: $errorCount (${(errorRate * 100).toStringAsFixed(1)}%), '
        'slowNetwork: $slowNetworkRequests (${(slowNetworkRate * 100).toStringAsFixed(1)}%), '
        'slowImages: $slowImageOperations (${(slowImageRate * 100).toStringAsFixed(1)}%))';
  }
}
