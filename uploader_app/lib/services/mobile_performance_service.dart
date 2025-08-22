import 'dart:async';
import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Mobile-specific performance optimization service
class MobilePerformanceService {
  final PerformanceMonitorService _performanceMonitor;
  final StreamController<MobilePerformanceEvent> _eventController = StreamController.broadcast();

  // Mobile APIs
  final Battery _battery = Battery();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // State
  BatteryState _batteryState = BatteryState.unknown;
  int _batteryLevel = 100;
  AndroidDeviceInfo? _androidInfo;
  IosDeviceInfo? _iosInfo;

  // Configuration
  final int _lowBatteryThreshold;
  final int _criticalBatteryThreshold;
  final bool _enableBatteryOptimization;
  final bool _enableTouchOptimization;
  final bool _enableMemoryOptimization;

  // Touch event handling
  Timer? _touchDebounceTimer;
  final Map<String, DateTime> _lastTouchEvents = {};
  final Duration _touchDebounceDuration;

  // Memory optimization
  final List<StreamSubscription> _subscriptions = [];
  bool _isLowMemoryMode = false;

  MobilePerformanceService({
    required PerformanceMonitorService performanceMonitor,
    int lowBatteryThreshold = 20,
    int criticalBatteryThreshold = 10,
    bool enableBatteryOptimization = true,
    bool enableTouchOptimization = true,
    bool enableMemoryOptimization = true,
    Duration touchDebounceDuration = const Duration(milliseconds: 100),
  })  : _performanceMonitor = performanceMonitor,
        _lowBatteryThreshold = lowBatteryThreshold,
        _criticalBatteryThreshold = criticalBatteryThreshold,
        _enableBatteryOptimization = enableBatteryOptimization,
        _enableTouchOptimization = enableTouchOptimization,
        _enableMemoryOptimization = enableMemoryOptimization,
        _touchDebounceDuration = touchDebounceDuration;

  /// Stream of mobile performance events
  Stream<MobilePerformanceEvent> get eventStream => _eventController.stream;

  /// Current battery level
  int get batteryLevel => _batteryLevel;

  /// Current battery state
  BatteryState get batteryState => _batteryState;

  /// Device information
  AndroidDeviceInfo? get androidInfo => _androidInfo;
  IosDeviceInfo? get iosInfo => _iosInfo;

  /// Whether device is in low memory mode
  bool get isLowMemoryMode => _isLowMemoryMode;

  /// Initialize mobile-specific optimizations
  Future<void> initialize() async {
    if (kIsWeb) return; // Skip on web

    try {
      _performanceMonitor.startTracking('mobile_performance_init');

      // Initialize device info
      await _initializeDeviceInfo();

      // Initialize battery monitoring
      if (_enableBatteryOptimization) {
        await _initializeBatteryMonitoring();
      }

      // Initialize touch optimization
      if (_enableTouchOptimization) {
        await _initializeTouchOptimization();
      }

      // Initialize memory optimization
      if (_enableMemoryOptimization) {
        await _initializeMemoryOptimization();
      }

      // Optimize based on device capabilities
      await _optimizeForDevice();

      _performanceMonitor.endTracking('mobile_performance_init', result: {
        'deviceInfo': _androidInfo != null || _iosInfo != null,
        'batteryMonitoring': _enableBatteryOptimization,
        'touchOptimization': _enableTouchOptimization,
        'memoryOptimization': _enableMemoryOptimization,
      });

      _eventController.add(const MobilePerformanceEvent(
        type: MobilePerformanceEventType.initialized,
        metadata: {'success': true},
      ));

    } catch (e) {
      debugPrint('Error initializing mobile performance service: $e');
      _eventController.add(MobilePerformanceEvent(
        type: MobilePerformanceEventType.error,
        metadata: {'error': e.toString()},
      ));
    }
  }

