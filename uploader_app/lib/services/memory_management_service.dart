import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// Memory management service for resource cleanup and pooling
class MemoryManagementService {
  // Memory pools
  final Map<String, ObjectPool> _pools = {};
  final Map<String, WeakReference> _weakReferences = {};

  // Memory monitoring
  final StreamController<MemoryEvent> _memoryEventController = StreamController.broadcast();
  Timer? _memoryCheckTimer;
  Timer? _cleanupTimer;

  // Configuration
  final int _maxPoolSize;
  final Duration _cleanupInterval;
  final Duration _memoryCheckInterval;
  final int _highMemoryThreshold; // MB
  final int _criticalMemoryThreshold; // MB

  // Statistics
  int _totalAllocations = 0;
  int _totalDeallocations = 0;
  int _forcedGCs = 0;

  MemoryManagementService({
    int maxPoolSize = 100,
    Duration cleanupInterval = const Duration(minutes: 5),
    Duration memoryCheckInterval = const Duration(seconds: 30),
    int highMemoryThreshold = 100, // MB
    int criticalMemoryThreshold = 150, // MB
  })  : _maxPoolSize = maxPoolSize,
        _cleanupInterval = cleanupInterval,
        _memoryCheckInterval = memoryCheckInterval,
        _highMemoryThreshold = highMemoryThreshold,
        _criticalMemoryThreshold = criticalMemoryThreshold {
    _initializeService();
  }

  /// Stream of memory events
  Stream<MemoryEvent> get memoryEventStream => _memoryEventController.stream;

