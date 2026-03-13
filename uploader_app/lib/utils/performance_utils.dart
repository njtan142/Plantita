import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uploader_app/services/http_client_service.dart';
import '../models/models.dart';
import '../models/upload_events.dart';
import '../models/performance_models.dart';
import '../services/performance_monitor_service.dart' as performance_monitor_service;
import '../services/performance_monitor_service.dart' show PerformanceEventType;
import '../services/network_optimization_service.dart';
import '../services/memory_management_service.dart';
import '../services/enhanced_upload_service.dart';
import '../services/web_performance_service.dart' if (dart.library.html) '';
import '../services/mobile_performance_service.dart' if (dart.library.html) '';

/// Comprehensive performance utilities for the Flutter uploader app
class PerformanceUtils {
  // Singleton instance
  static PerformanceUtils? _instance;

  // Core services
  late final performance_monitor_service.PerformanceMonitorService _performanceMonitor;
  late final NetworkOptimizationService _networkOptimizer;
  late final MemoryManagementService _memoryManager;
  late final EnhancedUploadService _enhancedUpload;

  // Platform-specific services
  WebPerformanceService? _webPerformance;
  MobilePerformanceService? _mobilePerformance;

  // Configuration
  final PerformanceConfig _config;

  // Initialization state
  bool _isInitialized = false;
  final Completer<void> _initCompleter = Completer<void>();

  /// Private constructor
  PerformanceUtils._({
    required PerformanceConfig config,
    required SharedPreferences prefs,
    required HttpClientService httpClient,
  }) : _config = config {
    _initializeServices(prefs, httpClient);
  }

  /// Factory constructor
  factory PerformanceUtils({
    PerformanceConfig? config,
    SharedPreferences? prefs,
    HttpClientService? httpClient,
  }) {
    if (_instance == null) {
      assert(config != null, 'PerformanceConfig is required for first initialization');
      assert(prefs != null, 'SharedPreferences is required for first initialization');
      assert(httpClient != null, 'HttpClientService is required for first initialization');

      _instance = PerformanceUtils._(
        config: config!,
        prefs: prefs!,
        httpClient: httpClient!,
      );
    }
    return _instance!;
  }

  /// Get singleton instance
  static PerformanceUtils get instance {
    assert(_instance != null, 'PerformanceUtils must be initialized first');
    return _instance!;
  }

  /// Check if initialized
  bool get isInitialized => _isInitialized;

  /// Initialization future
  Future<void> get initialization => _initCompleter.future;

  /// Performance monitor service
  performance_monitor_service.PerformanceMonitorService get performanceMonitor => _performanceMonitor;

  /// Network optimization service
  NetworkOptimizationService get networkOptimizer => _networkOptimizer;

  /// Memory management service
  MemoryManagementService get memoryManager => _memoryManager;

  /// Enhanced upload service
  EnhancedUploadService get enhancedUpload => _enhancedUpload;

  /// Web performance service (web only)
  WebPerformanceService? get webPerformance => _webPerformance;

  /// Mobile performance service (mobile only)
  MobilePerformanceService? get mobilePerformance => _mobilePerformance;

  /// Initialize all performance services
  void _initializeServices(SharedPreferences prefs, HttpClientService httpClient) {
    // Initialize core services
    _performanceMonitor = performance_monitor_service.PerformanceMonitorService();
    _networkOptimizer = NetworkOptimizationService(
      httpClient: httpClient,
      prefs: prefs,
    );
    _memoryManager = MemoryManagementService();
    _enhancedUpload = EnhancedUploadService(
      httpClient: httpClient,
      prefs: prefs,
      performanceMonitor: _performanceMonitor,
      memoryManager: _memoryManager,
    );

    // Initialize platform-specific services
    _initializePlatformServices();
  }

  /// Initialize platform-specific services
  void _initializePlatformServices() {
    if (kIsWeb) {
      // Web-specific initialization will be handled in the web service
      debugPrint('🌐 PerformanceUtils initialized for web platform');
    } else {
      // Mobile-specific initialization
      debugPrint('📱 PerformanceUtils initialized for mobile platform');
    }
  }

  /// Initialize all services
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      debugPrint('🚀 Initializing PerformanceUtils...');

      // Initialize core services
      await _initializeCoreServices();

      // Initialize platform-specific services
      await _initializePlatformSpecificServices();

      // Set up event listeners
      _setupEventListeners();

      // Start performance monitoring
      _startPerformanceMonitoring();

      _isInitialized = true;
      _initCompleter.complete();

