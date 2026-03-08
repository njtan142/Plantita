import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'package:flutter/foundation.dart';
import '../config/environment_config.dart';

/// PWA Service for managing Progressive Web App functionality
class PWAService {
  static final PWAService _instance = PWAService._internal();
  factory PWAService() => _instance;
  PWAService._internal();

  // Service Worker state
  bool _serviceWorkerRegistered = false;
  bool _isOnline = true;
  final StreamController<bool> _onlineStatusController = StreamController<bool>.broadcast();
  final StreamController<String> _messageController = StreamController<String>.broadcast();

  // Background sync queue
  final List<BackgroundSyncTask> _syncQueue = [];
  final StreamController<BackgroundSyncTask> _syncController = StreamController<BackgroundSyncTask>.broadcast();

  // Push notifications
  final StreamController<PushNotification> _notificationController = StreamController<PushNotification>.broadcast();

  // Getters
  bool get isServiceWorkerRegistered => _serviceWorkerRegistered;
  bool get isOnline => _isOnline;
  bool get isPWAEnabled => EnvironmentConfig.enablePWA;
  bool get isServiceWorkerEnabled => EnvironmentConfig.enableServiceWorker;
  bool get isBackgroundSyncEnabled => EnvironmentConfig.enableBackgroundSync;
  bool get isPushNotificationsEnabled => EnvironmentConfig.enablePushNotifications;

  // Streams
  Stream<bool> get onlineStatusStream => _onlineStatusController.stream;
  Stream<String> get messageStream => _messageController.stream;
  Stream<BackgroundSyncTask> get syncStream => _syncController.stream;
  Stream<PushNotification> get notificationStream => _notificationController.stream;

  /// Initialize PWA functionality
  Future<void> initialize() async {
    if (!kIsWeb || !isPWAEnabled) {
      debugPrint('PWA: Disabled or not running on web platform');
      return;
    }

    try {
      await _registerServiceWorker();
      await _setupNetworkMonitoring();
      await _setupPushNotifications();
      await _setupBackgroundSync();

      debugPrint('PWA: Initialized successfully');
      _messageController.add('PWA initialized successfully');
    } catch (e) {
      debugPrint('PWA: Initialization failed: $e');
      _messageController.add('PWA initialization failed: $e');
    }
  }

  /// Register the service worker
  Future<void> _registerServiceWorker() async {
    if (!isServiceWorkerEnabled) return;

    try {
      if (html.window.navigator.serviceWorker != null) {
        final registration = await html.window.navigator.serviceWorker!
            .register('/flutter_service_worker.js');

        _serviceWorkerRegistered = true;
        debugPrint('PWA: Service worker registered successfully');

        // Listen for service worker messages
        html.MessageChannel channel = html.MessageChannel();
        registration.active?.postMessage({'type': 'init'}, [channel.port2]);

        channel.port1.onMessage.listen((event) {
          final data = event.data;
          if (data is Map) {
            _handleServiceWorkerMessage(data);
          }
        });
      }
    } catch (e) {
      debugPrint('PWA: Service worker registration failed: $e');
    }
  }

  /// Setup network monitoring
  Future<void> _setupNetworkMonitoring() async {
    if (html.window.navigator.onLine != null) {
      _isOnline = html.window.navigator.onLine!;
      _onlineStatusController.add(_isOnline);
    }

    // Listen for online/offline events
    html.window.addEventListener('online', (event) {
      _isOnline = true;
      _onlineStatusController.add(true);
      debugPrint('PWA: Connection restored');
      _processSyncQueue(); // Process pending sync tasks
    });

    html.window.addEventListener('offline', (event) {
      _isOnline = false;
      _onlineStatusController.add(false);
      debugPrint('PWA: Connection lost');
    });
  }

  /// Setup push notifications
  Future<void> _setupPushNotifications() async {
    if (!isPushNotificationsEnabled) return;

    try {
      final permission = await _requestNotificationPermission();
      if (permission == 'granted') {
        debugPrint('PWA: Push notifications enabled');

        // Listen for push messages
        html.window.navigator.serviceWorker?.addEventListener('message', (event) {
          final data = event as html.MessageEvent;
          if (data.data is Map && data.data['type'] == 'push') {
            final notification = PushNotification.fromJson(data.data['payload']);
            _notificationController.add(notification);
          }
        });
      }
    } catch (e) {
      debugPrint('PWA: Push notifications setup failed: $e');
    }
  }

  /// Setup background sync
  Future<void> _setupBackgroundSync() async {
    if (!isBackgroundSyncEnabled) return;

    try {
      // Check if service worker and background sync are supported
      if (html.window.navigator.serviceWorker != null) {
        // Try to register for background sync by checking if the API is available
        final registration = await html.window.navigator.serviceWorker!.ready;
        // Background sync is supported if we can access the sync property without error
        if (registration.sync != null) {
          debugPrint('PWA: Background sync available');
        }
      }
    } catch (e) {
      debugPrint('PWA: Background sync setup failed: $e');
    }
  }

  /// Request notification permission
  Future<String> _requestNotificationPermission() async {
    if (html.Notification.supported) {
      final permission = await html.Notification.requestPermission();
      return permission.toString();
    }
    return 'denied';
  }

