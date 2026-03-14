import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

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
  final T _resource;
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
          _cleanup(_resource);
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

  double get allocationEfficiency => totalAllocations > 0 ? totalDeallocations / totalAllocations : 0;
  double get poolUtilization => totalPoolCapacity > 0 ? totalPooledObjects / totalPoolCapacity : 0;

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
