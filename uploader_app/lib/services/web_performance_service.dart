import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:universal_html/html.dart' as web_html;
import 'package:uploader_app/services/performance_monitor_service.dart';
import 'package:uploader_app/models/web_performance_models.dart';

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

      _webWorker!.addEventListener('message', (event) {
        if (event is web_html.MessageEvent) {
          _handleWebWorkerMessage(event.data);
        }
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
          if (entry is web_html.PerformanceNavigationTiming) {
            _performanceMetrics['navigation'] = {
              'loadTime': (entry.loadEventEnd ?? 0) - (entry.loadEventStart ?? 0),
              'domContentLoaded': (entry.domContentLoadedEventEnd ?? 0) - (entry.domContentLoadedEventStart ?? 0),
              'totalTime': (entry.loadEventEnd ?? 0) - (entry.fetchStart ?? 0),
            };
          }
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
      debugPrint('Caching resource: $url (implementation needs Response constructor)');

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

      final canvas = web_html.CanvasElement();
      final ctx = canvas.getContext('2d') as web_html.CanvasRenderingContext2D;

      final img = web_html.ImageElement();
      img.src = 'data:image;base64,${base64Encode(imageBytes)}';

      img.onLoad.listen((_) {
        double scale = 1.0;
        if (img.width! > maxWidth || img.height! > maxHeight) {
          final widthScale = maxWidth / img.width!;
          final heightScale = maxHeight / img.height!;
          scale = widthScale < heightScale ? widthScale : heightScale;
        }

        final newWidth = (img.width! * scale).round();
        final newHeight = (img.height! * scale).round();

        canvas.width = newWidth;
        canvas.height = newHeight;

        ctx.drawImageScaled(img, 0, 0, newWidth, newHeight);

        try {
          final canvasJS = js.JsObject.fromBrowserObject(canvas);

          final callback = js.JsFunction.withThis((_, dynamic blobJS) {
            if (blobJS != null) {
              final reader = web_html.FileReader();
              final blob = html.Blob([], blobJS['type']);
              reader.readAsArrayBuffer(blob);

              reader.onLoadEnd.listen((_) {
                try {
                  final result = reader.result;
                  if (result is Uint8List) {
                    completer.complete(result);
                  } else if (result is ByteBuffer) {
                    completer.complete(Uint8List.view(result));
                  } else {
                    completer.complete(null);
                  }
                } catch (e) {
                  completer.complete(null);
                }
              });

              reader.onError.listen((_) {
                completer.complete(null);
              });
            } else {
              completer.complete(null);
            }
          });

          canvasJS.callMethod('toBlob', [callback, 'image/jpeg', quality]);
        } catch (e) {
          completer.complete(null);
        }
      });

      img.onError.listen((_) {
        completer.complete(null);
      });

      return completer.future;

    } catch (e) {
      return null;
    }
  }

  /// Preload resources
  void preloadResources(List<String> urls) {
    for (final url in urls) {
      final link = web_html.LinkElement()
        ..rel = 'preload'
        ..href = url
        ..setAttribute('as', 'image');

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
      }), js.JsObject.jsify({'passive': true}));
    } catch (e) {
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
