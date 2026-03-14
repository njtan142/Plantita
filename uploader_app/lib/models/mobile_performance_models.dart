/// Network type enumeration
enum NetworkType {
  wifi,
  mobile,
  ethernet,
  vpn,
  none,
}

/// Mobile performance event types
enum MobilePerformanceEventType {
  initialized,
  deviceInfoLoaded,
  batteryStateChanged,
  criticalBatteryModeEnabled,
  lowBatteryModeEnabled,
  batterySavingDisabled,
  deviceOptimized,
  networkOptimized,
  touchEventProcessed,
  powerSavingEnabled,
  powerSavingDisabled,
  error,
}

/// Mobile performance event data
class MobilePerformanceEvent {
  final MobilePerformanceEventType type;
  final Map<String, dynamic>? metadata;

  const MobilePerformanceEvent({
    required this.type,
    this.metadata,
  });
}