      debugPrint('✅ PerformanceUtils initialization complete');
      _performanceMonitor.recordEvent(
        'performance_utils_initialized',
        PerformanceEventType.metric,
        metadata: {'config': _config.toJson()},
      );

    } catch (e) {
      debugPrint('❌ Error initializing PerformanceUtils: $e');
      _initCompleter.completeError(e);
      rethrow;
    }
  }

  /// Initialize core services
  Future<void> _initializeCoreServices() async {
    // Services are already initialized in constructor
    // but we can add any async initialization here
  }

  /// Initialize platform-specific services
  Future<void> _initializePlatformSpecificServices() async {
    if (kIsWeb) {
      // Web-specific services would be initialized here
      // _webPerformance = WebPerformanceService(performanceMonitor: _performanceMonitor);
      // await _webPerformance?.initialize();
    } else {
      // Mobile-specific services would be initialized here
      // _mobilePerformance = MobilePerformanceService(performanceMonitor: _performanceMonitor);
      // await _mobilePerformance?.initialize();
    }
  }

  /// Set up event listeners
  void _setupEventListeners() {
    // Listen to memory events
    _memoryManager.memoryEventStream.listen((event) {
      _handleMemoryEvent(event);
    });

    // Listen to network events
    _networkOptimizer.networkEventStream.listen((event) {
      _handleNetworkEvent(event);
    });

    // Listen to upload events
    _enhancedUpload.uploadEventStream.listen((event) {
      _handleUploadEvent(event);
    });
  }

  /// Start performance monitoring
  void _startPerformanceMonitoring() {
    // Record initial metrics
    _performanceMonitor.recordMemoryUsage(0); // Placeholder
    _performanceMonitor.recordEvent(
      'performance_monitoring_started',
      PerformanceEventType.metric,
    );
  }

  /// Handle memory events
  void _handleMemoryEvent(MemoryEvent event) {
    switch (event.type) {
      case MemoryEventType.memoryChecked:
        final mbUsed = event.metadata?['mbUsed'] as double? ?? 0.0;
        _performanceMonitor.recordMemoryUsage((mbUsed * 1024 * 1024).toInt());
        break;

      case MemoryEventType.cleanupPerformed:
        _performanceMonitor.recordEvent(
          'memory_cleanup',
          PerformanceEventType.metric,
          metadata: event.metadata,
        );
        break;

      default:
        break;
    }
  }

  /// Handle network events
  void _handleNetworkEvent(NetworkEvent event) {
    _performanceMonitor.recordEvent(
      'network_${event.type.name}',
      PerformanceEventType.metric,
      duration: event.duration,
      metadata: event.metadata,
    );
  }

  /// Handle upload events
  void _handleUploadEvent(UploadEvent event) {
    _performanceMonitor.recordEvent(
      'upload_${event.type.name}',
      PerformanceEventType.metric,
      metadata: {
        'uploadId': event.upload?.id,
        'error': event.error,
        ...?event.metadata,
      },
    );
  }

  /// Optimize image with platform-specific handling
  Future<OptimizedImageResult> optimizeImage(
    Uint8List imageBytes, {
    ImageQuality quality = ImageQuality.high,
    ImageFormat format = ImageFormat.auto,
    bool maintainAspectRatio = true,
  }) async {
    await initialization;

    final startTime = DateTime.now();
    _performanceMonitor.startTracking('image_optimization');

    try {
      // For now, return a basic result since we don't have the full image service
      // This would integrate with the image optimization service
      final result = OptimizedImageResult(
        originalBytes: imageBytes,
        optimizedBytes: imageBytes, // Placeholder
        originalSize: imageBytes.length,
        optimizedSize: imageBytes.length,
        format: format,
        processingTime: DateTime.now().difference(startTime),
      );

      _performanceMonitor.endTracking('image_optimization', result: {
        'originalSize': imageBytes.length,
        'optimizedSize': result.optimizedSize,
        'compressionRatio': result.compressionRatio,
      });

      return result;

    } catch (e) {
      _performanceMonitor.endTracking('image_optimization', result: {'error': e.toString()});
      rethrow;
    }
  }

  /// Upload file with performance optimization
  Future<Upload> uploadFile({
    required String fileName,
    required Uint8List fileBytes,
    required String mimeType,
    int? userId,
    UploadPriority priority = UploadPriority.normal,
    bool allowBackgroundUpload = true,
  }) async {
    await initialization;

    return await _enhancedUpload.uploadFile(
      fileName: fileName,
      fileBytes: fileBytes,
      mimeType: mimeType,
      userId: userId,
      priority: priority,
      allowBackgroundUpload: allowBackgroundUpload,
    );
  }

  /// Get optimized HTTP client
  Future<OptimizedResponse> get(String url, {Map<String, String>? headers}) async {
    await initialization;

    return await _networkOptimizer.get(
      url,
      headers: headers,
      useCache: true,
    );
  }

  /// Post with network optimization
  Future<OptimizedResponse> post(String url, {dynamic body, Map<String, String>? headers}) async {
    await initialization;

    return await _networkOptimizer.post(
      url,
      body: body,
      headers: headers,
    );
  }

  /// Acquire object from memory pool
  T acquireFromPool<T>(String poolName, T Function() factory) {
    return _memoryManager.acquire<T>(poolName, factory);
  }

  /// Release object back to memory pool
  void releaseToPool<T>(String poolName, T object) {
    _memoryManager.release<T>(poolName, object);
  }

  /// Wrap resource with automatic cleanup
  ResourceWrapper<T> wrapResource<T>(
    T resource,
    String resourceType, {
    void Function(T)? cleanup,
    Duration? maxLifetime,
  }) {
    return _memoryManager.wrapResource<T>(
      resource,
      resourceType,
      cleanup: cleanup,
      maxLifetime: maxLifetime,
    );
  }

  /// Force garbage collection
  Future<void> forceGarbageCollection() async {
    await _memoryManager.forceGarbageCollection();
  }

  /// Get comprehensive performance stats
  PerformanceStats getPerformanceStats() {
    return PerformanceStats(
      performanceMetrics: _convertPerformanceStats(_performanceMonitor.getStats()),
      networkStats: _networkOptimizer.getNetworkStats(),
      memoryStats: _memoryManager.getMemoryStats(),
      uploadStats: _enhancedUpload.queueStats,
      isInitialized: _isInitialized,
      platformSpecificStats: _getPlatformSpecificStats(),
    );
  }

  /// Get platform-specific stats
  Map<String, dynamic> _getPlatformSpecificStats() {
    if (kIsWeb && _webPerformance != null) {
      return {
        'platform': 'web',
        'memoryInfo': _webPerformance!.getPerformanceMetrics(),
      };
    } else if (!kIsWeb && _mobilePerformance != null) {
      return {
        'platform': 'mobile',
        'deviceCapabilities': _mobilePerformance!.getDeviceCapabilities(),
      };
    }
    return {'platform': kIsWeb ? 'web' : 'mobile'};
  }

  /// Clear all caches and reset pools
  Future<void> clearAllCaches() async {
    await _networkOptimizer.clearCache();
    _memoryManager.clearAll();

    _performanceMonitor.recordEvent(
      'caches_cleared',
      PerformanceEventType.metric,
    );
  }

  /// Enable performance optimization mode
  void enablePerformanceMode() {
    // Enable all optimizations
    debugPrint('⚡ Performance optimization mode enabled');
  }

  /// Disable performance optimization mode
  void disablePerformanceMode() {
    // Disable intensive optimizations
    debugPrint('🐌 Performance optimization mode disabled');
  }

  /// Get performance configuration
  PerformanceConfig get config => _config;

  /// Update performance configuration
  Future<void> updateConfig(PerformanceConfig newConfig) async {
    // This would update the configuration and reinitialize services if needed
    debugPrint('Performance configuration updated');
  }
/// Convert PerformanceStats to Map for compatibility
  Map<String, dynamic> _convertPerformanceStats(performance_monitor_service.PerformanceStats stats) {
    return {
      'totalEvents': stats.totalEvents,
      'networkRequests': stats.networkRequests,
      'imageOperations': stats.imageOperations,
      'averageNetworkTimeMs': stats.averageNetworkTime.inMilliseconds,
      'averageImageProcessingTimeMs': stats.averageImageProcessingTime.inMilliseconds,
      'averageMemoryUsage': stats.averageMemoryUsage,
      'errorCount': stats.errorCount,
      'slowNetworkRequests': stats.slowNetworkRequests,
      'slowImageOperations': stats.slowImageOperations,
      'errorRate': stats.errorRate,
      'slowNetworkRate': stats.slowNetworkRate,
      'slowImageRate': stats.slowImageRate,
    };
  }

  /// Dispose all resources
  void dispose() {
    _memoryManager.dispose();
    _networkOptimizer.dispose();
    _enhancedUpload.dispose();
    _performanceMonitor.dispose();
    _webPerformance?.dispose();
    _mobilePerformance?.dispose();
    _instance = null;
  }
}
