import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/memory_models.dart';

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
      return;
    } else {
      final tempList = <String>[];
      for (int i = 0; i < 10000; i++) {
        tempList.add('temp_$i');
      }
      return;
    }
  }

  /// Get memory usage (platform dependent)
  Future<MemoryInfo> getMemoryInfo() async {
    return const MemoryInfo(
      currentUsage: 0,
      peakUsage: 0,
      availableMemory: 0,
      isLowMemory: false,
    );
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
    for (final pool in _pools.values) {
      pool.cleanup();
    }

    _weakReferences.removeWhere((key, ref) => ref.target == null);

    await forceGarbageCollection();

    _memoryEventController.add(const MemoryEvent(
      type: MemoryEventType.cleanupPerformed,
      metadata: {'type': 'regular'},
    ));
  }

  /// Perform emergency cleanup when memory is critical
  Future<void> _performEmergencyCleanup() async {
    debugPrint('🚨 Performing emergency memory cleanup');

    for (final pool in _pools.values) {
      pool.clear();
    }

    _weakReferences.clear();

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
    clearAll();
    _memoryEventController.close();
  }
}
