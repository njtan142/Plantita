/// Web-specific memory information
class WebMemoryInfo {
  final int usedJSHeapSize;
  final int totalJSHeapSize;
  final int jsHeapSizeLimit;

  const WebMemoryInfo({
    required this.usedJSHeapSize,
    required this.totalJSHeapSize,
    required this.jsHeapSizeLimit,
  });

  double get memoryUsagePercentage => usedJSHeapSize / jsHeapSizeLimit;
  double get availableMemory => (jsHeapSizeLimit - usedJSHeapSize).toDouble();

  @override
  String toString() {
    return 'WebMemoryInfo(used: ${usedJSHeapSize ~/ 1024}KB, total: ${totalJSHeapSize ~/ 1024}KB, limit: ${jsHeapSizeLimit ~/ 1024}KB)';
  }
}

/// Web performance event types
enum WebPerformanceEventType {
  initialized,
  serviceWorkerRegistered,
  serviceWorkerUpdated,
  webWorkerMessage,
  webWorkerError,
  performanceMeasured,
  performanceDataCleared,
  garbageCollectionForced,
  cacheStorageReady,
  resourceCached,
  cacheHit,
  cacheMiss,
  connectionOptimized,
  resourcePreloaded,
  error,
}

/// Web performance event data
class WebPerformanceEvent {
  final WebPerformanceEventType type;
  final Map<String, dynamic>? metadata;

  const WebPerformanceEvent({
    required this.type,
    this.metadata,
  });
}
