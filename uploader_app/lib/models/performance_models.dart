import 'dart:typed_data';
import '../services/network_optimization_service.dart';
import '../services/memory_management_service.dart';
import 'upload_events.dart';

/// Performance configuration
class PerformanceConfig {
  final bool enablePerformanceMonitoring;
  final bool enableNetworkOptimization;
  final bool enableMemoryOptimization;
  final bool enableImageOptimization;
  final bool enableWebOptimizations;
  final bool enableMobileOptimizations;
  final bool enableOfflineUploads;
  final int maxCacheSize;
  final Duration cacheExpirationDuration;
  final int maxConcurrentUploads;
  final int maxPoolSize;
  final bool enableServiceWorker;
  final bool enableWebWorker;
  final bool enableBackgroundFetch;

  const PerformanceConfig({
    this.enablePerformanceMonitoring = true,
    this.enableNetworkOptimization = true,
    this.enableMemoryOptimization = true,
    this.enableImageOptimization = true,
    this.enableWebOptimizations = true,
    this.enableMobileOptimizations = true,
    this.enableOfflineUploads = true,
    this.maxCacheSize = 50 * 1024 * 1024, // 50MB
    this.cacheExpirationDuration = const Duration(hours: 24),
    this.maxConcurrentUploads = 3,
    this.maxPoolSize = 100,
    this.enableServiceWorker = true,
    this.enableWebWorker = true,
    this.enableBackgroundFetch = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'enablePerformanceMonitoring': enablePerformanceMonitoring,
      'enableNetworkOptimization': enableNetworkOptimization,
      'enableMemoryOptimization': enableMemoryOptimization,
      'enableImageOptimization': enableImageOptimization,
      'enableWebOptimizations': enableWebOptimizations,
      'enableMobileOptimizations': enableMobileOptimizations,
      'enableOfflineUploads': enableOfflineUploads,
      'maxCacheSize': maxCacheSize,
      'cacheExpirationDuration': cacheExpirationDuration.inSeconds,
      'maxConcurrentUploads': maxConcurrentUploads,
      'maxPoolSize': maxPoolSize,
      'enableServiceWorker': enableServiceWorker,
      'enableWebWorker': enableWebWorker,
      'enableBackgroundFetch': enableBackgroundFetch,
    };
  }

  factory PerformanceConfig.fromJson(Map<String, dynamic> json) {
    return PerformanceConfig(
      enablePerformanceMonitoring: json['enablePerformanceMonitoring'] ?? true,
      enableNetworkOptimization: json['enableNetworkOptimization'] ?? true,
      enableMemoryOptimization: json['enableMemoryOptimization'] ?? true,
      enableImageOptimization: json['enableImageOptimization'] ?? true,
      enableWebOptimizations: json['enableWebOptimizations'] ?? true,
      enableMobileOptimizations: json['enableMobileOptimizations'] ?? true,
      enableOfflineUploads: json['enableOfflineUploads'] ?? true,
      maxCacheSize: json['maxCacheSize'] ?? 50 * 1024 * 1024,
      cacheExpirationDuration: Duration(seconds: json['cacheExpirationDuration'] ?? 24 * 60 * 60),
      maxConcurrentUploads: json['maxConcurrentUploads'] ?? 3,
      maxPoolSize: json['maxPoolSize'] ?? 100,
      enableServiceWorker: json['enableServiceWorker'] ?? true,
      enableWebWorker: json['enableWebWorker'] ?? true,
      enableBackgroundFetch: json['enableBackgroundFetch'] ?? true,
    );
  }
}

/// Optimized image result
class OptimizedImageResult {
  final Uint8List originalBytes;
  final Uint8List optimizedBytes;
  final int originalSize;
  final int optimizedSize;
  final ImageFormat format;
  final Duration processingTime;

  const OptimizedImageResult({
    required this.originalBytes,
    required this.optimizedBytes,
    required this.originalSize,
    required this.optimizedSize,
    required this.format,
    required this.processingTime,
  });

  double get compressionRatio => originalSize > 0 ? optimizedSize / originalSize : 0;
  double get sizeReduction => (originalSize - optimizedSize).toDouble();
  double get processingSpeed => originalSize / processingTime.inMilliseconds; // bytes per ms

  @override
  String toString() {
    return 'OptimizedImageResult(size: ${optimizedSize ~/ 1024}KB, ratio: ${(compressionRatio * 100).toStringAsFixed(1)}%, time: ${processingTime.inMilliseconds}ms)';
  }
}

/// Comprehensive performance statistics
class PerformanceStats {
  final Map<String, dynamic> performanceMetrics;
  final NetworkStats networkStats;
  final MemoryStats memoryStats;
  final UploadQueueStats uploadStats;
  final bool isInitialized;
  final Map<String, dynamic> platformSpecificStats;

  const PerformanceStats({
    required this.performanceMetrics,
    required this.networkStats,
    required this.memoryStats,
    required this.uploadStats,
    required this.isInitialized,
    required this.platformSpecificStats,
  });

  Map<String, dynamic> toJson() {
    return {
      'performanceMetrics': performanceMetrics.toString(),
      'networkStats': networkStats.toString(),
      'memoryStats': memoryStats.toString(),
      'uploadStats': {
        'activeUploads': uploadStats.activeUploads,
        'offlineQueueLength': uploadStats.offlineQueueLength,
        'failedUploads': uploadStats.failedUploads,
      },
      'isInitialized': isInitialized,
      'platformSpecificStats': platformSpecificStats,
    };
  }
}

/// Image quality settings
enum ImageQuality {
  low,
  medium,
  high,
  original,
}

/// Image format options
enum ImageFormat {
  auto,
  jpeg,
  png,
  webp,
}
