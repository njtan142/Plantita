import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:universal_html/html.dart' as web_html;

/// Web-specific performance optimization service
class WebPerformanceService {
  final PerformanceMonitorService _performanceMonitor;
  final StreamController<WebPerformanceEvent> _eventController = StreamController.broadcast();

  // Web APIs
  web_html.ServiceWorker? _serviceWorker;
  web_html.CacheStorage? _cacheStorage;
  web_html.Worker? _webWorker;

  // Performance observers
  web_html.PerformanceObserver? _performanceObserver;
  web_html.PerformanceObserver? _resourceObserver;
  web_html.PerformanceObserver? _navigationObserver;

  // Configuration
  final bool _enableServiceWorker;
  final bool _enableWebWorker;
  final bool _enablePerformanceMonitoring;
  final Duration _cacheExpirationDuration;
  final int _maxCacheSize;

  // State
  bool _isInitialized = false;
  final Map<String, dynamic> _performanceMetrics = {};

  WebPerformanceService({
    required PerformanceMonitorService performanceMonitor,
    bool enableServiceWorker = true,
    bool enableWebWorker = true,
    bool enablePerformanceMonitoring = true,
    Duration cacheExpirationDuration = const Duration(hours: 24),
    int maxCacheSize = 50 * 1024 * 1024, // 50MB
  })  : _performanceMonitor = performanceMonitor,
        _enableServiceWorker = enableServiceWorker,
        _enableWebWorker = enableWebWorker,
        _enablePerformanceMonitoring = enablePerformanceMonitoring,
        _cacheExpirationDuration = cacheExpirationDuration,
        _maxCacheSize = maxCacheSize;

  /// Stream of web performance events
  Stream<WebPerformanceEvent> get eventStream => _eventController.stream;

  /// Initialize web-specific optimizations
  Future<void> initialize() async {
    if (!kIsWeb || _isInitialized) return;

    try {
      _performanceMonitor.startTracking('web_performance_init');

      // Initialize service worker
      if (_enableServiceWorker) {
        await _initializeServiceWorker();
      }

      // Initialize web worker
      if (_enableWebWorker) {
        await _initializeWebWorker();
      }

      // Initialize performance monitoring
      if (_enablePerformanceMonitoring) {
        await _initializePerformanceMonitoring();
      }

      // Initialize cache storage
      await _initializeCacheStorage();

      // Optimize for current connection
      await _optimizeForConnection();

      _isInitialized = true;

      _performanceMonitor.endTracking('web_performance_init', result: {
        'serviceWorker': _serviceWorker != null,
        'webWorker': _webWorker != null,
        'performanceMonitoring': _performanceObserver != null,
      });

      _eventController.add(const WebPerformanceEvent(
        type: WebPerformanceEventType.initialized,
        metadata: {'success': true},
      ));

    } catch (e) {
      debugPrint('Error initializing web performance service: $e');
      _eventController.add(WebPerformanceEvent(
        type: WebPerformanceEventType.error,
        metadata: {'error': e.toString()},
      ));
    }
  }

  /// Initialize service worker for caching and offline support
  Future<void> _initializeServiceWorker() async {
    try {
      if (web_html.window.navigator.serviceWorker == null) {
        debugPrint('Service Worker not supported');
        return;
      }

      final registration = await web_html.window.navigator.serviceWorker!
          .register('/sw.js', {'scope': '/'});

      registration.addEventListener('updatefound', (event) {
        _eventController.add(const WebPerformanceEvent(
          type: WebPerformanceEventType.serviceWorkerUpdated,
        ));
      });

      _serviceWorker = registration.active;

      debugPrint('Service Worker registered successfully');
      _eventController.add(const WebPerformanceEvent(
        type: WebPerformanceEventType.serviceWorkerRegistered,
      ));

    } catch (e) {
      debugPrint('Error initializing service worker: $e');
    }
  }

  /// Initialize web worker for background processing
  Future<void> _initializeWebWorker() async {
    try {
      _webWorker = web_html.Worker('/worker.js');

      _webWorker!.addEventListener('message', (web_html.MessageEvent event) {
        _handleWebWorkerMessage(event.data);
      });

      _webWorker!.addEventListener('error', (event) {
        _eventController.add(WebPerformanceEvent(
          type: WebPerformanceEventType.webWorkerError,
          metadata: {'error': event.toString()},
        ));
      });

      debugPrint('Web Worker initialized successfully');
    } catch (e) {
      debugPrint('Error initializing web worker: $e');
    }
  }