  /// Initialize the service
  void _initializeService() {
    // Start periodic cleanup
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) => _performCleanup());

    // Start memory monitoring
    _memoryCheckTimer = Timer.periodic(_memoryCheckInterval, (_) => _checkMemoryUsage());
  }

  /// Get or create object pool
  ObjectPool<T> getPool<T>(String poolName, T Function() factory) {
    if (!_pools.containsKey(poolName)) {
      _pools[poolName] = ObjectPool<T>(poolName, factory, _maxPoolSize);
    }
    return _pools[poolName] as ObjectPool<T>;
  }

  /// Acquire object from pool
  T acquire<T>(String poolName, T Function() factory) {
    final pool = getPool<T>(poolName, factory);
    final object = pool.acquire();
    _totalAllocations++;

    _memoryEventController.add(MemoryEvent(
      type: MemoryEventType.objectAcquired,
      poolName: poolName,
      objectType: T.toString(),
      metadata: {'totalAllocations': _totalAllocations},
    ));

    return object;
  }

  /// Release object back to pool
  void release<T>(String poolName, T object) {
    final pool = _pools[poolName];
    if (pool != null) {
      pool.release(object);
      _totalDeallocations++;

      _memoryEventController.add(MemoryEvent(
        type: MemoryEventType.objectReleased,
        poolName: poolName,
        objectType: T.toString(),
        metadata: {'totalDeallocations': _totalDeallocations},
      ));
    }
  }

  /// Register weak reference for tracking
  void registerWeakReference(String key, Object object) {
    _weakReferences[key] = WeakReference(object);
  }

  /// Remove weak reference
  void unregisterWeakReference(String key) {
    _weakReferences.remove(key);
  }

  /// Get object from weak reference if still alive
  T? getWeakReference<T>(String key) {
    final ref = _weakReferences[key];
    return ref?.target as T?;
  }

  /// Create resource wrapper with automatic cleanup
  ResourceWrapper<T> wrapResource<T>(
    T resource,
    String resourceType, {
    void Function(T)? cleanup,
    Duration? maxLifetime,
  }) {
    return ResourceWrapper<T>(
      resource,
      resourceType,
      cleanup: cleanup,
      maxLifetime: maxLifetime,
      onDisposed: () => _onResourceDisposed(resourceType),
    );
  }

  /// Force garbage collection (platform dependent)
  Future<void> forceGarbageCollection() async {
    _forcedGCs++;

    _memoryEventController.add( MemoryEvent(
      type: MemoryEventType.gcForced,
      metadata: {'forcedGCs': _forcedGCs},
    ));

    if (kIsWeb) {
      // Web doesn't allow forced GC
      return;
    } else {
      // For mobile/desktop, we can't force GC directly
      // but we can suggest it by creating pressure
      final tempList = <String>[];
      for (int i = 0; i < 10000; i++) {
        tempList.add('temp_$i');
      }
      // Let it go out of scope
      return;
    }
  }

  /// Get memory usage (platform dependent)
  Future<MemoryInfo> getMemoryInfo() async {
    if (kIsWeb) {
      // Web memory info is limited
      return const MemoryInfo(
        currentUsage: 0,
        peakUsage: 0,
        availableMemory: 0,
        isLowMemory: false,
      );
    } else {
      // For mobile/desktop, try to get memory info
      // This is platform dependent and may not be accurate
      return const MemoryInfo(
        currentUsage: 0,
        peakUsage: 0,
        availableMemory: 0,
        isLowMemory: false,
      );
    }
  }

  /// Check memory usage and trigger cleanup if needed
  Future<void> _checkMemoryUsage() async {
    try {
      final memoryInfo = await getMemoryInfo();

      if (memoryInfo.isLowMemory || memoryInfo.currentUsage > _criticalMemoryThreshold) {
        debugPrint('🚨 Critical memory usage detected: ${memoryInfo.currentUsage}MB');
        await _performEmergencyCleanup();
      } else if (memoryInfo.currentUsage > _highMemoryThreshold) {
        debugPrint('⚠️ High memory usage detected: ${memoryInfo.currentUsage}MB');
        await _performCleanup();
      }

      _memoryEventController.add(MemoryEvent(
        type: MemoryEventType.memoryChecked,
        metadata: {
          'currentUsage': memoryInfo.currentUsage,
          'peakUsage': memoryInfo.peakUsage,
          'isLowMemory': memoryInfo.isLowMemory,
        },
      ));
    } catch (e) {
      debugPrint('Error checking memory usage: $e');
    }
  }

  /// Perform regular cleanup
  Future<void> _performCleanup() async {
    // Clean expired resources
    for (final pool in _pools.values) {
      pool.cleanup();
    }

    // Clean dead weak references
    _weakReferences.removeWhere((key, ref) => ref.target == null);

    // Suggest garbage collection
    await forceGarbageCollection();

    _memoryEventController.add(const MemoryEvent(
      type: MemoryEventType.cleanupPerformed,
      metadata: {'type': 'regular'},
    ));
  }

  /// Perform emergency cleanup when memory is critical
  Future<void> _performEmergencyCleanup() async {
    debugPrint('🚨 Performing emergency memory cleanup');

    // Clear all pools
    for (final pool in _pools.values) {
      pool.clear();
    }

    // Clear weak references
    _weakReferences.clear();

    // Force garbage collection
    await forceGarbageCollection();

    _memoryEventController.add(const MemoryEvent(
      type: MemoryEventType.cleanupPerformed,
      metadata: {'type': 'emergency'},
    ));
  }

  /// Handle resource disposal
  void _onResourceDisposed(String resourceType) {
    _memoryEventController.add(MemoryEvent(
      type: MemoryEventType.resourceDisposed,
      metadata: {'resourceType': resourceType},
    ));
  }

  /// Get memory statistics
  MemoryStats getMemoryStats() {
    int totalPooledObjects = 0;
    int totalPoolSize = 0;

    for (final pool in _pools.values) {
      totalPooledObjects += pool.size;
      totalPoolSize += pool.maxSize;
    }

    return MemoryStats(
      totalAllocations: _totalAllocations,
      totalDeallocations: _totalDeallocations,
      forcedGCs: _forcedGCs,
      activePools: _pools.length,
      totalPooledObjects: totalPooledObjects,
      totalPoolCapacity: totalPoolSize,
      weakReferencesCount: _weakReferences.length,
    );
  }

  /// Clear all pools and resources
  void clearAll() {
    for (final pool in _pools.values) {
      pool.clear();
    }
    _pools.clear();
    _weakReferences.clear();

    _memoryEventController.add(const MemoryEvent(
      type: MemoryEventType.allCleared,
    ));
  }

  /// Dispose resources
  void dispose() {
    _cleanupTimer?.cancel();
    _memoryCheckTimer?.cancel();
    _memoryEventController.close();
    clearAll();
  }
}

/// Object pool for resource management
class ObjectPool<T> {
  final String name;
  final T Function() _factory;
  final int maxSize;
  final Queue<T> _available = Queue<T>();
  final Set<T> _inUse = {};