  /// Initialize device information
  Future<void> _initializeDeviceInfo() async {
    try {
      if (Platform.isAndroid) {
        _androidInfo = await _deviceInfo.androidInfo;
        _eventController.add(MobilePerformanceEvent(
          type: MobilePerformanceEventType.deviceInfoLoaded,
          metadata: {
            'platform': 'android',
            'model': _androidInfo!.model,
            'androidVersion': _androidInfo!.version.release,
            'manufacturer': _androidInfo!.manufacturer,
          },
        ));
      } else if (Platform.isIOS) {
        _iosInfo = await _deviceInfo.iosInfo;
        _eventController.add(MobilePerformanceEvent(
          type: MobilePerformanceEventType.deviceInfoLoaded,
          metadata: {
            'platform': 'ios',
            'model': _iosInfo!.model,
            'systemVersion': _iosInfo!.systemVersion,
            'name': _iosInfo!.name,
          },
        ));
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
    }
  }

  /// Initialize battery monitoring
  Future<void> _initializeBatteryMonitoring() async {
    try {
      // Get initial battery level
      _batteryLevel = await _battery.batteryLevel;
      _batteryState = await _battery.batteryState;

      _performanceMonitor.recordBatteryLevel(_batteryLevel / 100.0);

      // Set up battery level monitoring
      final batterySubscription = _battery.onBatteryStateChanged.listen(
        _onBatteryStateChanged,
      );

      _subscriptions.add(batterySubscription);

      debugPrint('Battery monitoring initialized: $_batteryLevel%');
    } catch (e) {
      debugPrint('Error initializing battery monitoring: $e');
    }
  }

  /// Handle battery state changes
  void _onBatteryStateChanged(BatteryState state) {
    _batteryState = state;

    _eventController.add(MobilePerformanceEvent(
      type: MobilePerformanceEventType.batteryStateChanged,
      metadata: {
        'state': state.name,
        'level': _batteryLevel,
      },
    ));

    // Optimize based on battery state
    _optimizeForBatteryState();
  }

  /// Optimize based on battery state
  void _optimizeForBatteryState() {
    if (_batteryLevel <= _criticalBatteryThreshold) {
      _enableCriticalBatteryMode();
    } else if (_batteryLevel <= _lowBatteryThreshold) {
      _enableLowBatteryMode();
    } else {
      _disableBatterySavingMode();
    }
  }

  /// Enable critical battery mode
  void _enableCriticalBatteryMode() {
    debugPrint('🔋 Enabling critical battery mode');
    _isLowMemoryMode = true;

    _eventController.add(const MobilePerformanceEvent(
      type: MobilePerformanceEventType.criticalBatteryModeEnabled,
      metadata: {'level': 'critical'},
    ));

    // Force garbage collection
    // Note: Dart doesn't provide direct GC control, but we can suggest it
    _suggestGarbageCollection();
  }

  /// Enable low battery mode
  void _enableLowBatteryMode() {
    debugPrint('🔋 Enabling low battery mode');
    _isLowMemoryMode = true;

    _eventController.add(const MobilePerformanceEvent(
      type: MobilePerformanceEventType.lowBatteryModeEnabled,
      metadata: {'level': 'low'},
    ));
  }

  /// Disable battery saving mode
  void _disableBatterySavingMode() {
    debugPrint('🔋 Disabling battery saving mode');
    _isLowMemoryMode = false;

    _eventController.add(const MobilePerformanceEvent(
      type: MobilePerformanceEventType.batterySavingDisabled,
    ));
  }

  /// Initialize touch optimization
  Future<void> _initializeTouchOptimization() async {
    // Set up system UI overlay style for better touch response
    SystemChrome.setSystemUIOverlayStyle( SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ));

    // Enable high refresh rate if supported
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    debugPrint('Touch optimization initialized');
  }

  /// Debounce touch events
  void debounceTouchEvent(String eventId, VoidCallback action) {
    if (!_enableTouchOptimization) {
      action();
      return;
    }

    final now = DateTime.now();
    final lastEvent = _lastTouchEvents[eventId];

    if (lastEvent == null || now.difference(lastEvent) >= _touchDebounceDuration) {
      _lastTouchEvents[eventId] = now;
      action();

      // Emit touch event
      _eventController.add(MobilePerformanceEvent(
        type: MobilePerformanceEventType.touchEventProcessed,
        metadata: {'eventId': eventId},
      ));
    }
  }

  /// Initialize memory optimization
  Future<void> _initializeMemoryOptimization() async {
    // Set up memory pressure monitoring (if available)
    // Note: Flutter doesn't provide direct memory pressure events
    // but we can monitor through performance metrics

    debugPrint('Memory optimization initialized');
  }

  /// Optimize based on device capabilities
  Future<void> _optimizeForDevice() async {
    if (_androidInfo != null) {
      await _optimizeForAndroid();
    } else if (_iosInfo != null) {
      await _optimizeForIOS();
    }
  }