  /// Initialize performance monitoring with web APIs
  Future<void> _initializePerformanceMonitoring() async {
    try {
      // Navigation timing
      _navigationObserver = web_html.PerformanceObserver((entries, observer) {
        for (final entry in entries.getEntries()) {
          _performanceMetrics['navigation'] = {
            'loadTime': entry.loadEventEnd - entry.loadEventStart,
            'domContentLoaded': entry.domContentLoadedEventEnd - entry.domContentLoadedEventStart,
            'totalTime': entry.loadEventEnd - entry.fetchStart,
          };
        }
      });
      _navigationObserver!.observe({'type': 'navigation', 'buffered': true});

      // Resource timing
      _resourceObserver = web_html.PerformanceObserver((entries, observer) {
        for (final entry in entries.getEntries()) {
          if (entry is web_html.PerformanceResourceTiming) {
            _performanceMetrics['resources'] ??= [];
            (_performanceMetrics['resources'] as List).add({
              'url': entry.name,
              'duration': entry.duration,
              'size': entry.transferSize,
              'cached': entry.transferSize == 0,
            });
          }
        }
      });
      _resourceObserver!.observe({'type': 'resource', 'buffered': true});

      // Overall performance observer
      _performanceObserver = web_html.PerformanceObserver((entries, observer) {
        for (final entry in entries.getEntries()) {
          _performanceMonitor.recordEvent(
            'web_performance_entry',
            PerformanceEventType.metric,
            duration: Duration(microseconds: (entry.duration * 1000).round()),
            metadata: {
              'entryType': entry.entryType,
              'name': entry.name,
              'startTime': entry.startTime,
            },
          );
        }
      });
      _performanceObserver!.observe({'entryTypes': ['measure', 'paint', 'frame']});

      debugPrint('Performance monitoring initialized');
    } catch (e) {
      debugPrint('Error initializing performance monitoring: $e');
    }
  }

  /// Initialize cache storage API
  Future<void> _initializeCacheStorage() async {
    try {
      _cacheStorage = web_html.window.caches;
      if (_cacheStorage != null) {
        // Clean expired cache entries
        await _cleanExpiredCache();

        _eventController.add(const WebPerformanceEvent(
          type: WebPerformanceEventType.cacheStorageReady,
        ));
      }
    } catch (e) {
      debugPrint('Error initializing cache storage: $e');
    }
  }

  /// Optimize based on current connection
  Future<void> _optimizeForConnection() async {
    try {
      final connection = js.context['navigator']['connection'];
      if (connection != null) {
        final effectiveType = connection['effectiveType'];
        final saveData = connection['saveData'];

        _performanceMetrics['connection'] = {
          'effectiveType': effectiveType,
          'saveData': saveData,
        };

        _eventController.add(WebPerformanceEvent(
          type: WebPerformanceEventType.connectionOptimized,
          metadata: {
            'effectiveType': effectiveType,
            'saveData': saveData,
          },
        ));

        // Adjust behavior based on connection
        if (effectiveType == 'slow-2g' || effectiveType == '2g') {
          // Enable aggressive compression and caching
          debugPrint('Optimizing for slow connection: $effectiveType');
        } else if (effectiveType == '3g' || effectiveType == '4g') {
          // Standard optimizations
          debugPrint('Standard optimization for connection: $effectiveType');
        }
      }
    } catch (e) {
      debugPrint('Error optimizing for connection: $e');
    }
  }

  /// Cache resource using Cache API
  Future<void> cacheResource(String url, dynamic data, {String? cacheName}) async {
    if (_cacheStorage == null) return;

    try {
      final cache = await _cacheStorage!.open(cacheName ?? 'flutter-app-cache');
      final response = web_html.Response(
        data is String ? data : jsonEncode(data),
        200,
        headers: {'content-type': 'application/json'},
      );

      await cache.put(url, response);

      _eventController.add(WebPerformanceEvent(
        type: WebPerformanceEventType.resourceCached,
        metadata: {'url': url, 'cacheName': cacheName},
      ));

    } catch (e) {
      debugPrint('Error caching resource: $e');
    }
  }