  ObjectPool(this.name, this._factory, this.maxSize);

  int get size => _available.length + _inUse.length;
  int get availableCount => _available.length;
  int get inUseCount => _inUse.length;

  T acquire() {
    if (_available.isNotEmpty) {
      final object = _available.removeFirst();
      _inUse.add(object);
      return object;
    } else if (size < maxSize) {
      final object = _factory();
      _inUse.add(object);
      return object;
    } else {
      throw MemoryManagementException('Object pool "$name" is at maximum capacity ($maxSize)');
    }
  }

  void release(T object) {
    if (_inUse.remove(object)) {
      if (_available.length < maxSize) {
        _available.add(object);
      }
    }
  }

  void cleanup() {
    // Remove excess objects
    while (_available.length > maxSize ~/ 2) {
      _available.removeFirst();
    }
  }

  void clear() {
    _available.clear();
    _inUse.clear();
  }
}

/// Resource wrapper with automatic cleanup
class ResourceWrapper<T> {
  T _resource;
  final String _resourceType;
  final void Function(T)? _cleanup;
  final DateTime _createdAt;
  final Duration? _maxLifetime;
  Timer? _lifetimeTimer;
  bool _disposed = false;

  final void Function() _onDisposed;

  ResourceWrapper(
    this._resource,
    this._resourceType,
    {
      void Function(T)? cleanup,
      Duration? maxLifetime,
      required void Function() onDisposed,
    }
  ) : _cleanup = cleanup,
      _createdAt = DateTime.now(),
      _maxLifetime = maxLifetime,
      _onDisposed = onDisposed {
    if (_maxLifetime != null) {
      _lifetimeTimer = Timer(_maxLifetime, dispose);
    }
  }

  T get resource {
    if (_disposed) {
      throw MemoryManagementException('Resource has been disposed');
    }
    return _resource;
  }

  bool get isDisposed => _disposed;

  Duration get age => DateTime.now().difference(_createdAt);

  void dispose() {
    if (!_disposed) {
      _disposed = true;
      _lifetimeTimer?.cancel();

      if (_cleanup != null) {
        try {
          _cleanup!(_resource);
        } catch (e) {
          debugPrint('Error cleaning up resource $_resourceType: $e');
        }
      }

      _onDisposed();
    }
  }
}

/// Memory information
class MemoryInfo {
  final int currentUsage; // MB
  final int peakUsage; // MB
  final int availableMemory; // MB
  final bool isLowMemory;

  const MemoryInfo({
    required this.currentUsage,
    required this.peakUsage,
    required this.availableMemory,
    required this.isLowMemory,
  });
}

/// Memory event types
enum MemoryEventType {
  objectAcquired,
  objectReleased,
  resourceDisposed,
  memoryChecked,
  cleanupPerformed,
  gcForced,
  allCleared,
}

/// Memory event data
class MemoryEvent {
  final MemoryEventType type;
  final String? poolName;
  final String? objectType;
  final Map<String, dynamic>? metadata;

  const MemoryEvent({
    required this.type,
    this.poolName,
    this.objectType,
    this.metadata,
  });
}

/// Memory statistics
class MemoryStats {
  final int totalAllocations;
  final int totalDeallocations;
  final int forcedGCs;
  final int activePools;
  final int totalPooledObjects;
  final int totalPoolCapacity;
  final int weakReferencesCount;

  const MemoryStats({
    required this.totalAllocations,
    required this.totalDeallocations,
    required this.forcedGCs,
    required this.activePools,
    required this.totalPooledObjects,
    required this.totalPoolCapacity,
    required this.weakReferencesCount,
  });

  double get allocationEfficiency => totalDeallocations / totalAllocations;
  double get poolUtilization => totalPooledObjects / totalPoolCapacity;

  @override
  String toString() {
    return 'MemoryStats(allocations: $totalAllocations, deallocations: $totalDeallocations, '
        'pools: $activePools, pooledObjects: $totalPooledObjects, '
        'weakRefs: $weakReferencesCount, efficiency: ${(allocationEfficiency * 100).toStringAsFixed(1)}%)';
  }
}

/// Custom exception for memory management errors
class MemoryManagementException implements Exception {
  final String message;
  const MemoryManagementException(this.message);

  @override
  String toString() => message;
}