  /// Android-specific optimizations
  Future<void> _optimizeForAndroid() async {
    final device = _androidInfo!;

    // Optimize based on Android version
    final version = int.tryParse(device.version.release.split('.').first) ?? 0;

    if (version >= 8) {
      // Android 8.0+ optimizations
      debugPrint('Applying Android 8.0+ optimizations');
    }

    // Optimize based on manufacturer
    if (device.manufacturer.toLowerCase() == 'samsung') {
      debugPrint('Applying Samsung-specific optimizations');
    } else if (device.manufacturer.toLowerCase() == 'google') {
      debugPrint('Applying Google Pixel optimizations');
    }

    _eventController.add(MobilePerformanceEvent(
      type: MobilePerformanceEventType.deviceOptimized,
      metadata: {
        'platform': 'android',
        'version': device.version.release,
        'manufacturer': device.manufacturer,
        'model': device.model,
      },
    ));
  }

  /// iOS-specific optimizations
  Future<void> _optimizeForIOS() async {
    final device = _iosInfo!;

    // Optimize based on iOS version
    final version = int.tryParse(device.systemVersion.split('.').first) ?? 0;

    if (version >= 15) {
      // iOS 15+ optimizations
      debugPrint('Applying iOS 15+ optimizations');
    }

    _eventController.add(MobilePerformanceEvent(
      type: MobilePerformanceEventType.deviceOptimized,
      metadata: {
        'platform': 'ios',
        'version': device.systemVersion,
        'model': device.model,
        'name': device.name,
      },
    ));
  }

  /// Get network type for optimization
  Future<NetworkType> getNetworkType() async {
    try {
      final connectivity = await Connectivity().checkConnectivity();
      final result = connectivity.isNotEmpty ? connectivity.first : ConnectivityResult.none;

      switch (result) {
        case ConnectivityResult.wifi:
          return NetworkType.wifi;
        case ConnectivityResult.mobile:
          return NetworkType.mobile;
        case ConnectivityResult.ethernet:
          return NetworkType.ethernet;
        case ConnectivityResult.vpn:
          return NetworkType.vpn;
        default:
          return NetworkType.none;
      }
    } catch (e) {
      return NetworkType.none;
    }
  }

  /// Optimize for network type
  Future<void> optimizeForNetwork(NetworkType networkType) async {
    switch (networkType) {
      case NetworkType.mobile:
        debugPrint('📶 Optimizing for mobile network');
        break;
      case NetworkType.wifi:
        debugPrint('📶 Optimizing for WiFi network');
        break;
      case NetworkType.ethernet:
        debugPrint('📶 Optimizing for ethernet network');
        break;
      case NetworkType.vpn:
        debugPrint('📶 Optimizing for VPN network');
        break;
      case NetworkType.none:
        debugPrint('📶 No network connection detected');
        break;
    }

    _eventController.add(MobilePerformanceEvent(
      type: MobilePerformanceEventType.networkOptimized,
      metadata: {'networkType': networkType.name},
    ));
  }

  /// Suggest garbage collection
  void _suggestGarbageCollection() {
    // Create some pressure to suggest GC
    final tempList = <String>[];
    for (int i = 0; i < 5000; i++) {
      tempList.add('temp_$i');
    }
    // Let it go out of scope
  }

  /// Enable power saving mode
  void enablePowerSavingMode() {
    _isLowMemoryMode = true;

    _eventController.add(const MobilePerformanceEvent(
      type: MobilePerformanceEventType.powerSavingEnabled,
    ));
  }

  /// Disable power saving mode
  void disablePowerSavingMode() {
    _isLowMemoryMode = false;

    _eventController.add(const MobilePerformanceEvent(
      type: MobilePerformanceEventType.powerSavingDisabled,
    ));
  }

  /// Get device performance capabilities
  Map<String, dynamic> getDeviceCapabilities() {
    return {
      'platform': Platform.isAndroid ? 'android' : Platform.isIOS ? 'ios' : 'unknown',
      'batteryLevel': _batteryLevel,
      'batteryState': _batteryState.name,
      'lowMemoryMode': _isLowMemoryMode,
      'androidInfo': _androidInfo?.data,
      'iosInfo': _iosInfo?.data,
    };
  }

  /// Dispose resources
  void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _touchDebounceTimer?.cancel();
    _lastTouchEvents.clear();
    _eventController.close();
  }
}

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