  /// Get cached resource
  Future<dynamic> getCachedResource(String url, {String? cacheName}) async {
    if (_cacheStorage == null) return null;

    try {
      final cache = await _cacheStorage!.open(cacheName ?? 'flutter-app-cache');
      final response = await cache.match(url);

      if (response != null) {
        _eventController.add(WebPerformanceEvent(
          type: WebPerformanceEventType.cacheHit,
          metadata: {'url': url, 'cacheName': cacheName},
        ));
        return response.text();
      }

      _eventController.add(WebPerformanceEvent(
        type: WebPerformanceEventType.cacheMiss,
        metadata: {'url': url, 'cacheName': cacheName},
      ));

    } catch (e) {
      debugPrint('Error getting cached resource: $e');
    }

    return null;
  }

  /// Post message to web worker
  void postMessageToWebWorker(dynamic message) {
    if (_webWorker != null) {
      _webWorker!.postMessage(message);
    }
  }

  /// Handle web worker messages
  void _handleWebWorkerMessage(dynamic message) {
    _eventController.add(WebPerformanceEvent(
      type: WebPerformanceEventType.webWorkerMessage,
      metadata: {'message': message},
    ));
  }

  /// Clean expired cache entries
  Future<void> _cleanExpiredCache() async {
    if (_cacheStorage == null) return;

    try {
      final cacheNames = await _cacheStorage!.keys();
      for (final cacheName in cacheNames) {
        final cache = await _cacheStorage!.open(cacheName);
        final requests = await cache.keys();

        for (final request in requests) {
          // Check if cache entry is expired (simplified)
          // In a real app, you'd check response headers for expiration
          final response = await cache.match(request);
          if (response != null) {
            final date = response.headers['date'];
            if (date != null) {
              final cacheDate = DateTime.parse(date);
              if (DateTime.now().difference(cacheDate) > _cacheExpirationDuration) {
                await cache.delete(request);
              }
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error cleaning expired cache: $e');
    }
  }

  /// Measure custom performance metric
  void measurePerformance(String name, void Function() operation) {
    final start = web_html.window.performance.now();
    operation();
    final end = web_html.window.performance.now();
    final duration = end - start;

    _performanceMonitor.recordEvent(
      name,
      PerformanceEventType.metric,
      duration: Duration(microseconds: (duration * 1000).round()),
    );

    _eventController.add(WebPerformanceEvent(
      type: WebPerformanceEventType.performanceMeasured,
      metadata: {'name': name, 'duration': duration},
    ));
  }

  /// Get memory usage information
  Future<WebMemoryInfo?> getMemoryInfo() async {
    try {
      final memory = js.context['performance']['memory'];
      if (memory != null) {
        return WebMemoryInfo(
          usedJSHeapSize: memory['usedJSHeapSize'],
          totalJSHeapSize: memory['totalJSHeapSize'],
          jsHeapSizeLimit: memory['jsHeapSizeLimit'],
        );
      }
    } catch (e) {
      debugPrint('Error getting memory info: $e');
    }
    return null;
  }

  /// Force garbage collection (if available)
  void forceGarbageCollection() {
    try {
      if (js.context['gc'] != null) {
        js.context['gc']();
        _eventController.add(const WebPerformanceEvent(
          type: WebPerformanceEventType.garbageCollectionForced,
        ));
      }
    } catch (e) {
      debugPrint('Error forcing garbage collection: $e');
    }
  }

  /// Get performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return Map.from(_performanceMetrics);
  }

  /// Clear performance data
  void clearPerformanceData() {
    _performanceMetrics.clear();
    _eventController.add(const WebPerformanceEvent(
      type: WebPerformanceEventType.performanceDataCleared,
    ));
  }

  /// Optimize images using web APIs
  Future<Uint8List?> optimizeImageWeb(Uint8List imageBytes, {
    int maxWidth = 1920,
    int maxHeight = 1080,
    double quality = 0.85,
  }) async {
    try {
      final completer = Completer<Uint8List?>();

      // Create canvas for image processing
      final canvas = web_html.CanvasElement();
      final ctx = canvas.getContext('2d') as web_html.CanvasRenderingContext2D;

      // Create image element
      final img = web_html.ImageElement();
      img.src = 'data:image;base64,${base64Encode(imageBytes)}';

      img.onLoad.listen((_) {
        // Calculate new dimensions
        double scale = 1.0;
        if (img.width! > maxWidth || img.height! > maxHeight) {
          final widthScale = maxWidth / img.width!;
          final heightScale = maxHeight / img.height!;
          scale = widthScale < heightScale ? widthScale : heightScale;
        }

        final newWidth = (img.width! * scale).round();
        final newHeight = (img.height! * scale).round();

        // Set canvas size
        canvas.width = newWidth;
        canvas.height = newHeight;

        // Draw and compress image
        ctx.drawImageScaled(img, 0, 0, newWidth, newHeight);

        debugPrint('About to call toBlob with quality: $quality');
        debugPrint('Canvas dimensions: ${canvas.width}x${canvas.height}');
        debugPrint('Image dimensions: ${img.width}x${img.height}');

        try {
          // Use JavaScript interop for canvas.toBlob
          final canvasJS = js.JsObject.fromBrowserObject(canvas);

          canvasJS.callMethod('toBlob', [
            js.allowInterop((js.JsObject? blobJS) {
              debugPrint('JavaScript toBlob callback triggered, blob is: ${blobJS != null ? 'not null' : 'null'}');
              if (blobJS != null) {
                debugPrint('Blob size: ${blobJS['size']} bytes');

                // Convert JS blob to Dart bytes using FileReader
                final reader = web_html.FileReader();
                // Create a proper blob from the JS object
                final blob = html.Blob([], blobJS['type']);
                reader.readAsArrayBuffer(blob);

                reader.onLoadEnd.listen((_) {
                  debugPrint('FileReader onLoadEnd triggered, result type: ${reader.result.runtimeType}');
                  try {
                    final result = reader.result;
                    if (result is Uint8List) {
                      debugPrint('Converting result to Uint8List, length: ${result.length}');
                      completer.complete(result);
                    } else if (result is ByteBuffer) {
                      debugPrint('Converting ByteBuffer to Uint8List');
                      completer.complete(Uint8List.view(result));
                    } else {
                      debugPrint('Unexpected result type: ${result.runtimeType}');
                      completer.complete(null);
                    }
                  } catch (e) {
                    debugPrint('Error processing FileReader result: $e');
                    completer.complete(null);
                  }
                });

                reader.onError.listen((_) {
                  debugPrint('FileReader error occurred');
                  completer.complete(null);
                });
              } else {
                debugPrint('Blob is null, completing with null');
                completer.complete(null);
              }
            }),
            'image/jpeg',
            quality
          ]);
        } catch (e) {
          debugPrint('Error calling toBlob: $e');
          completer.complete(null);
        }
      });

      img.onError.listen((_) {
        completer.complete(null);
      });

      return completer.future;

    } catch (e) {
      debugPrint('Error optimizing image on web: $e');
      return null;
    }
  }

  /// Preload resources
  void preloadResources(List<String> urls) {
    for (final url in urls) {
      final link = web_html.LinkElement()
        ..rel = 'preload'
        ..href = url
        ..as_ = 'image'; // or other resource type

      web_html.document.head!.append(link);

      _eventController.add(WebPerformanceEvent(
        type: WebPerformanceEventType.resourcePreloaded,
        metadata: {'url': url},
      ));
    }
  }

  /// Enable passive event listeners for better scroll performance
  void enablePassiveScroll() {
    try {
      js.context['window'].addEventListener('scroll', js.allowInterop((event) {
        // Handle scroll with passive listener
      }), js.JsObject.jsify({'passive': true}));

      debugPrint('Passive scroll listeners enabled');
    } catch (e) {
      debugPrint('Error enabling passive scroll: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _performanceObserver?.disconnect();
    _resourceObserver?.disconnect();
    _navigationObserver?.disconnect();
    _webWorker?.terminate();
    _eventController.close();
  }
}

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
  double get availableMemory => jsHeapSizeLimit - usedJSHeapSize;

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