  /// Handle service worker messages
  void _handleServiceWorkerMessage(Map<dynamic, dynamic> data) {
    final type = data['type'];
    switch (type) {
      case 'sync-complete':
        debugPrint('PWA: Background sync completed');
        break;
      case 'cache-updated':
        debugPrint('PWA: Cache updated');
        break;
      case 'offline-ready':
        debugPrint('PWA: App ready for offline use');
        break;
      default:
        debugPrint('PWA: Unknown message type: $type');
    }
  }

  /// Show install prompt
  Future<void> showInstallPrompt() async {
    try {
      final deferredPrompt = html.window.document.querySelector('#deferred-install-prompt');
      if (deferredPrompt != null) {
        (deferredPrompt as html.EventTarget).dispatchEvent(html.Event('click'));
      }
    } catch (e) {
      debugPrint('PWA: Install prompt failed: $e');
    }
  }

  /// Add task to background sync queue
  Future<void> addToSyncQueue(BackgroundSyncTask task) async {
    _syncQueue.add(task);
    _syncController.add(task);

    if (_isOnline) {
      await _processSyncQueue();
    } else {
      // Store for later sync
      await _storeSyncTask(task);
    }
  }

  /// Process sync queue
  Future<void> _processSyncQueue() async {
    if (_syncQueue.isEmpty) return;

    for (final task in List.from(_syncQueue)) {
      try {
        await _executeSyncTask(task);
        _syncQueue.remove(task);
        await _removeStoredSyncTask(task.id);
        debugPrint('PWA: Sync task completed: ${task.id}');
      } catch (e) {
        debugPrint('PWA: Sync task failed: ${task.id}, error: $e');
        // Keep failed tasks for retry
      }
    }
  }

  /// Execute sync task
  Future<void> _executeSyncTask(BackgroundSyncTask task) async {
    // Implement task execution based on task type
    switch (task.type) {
      case 'upload':
        // Handle upload task
        break;
      case 'delete':
        // Handle delete task
        break;
      case 'update':
        // Handle update task
        break;
      default:
        throw Exception('Unknown sync task type: ${task.type}');
    }
  }

  /// Store sync task for offline persistence
  Future<void> _storeSyncTask(BackgroundSyncTask task) async {
    try {
      final tasks = await _loadStoredSyncTasks();
      tasks[task.id] = task.toJson();
      html.window.localStorage['pwa_sync_tasks'] = jsonEncode(tasks);
    } catch (e) {
      debugPrint('PWA: Failed to store sync task: $e');
    }
  }

  /// Remove stored sync task
  Future<void> _removeStoredSyncTask(String taskId) async {
    try {
      final tasks = await _loadStoredSyncTasks();
      tasks.remove(taskId);
      html.window.localStorage['pwa_sync_tasks'] = jsonEncode(tasks);
    } catch (e) {
      debugPrint('PWA: Failed to remove stored sync task: $e');
    }
  }

  /// Load stored sync tasks
  Future<Map<String, dynamic>> _loadStoredSyncTasks() async {
    try {
      final stored = html.window.localStorage['pwa_sync_tasks'];
      if (stored != null) {
        return Map<String, dynamic>.from(jsonDecode(stored));
      }
    } catch (e) {
      debugPrint('PWA: Failed to load stored sync tasks: $e');
    }
    return {};
  }

  /// Get PWA installation status
  bool get isInstalled {
    // Check if app is running in standalone mode (PWA)
    return html.window.matchMedia('(display-mode: standalone)').matches;
  }

  /// Get app install prompt
  Future<void> promptInstall() async {
    try {
      final prompt = html.window.document.querySelector('#install-prompt');
      if (prompt != null) {
        (prompt as html.EventTarget).dispatchEvent(html.Event('click'));
      }
    } catch (e) {
      debugPrint('PWA: Install prompt failed: $e');
    }
  }

  /// Share content using Web Share API
  Future<bool> shareContent(String title, String text, String url) async {
    try {
      // Try to use Web Share API - will throw if not supported
      await html.window.navigator.share({
        'title': title,
        'text': text,
        'url': url,
      });
      return true;
    } catch (e) {
      debugPrint('PWA: Share failed: $e');
    }
    return false;
  }

  /// Dispose resources
  void dispose() {
    _onlineStatusController.close();
    _messageController.close();
    _syncController.close();
    _notificationController.close();
  }
}

/// Background sync task model
class BackgroundSyncTask {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  BackgroundSyncTask({
    required this.id,
    required this.type,
    required this.data,
    DateTime? createdAt,
    this.retryCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  factory BackgroundSyncTask.fromJson(Map<String, dynamic> json) {
    return BackgroundSyncTask(
      id: json['id'],
      type: json['type'],
      data: Map<String, dynamic>.from(json['data']),
      createdAt: DateTime.parse(json['createdAt']),
      retryCount: json['retryCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
    };
  }
}

/// Push notification model
class PushNotification {
  final String title;
  final String body;
  final String? icon;
  final String? image;
  final Map<String, dynamic>? data;

  PushNotification({
    required this.title,
    required this.body,
    this.icon,
    this.image,
    this.data,
  });

  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      title: json['title'],
      body: json['body'],
      icon: json['icon'],
      image: json['image'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'icon': icon,
      'image': image,
      'data': data,
    };
  }
}