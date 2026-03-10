import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uploader_app/services/memory_management_service.dart';

class TestMemoryManagementService extends MemoryManagementService {
  MemoryInfo? mockMemoryInfo;
  bool shouldThrowError = false;

  TestMemoryManagementService({
    super.maxPoolSize,
    super.cleanupInterval,
    super.memoryCheckInterval,
    super.highMemoryThreshold,
    super.criticalMemoryThreshold,
  });

  @override
  Future<MemoryInfo> getMemoryInfo() async {
    if (shouldThrowError) {
      throw Exception('Mock memory check error');
    }
    return mockMemoryInfo ??
        const MemoryInfo(
          currentUsage: 50,
          peakUsage: 60,
          availableMemory: 1000,
          isLowMemory: false,
        );
  }
}

void main() {
  group('MemoryManagementService', () {
    late TestMemoryManagementService service;

    // Custom debug print output collector
    final List<String> debugPrintOutput = [];

    setUp(() {
      // Intercept debugPrint
      debugPrintOutput.clear();
      debugPrint = (String? message, {int? wrapWidth}) {
        if (message != null) {
          debugPrintOutput.add(message);
        }
      };

      // Initialize with short intervals to facilitate testing where necessary,
      // but mostly we will trigger checks manually or wait briefly.
      service = TestMemoryManagementService(
        memoryCheckInterval: const Duration(milliseconds: 50),
        cleanupInterval: const Duration(minutes: 5),
        highMemoryThreshold: 100,
        criticalMemoryThreshold: 150,
      );
    });

    tearDown(() async {
      // Small delay before disposal to avoid 'Cannot add new events after calling close'
      // from pending periodic timer ticks.
      await Future.delayed(const Duration(milliseconds: 50));
      service.dispose();
      debugPrint = debugPrintThrottled; // Reset to default
    });

    test('handles errors during memory check gracefully', () async {
      service.shouldThrowError = true;

      // Wait a short time for the periodic timer to run and _checkMemoryUsage to be called
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert that debugPrint recorded the error
      expect(
        debugPrintOutput.any((msg) => msg.contains('Error checking memory usage: Exception: Mock memory check error')),
        isTrue,
        reason: 'The error from getMemoryInfo() should be caught and logged',
      );
    });

    test('triggers cleanup on high memory', () async {
      service.mockMemoryInfo = const MemoryInfo(
        currentUsage: 120, // Above 100
        peakUsage: 120,
        availableMemory: 880,
        isLowMemory: false,
      );

      final events = <MemoryEvent>[];
      final subscription = service.memoryEventStream.listen(events.add);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(
        debugPrintOutput.any((msg) => msg.contains('High memory usage detected: 120MB')),
        isTrue,
      );

      // Should have triggered cleanup
      expect(
        events.any((e) => e.type == MemoryEventType.cleanupPerformed && e.metadata?['type'] == 'regular'),
        isTrue,
      );

      await subscription.cancel();
    });

    test('triggers emergency cleanup on critical memory', () async {
      service.mockMemoryInfo = const MemoryInfo(
        currentUsage: 160, // Above 150
        peakUsage: 160,
        availableMemory: 840,
        isLowMemory: true, // Also test low memory flag
      );

      final events = <MemoryEvent>[];
      final subscription = service.memoryEventStream.listen(events.add);

      await Future.delayed(const Duration(milliseconds: 100));

      expect(
        debugPrintOutput.any((msg) => msg.contains('Critical memory usage detected: 160MB')),
        isTrue,
      );
      expect(
        debugPrintOutput.any((msg) => msg.contains('Performing emergency memory cleanup')),
        isTrue,
      );

      // Should have triggered emergency cleanup
      expect(
        events.any((e) => e.type == MemoryEventType.cleanupPerformed && e.metadata?['type'] == 'emergency'),
        isTrue,
      );

      await subscription.cancel();
    });

    test('pool object allocation and release works', () {
      final events = <MemoryEvent>[];
      final subscription = service.memoryEventStream.listen(events.add);

      // Acquire
      final obj = service.acquire<String>('strings', () => 'hello');
      expect(obj, 'hello');

      // Release
      service.release<String>('strings', obj);

      final stats = service.getMemoryStats();
      expect(stats.totalAllocations, 1);
      expect(stats.totalDeallocations, 1);

      subscription.cancel();
    });

    test('weak references are tracked and cleared on emergency cleanup', () async {
      // Register
      final obj = Object();
      service.registerWeakReference('test_ref', obj);

      expect(service.getWeakReference<Object>('test_ref'), isNotNull);

      // Trigger emergency cleanup
      service.mockMemoryInfo = const MemoryInfo(
        currentUsage: 160,
        peakUsage: 160,
        availableMemory: 840,
        isLowMemory: true,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // Weak reference should be cleared
      expect(service.getWeakReference<Object>('test_ref'), isNull);

      final stats = service.getMemoryStats();
      expect(stats.weakReferencesCount, 0);
    });
  });
}
