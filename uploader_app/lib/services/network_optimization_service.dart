import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uploader_app/models/api_response_model.dart';
import 'http_client_service.dart';

/// Network optimization service with connection pooling and intelligent caching
class NetworkOptimizationService {
  final HttpClientService _httpClient;
  final SharedPreferences _prefs;
  final Connectivity _connectivity;

  // Connection pooling
  final Map<String, ConnectionPool> _connectionPools = {};
  final int _maxConnectionsPerHost;
  final Duration _connectionTimeout;

  // Caching
  final Map<String, CachedResponse> _memoryCache = {};
  final Map<String, Completer<http.Response>> _pendingRequests = {};
  final int _maxCacheSize;
  final Duration _defaultCacheDuration;
  final Map<String, Duration> _cacheDurations = {};

  // Request deduplication
  final Map<String, DateTime> _requestTimestamps = {};
  final Duration _deduplicationWindow;

  // Network monitoring
  final StreamController<NetworkEvent> _networkEventController = StreamController.broadcast();
  ConnectivityResult _currentConnectivity = ConnectivityResult.none;
  Timer? _connectivityCheckTimer;

  NetworkOptimizationService({
    required HttpClientService httpClient,
    required SharedPreferences prefs,
    Connectivity? connectivity,
    int maxConnectionsPerHost = 6,
    Duration connectionTimeout = const Duration(seconds: 30),
    int maxCacheSize = 50,
    Duration defaultCacheDuration = const Duration(minutes: 5),
    Duration deduplicationWindow = const Duration(milliseconds: 500),
  })  : _httpClient = httpClient,
        _prefs = prefs,
        _connectivity = connectivity ?? Connectivity(),
        _maxConnectionsPerHost = maxConnectionsPerHost,
        _connectionTimeout = connectionTimeout,
        _maxCacheSize = maxCacheSize,
        _defaultCacheDuration = defaultCacheDuration,
        _deduplicationWindow = deduplicationWindow {
    _initializeService();
  }

  /// Stream of network events
  Stream<NetworkEvent> get networkEventStream => _networkEventController.stream;

  /// Current connectivity status
  ConnectivityResult get currentConnectivity => _currentConnectivity;

  /// Initialize the service
  void _initializeService() {
    // Set up connectivity monitoring
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged as void Function(List<ConnectivityResult> event)?);

    // Load cache durations for different endpoints
    _setupCacheDurations();

