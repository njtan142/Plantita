import 'dart:async';
import 'dart:collection';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/api_response_model.dart';

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