    // Start periodic connectivity checks
    _connectivityCheckTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _performConnectivityCheck();
    });
  }

  /// Set up cache durations for different endpoint types
  void _setupCacheDurations() {
    // Static data - longer cache
    _cacheDurations['/api/users'] = const Duration(hours: 1);
    _cacheDurations['/api/config'] = const Duration(hours: 2);

    // Dynamic data - shorter cache
    _cacheDurations['/api/uploads'] = const Duration(minutes: 5);
    _cacheDurations['/api/notifications'] = const Duration(minutes: 1);

    // Real-time data - no cache
    _cacheDurations['/api/realtime'] = Duration.zero;
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(ConnectivityResult result) {
    final previousConnectivity = _currentConnectivity;
    _currentConnectivity = result;

    // Emit network event
    _networkEventController.add(NetworkEvent(
      type: NetworkEventType.connectivityChanged,
      connectivity: result,
      metadata: {
        'previous': previousConnectivity.name,
        'current': result.name,
      },
    ));

    // Clear pending requests on connectivity loss
    if (result == ConnectivityResult.none) {
      _pendingRequests.clear();
    }

    debugPrint('🌐 Network connectivity changed: ${previousConnectivity.name} -> ${result.name}');
  }

  /// Perform connectivity check
  Future<void> _performConnectivityCheck() async {
    try {
      final result = await _connectivity.checkConnectivity();
      if (result != _currentConnectivity) {
        _onConnectivityChanged(result as ConnectivityResult);
      }
    } catch (e) {
      debugPrint('Error checking connectivity: $e');
    }
  }

  /// Optimized GET request with caching and connection pooling
  Future<OptimizedResponse> get(
    String url, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParams,
    bool useCache = true,
    bool forceRefresh = false,
    Duration? customCacheDuration,
  }) async {
    final startTime = DateTime.now();
    final cacheKey = _generateCacheKey('GET', url, queryParams);

    // Check for duplicate requests
    if (_isDuplicateRequest(cacheKey)) {
      return await _waitForPendingRequest(cacheKey);
    }

    // Check cache first
    if (useCache && !forceRefresh) {
      final cached = await _getCachedResponse(cacheKey);
      if (cached != null && !cached.isExpired) {
        _networkEventController.add(NetworkEvent(
          type: NetworkEventType.cacheHit,
          url: url,
          duration: DateTime.now().difference(startTime),
          metadata: {'cacheKey': cacheKey},
        ));
        return OptimizedResponse.fromCached(cached.response, true, cached.cachedAt);
      }
    }

    // Create pending request
    final completer = Completer<OptimizedResponse>();
    _pendingRequests[cacheKey] = completer as Completer<http.Response>;

    try {
      // Get connection from pool
      final connection = await _getConnection(url);

      // Make request
      final response = await _httpClient.get(
        url,
        headers: headers,
        queryParams: queryParams,
      );

      if (response.success && response.data != null) {
        // Cache successful response
        if (useCache) {
          await _cacheResponse(cacheKey, response.data, customCacheDuration);
        }

        final optimizedResponse = OptimizedResponse.fromApiResponse(
          response,
          false,
          DateTime.now().difference(startTime),
        );

        completer.complete(optimizedResponse);

        _networkEventController.add(NetworkEvent(
          type: NetworkEventType.requestCompleted,
          url: url,
          duration: optimizedResponse.responseTime,
          metadata: {
            'statusCode': response.statusCode,
            'cached': false,
          },
        ));

        return optimizedResponse;
      } else {
        throw NetworkOptimizationException('Request failed: ${response.message}');
      }
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _pendingRequests.remove(cacheKey);
      _releaseConnection(url);
    }
  }

  /// Optimized POST request
  Future<OptimizedResponse> post(
    String url, {
    dynamic body,
    Map<String, String>? headers,
    bool invalidateCache = true,
  }) async {
    final startTime = DateTime.now();

    try {
      final response = await _httpClient.post(
        url,
        body: body,
        headers: headers,
      );

      if (response.success) {
        // Invalidate related cache entries
        if (invalidateCache) {
          await _invalidateCacheForUrl(url);
        }

        return OptimizedResponse.fromApiResponse(
          response,
          false,
          DateTime.now().difference(startTime),
        );
      } else {
        throw NetworkOptimizationException('POST request failed: ${response.message}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Upload file with progress tracking and connection pooling
  Future<OptimizedResponse> uploadFile(
    String url,
    String fieldName,
    List<int> fileBytes,
    String fileName,
    String mimeType, {
    Map<String, String>? fields,
    Map<String, String>? headers,
    Function(double)? onProgress,
  }) async {
    final startTime = DateTime.now();

    try {
      final response = await _httpClient.uploadFile(
        url,
        fieldName,
        fileBytes,
        fileName,
        mimeType,
        fields: fields,
        headers: headers,
        onProgress: onProgress,
      );

      return OptimizedResponse.fromApiResponse(
        response,
        false,
        DateTime.now().difference(startTime),
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Get connection from pool
  Future<ConnectionPool> _getConnection(String url) async {
    final host = _extractHost(url);
    final pool = _connectionPools.putIfAbsent(
      host,
      () => ConnectionPool(host, _maxConnectionsPerHost),
    );

    return await pool.getConnection(_connectionTimeout);
  }

  /// Release connection back to pool
  void _releaseConnection(String url) {
    final host = _extractHost(url);
    final pool = _connectionPools[host];
    pool?.releaseConnection();
  }

  /// Check if request is duplicate
  bool _isDuplicateRequest(String cacheKey) {
    final lastRequest = _requestTimestamps[cacheKey];
    if (lastRequest == null) return false;

    final now = DateTime.now();
    final timeDiff = now.difference(lastRequest);
    return timeDiff < _deduplicationWindow;
  }

  /// Wait for pending request to complete
  Future<OptimizedResponse> _waitForPendingRequest(String cacheKey) {
    final completer = _pendingRequests[cacheKey];
    if (completer != null) {
      return completer.future.then((response) => OptimizedResponse.fromApiResponse(
        ApiResponse.success(response, message: 'Request completed'),
        false,
        Duration.zero,
      ));
    }
    throw NetworkOptimizationException('No pending request found');
  }

  /// Get cached response
  Future<CachedResponse?> _getCachedResponse(String cacheKey) async {
    // Check memory cache first
    if (_memoryCache.containsKey(cacheKey)) {
      final cached = _memoryCache[cacheKey]!;
      if (!cached.isExpired) {
        return cached;
      } else {
        _memoryCache.remove(cacheKey);
      }
    }

    // Check persistent cache
    try {
      final cacheJson = _prefs.getString('network_cache_$cacheKey');
      if (cacheJson != null) {
        final cached = CachedResponse.fromJson(jsonDecode(cacheJson));
        if (!cached.isExpired) {
          // Restore to memory cache
          _memoryCache[cacheKey] = cached;
          return cached;
        } else {
          // Remove expired cache
          await _prefs.remove('network_cache_$cacheKey');
        }
      }
    } catch (e) {
      debugPrint('Error reading cache: $e');
    }

    return null;
  }

  /// Cache response
  Future<void> _cacheResponse(
    String cacheKey,
    dynamic response,
    Duration? customDuration,
  ) async {
    final cacheDuration = customDuration ?? _defaultCacheDuration;
    final cachedResponse = CachedResponse(
      response: response,
      cachedAt: DateTime.now(),
      expiresAt: DateTime.now().add(cacheDuration),
    );

    // Add to memory cache
    if (_memoryCache.length >= _maxCacheSize) {
      // Remove oldest entry
      final oldestKey = _memoryCache.keys.first;
      _memoryCache.remove(oldestKey);
    }
    _memoryCache[cacheKey] = cachedResponse;

    // Add to persistent cache
    try {
      await _prefs.setString(
        'network_cache_$cacheKey',
        jsonEncode(cachedResponse.toJson()),
      );
    } catch (e) {
      debugPrint('Error caching response: $e');
    }
  }

  /// Invalidate cache for URL
  Future<void> _invalidateCacheForUrl(String url) async {
    final pattern = url.replaceAll(RegExp(r'[.*+?^${}()|[\]\\]'), r'\$&');

    // Remove from memory cache
    _memoryCache.removeWhere((key, _) => key.contains(pattern));

    // Remove from persistent cache
    final cacheKeys = _prefs.getKeys().where((key) => key.startsWith('network_cache_'));
    for (final key in cacheKeys) {
      if (key.contains(pattern)) {
        await _prefs.remove(key);
      }
    }
  }

  /// Clear all caches
  Future<void> clearCache() async {
    _memoryCache.clear();

    final cacheKeys = _prefs.getKeys().where((key) => key.startsWith('network_cache_'));
    for (final key in cacheKeys) {
      await _prefs.remove(key);
    }

    _networkEventController.add(const NetworkEvent(
      type: NetworkEventType.cacheCleared,
      metadata: {'cacheType': 'all'},
    ));
  }

  /// Generate cache key for request
  String _generateCacheKey(String method, String url, Map<String, dynamic>? params) {
    final keyData = {
      'method': method,
      'url': url,
      'params': params,
    };
    return base64Encode(utf8.encode(jsonEncode(keyData)));
  }

  /// Extract host from URL
  String _extractHost(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host;
    } catch (e) {
      return url;
    }
  }

  /// Get network statistics
  NetworkStats getNetworkStats() {
    return NetworkStats(
      activeConnections: _connectionPools.values.map((pool) => pool.activeConnections).fold(0, (a, b) => a + b),
      pendingRequests: _pendingRequests.length,
      memoryCacheSize: _memoryCache.length,
      persistentCacheSize: _prefs.getKeys().where((key) => key.startsWith('network_cache_')).length,
      connectivityStatus: _currentConnectivity,
    );
  }

  /// Dispose resources
  void dispose() {
    _connectivityCheckTimer?.cancel();
    _networkEventController.close();
    _connectionPools.clear();
    _memoryCache.clear();
    _pendingRequests.clear();
    _requestTimestamps.clear();
  }
}

/// Connection pool for managing HTTP connections
class ConnectionPool {
  final String host;
  final int maxConnections;
  int activeConnections = 0;
  final Queue<Completer<void>> _waitingConnections = Queue();

  ConnectionPool(this.host, this.maxConnections);

  Future<ConnectionPool> getConnection(Duration timeout) async {
    if (activeConnections < maxConnections) {
      activeConnections++;
      return this;
    }

    // Wait for available connection
    final completer = Completer<void>();
    _waitingConnections.add(completer);

    try {
      await completer.future.timeout(timeout);
      activeConnections++;
      return this;
    } catch (e) {
      _waitingConnections.remove(completer);
      throw NetworkOptimizationException('Connection timeout');
    }
  }

  void releaseConnection() {
    activeConnections = activeConnections.clamp(0, maxConnections);

    if (_waitingConnections.isNotEmpty) {
      final waiting = _waitingConnections.removeFirst();
      waiting.complete();
    }
  }
}

/// Cached response wrapper
class CachedResponse {
  final dynamic response;
  final DateTime cachedAt;
  final DateTime expiresAt;

  const CachedResponse({
    required this.response,
    required this.cachedAt,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Duration get remainingTime => expiresAt.difference(DateTime.now());

  factory CachedResponse.fromJson(Map<String, dynamic> json) {
    return CachedResponse(
      response: json['response'],
      cachedAt: DateTime.parse(json['cachedAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response': response,
      'cachedAt': cachedAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
    };
  }
}

/// Optimized response with metadata
class OptimizedResponse {
  final dynamic data;
  final bool fromCache;
  final Duration responseTime;
  final DateTime? cachedAt;
  final int? statusCode;
  final String? error;

  const OptimizedResponse({
    required this.data,
    required this.fromCache,
    required this.responseTime,
    this.cachedAt,
    this.statusCode,
    this.error,
  });

  factory OptimizedResponse.fromApiResponse(ApiResponse response, bool fromCache, Duration responseTime) {
    return OptimizedResponse(
      data: response.data,
      fromCache: fromCache,
      responseTime: responseTime,
      statusCode: response.statusCode,
      error: response.message,
    );
  }

  factory OptimizedResponse.fromCached(dynamic data, bool fromCache, DateTime cachedAt) {
    return OptimizedResponse(
      data: data,
      fromCache: fromCache,
      responseTime: Duration.zero,
      cachedAt: cachedAt,
    );
  }

  bool get isSuccess => error == null;
}

/// Network event types
enum NetworkEventType {
  connectivityChanged,
  requestCompleted,
  cacheHit,
  cacheMiss,
  cacheCleared,
  error,
}

/// Network event data
class NetworkEvent {
  final NetworkEventType type;
  final String? url;
  final Duration? duration;
  final ConnectivityResult? connectivity;
  final Map<String, dynamic>? metadata;

  const NetworkEvent({
    required this.type,
    this.url,
    this.duration,
    this.connectivity,
    this.metadata,
  });
}

/// Network statistics
class NetworkStats {
  final int activeConnections;
  final int pendingRequests;
  final int memoryCacheSize;
  final int persistentCacheSize;
  final ConnectivityResult connectivityStatus;

  const NetworkStats({
    required this.activeConnections,
    required this.pendingRequests,
    required this.memoryCacheSize,
    required this.persistentCacheSize,
    required this.connectivityStatus,
  });

  @override
  String toString() {
    return 'NetworkStats(connections: $activeConnections, pending: $pendingRequests, '
        'memoryCache: $memoryCacheSize, persistentCache: $persistentCacheSize, '
        'connectivity: ${connectivityStatus.name})';
  }
}

/// Custom exception for network optimization errors
class NetworkOptimizationException implements Exception {
  final String message;
  const NetworkOptimizationException(this.message);

  @override
  String toString() => message;
}