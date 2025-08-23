import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../models/models.dart';
import 'http_client_service.dart';
import 'performance_monitor_service.dart';
import 'memory_management_service.dart';

/// Enhanced upload service with offline queue processing and background capabilities
class EnhancedUploadService {
  final HttpClientService _httpClient;
  final SharedPreferences _prefs;
  final Connectivity _connectivity;
  final PerformanceMonitorService _performanceMonitor;
  final MemoryManagementService _memoryManager;

  // Upload queues
  final List<EnhancedUploadQueueItem> _activeUploads = [];
  final List<EnhancedUploadQueueItem> _offlineQueue = [];
  final List<EnhancedUploadQueueItem> _failedUploads = [];

  // Stream controllers
  final StreamController<UploadEvent> _uploadEventController = StreamController.broadcast();
  final StreamController<UploadProgress> _progressController = StreamController.broadcast();

  // Configuration
  final int _maxConcurrentUploads;
  final int _maxRetries;
  final Duration _retryDelay;
  final Duration _queuePersistenceInterval;
  final int _maxOfflineQueueSize;
  final Duration _backgroundTaskInterval;

  // State
  int _activeUploadCount = 0;
  Timer? _queuePersistenceTimer;
  Timer? _backgroundTaskTimer;
  bool _isBackgroundTaskRegistered = false;

  EnhancedUploadService({
    required HttpClientService httpClient,
    required SharedPreferences prefs,
    required PerformanceMonitorService performanceMonitor,
    required MemoryManagementService memoryManager,
    Connectivity? connectivity,
    int maxConcurrentUploads = 3,
    int maxRetries = 5,
    Duration retryDelay = const Duration(seconds: 5),
    Duration queuePersistenceInterval = const Duration(seconds: 30),
    int maxOfflineQueueSize = 100,
    Duration backgroundTaskInterval = const Duration(minutes: 15),
  })  : _httpClient = httpClient,
        _prefs = prefs,
        _performanceMonitor = performanceMonitor,
        _memoryManager = memoryManager,
        _connectivity = connectivity ?? Connectivity(),
        _maxConcurrentUploads = maxConcurrentUploads,
        _maxRetries = maxRetries,
        _retryDelay = retryDelay,
        _queuePersistenceInterval = queuePersistenceInterval,
        _maxOfflineQueueSize = maxOfflineQueueSize,
        _backgroundTaskInterval = backgroundTaskInterval {
    _initializeService();
  }

  /// Stream of upload events
  Stream<UploadEvent> get uploadEventStream => _uploadEventController.stream;

  /// Stream of upload progress
  Stream<UploadProgress> get progressStream => _progressController.stream;

  /// Current upload statistics
  UploadQueueStats get queueStats => UploadQueueStats(
    activeUploads: _activeUploads.length,
    offlineQueueLength: _offlineQueue.length,
    failedUploads: _failedUploads.length,
    maxConcurrentUploads: _maxConcurrentUploads,
  );

  /// Initialize the service
  void _initializeService() {
    // Load persisted queues
    _loadPersistedQueues();

    // Set up queue persistence
    _queuePersistenceTimer = Timer.periodic(_queuePersistenceInterval, (_) => _persistQueues());

    // Set up connectivity monitoring
    _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);

    // Initialize background tasks for mobile
    if (!kIsWeb) {
      _initializeBackgroundTasks();
    }

    // Process any pending offline uploads
    _processOfflineQueue();
  }

  /// Initialize background tasks for mobile
  Future<void> _initializeBackgroundTasks() async {
    try {
      // Use Timer-based approach for background processing when app is active
      _backgroundTaskTimer = Timer.periodic(_backgroundTaskInterval, (_) {
        if (!kIsWeb) {
          _processOfflineQueueInBackground();
        }
      });

      _isBackgroundTaskRegistered = true;
      debugPrint('📱 Background task timer registered for offline upload processing');
    } catch (e) {
      debugPrint('Error initializing background tasks: $e');
    }
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> result) {
    final connectivity = result.isNotEmpty ? result.first : ConnectivityResult.none;

    if (connectivity != ConnectivityResult.none) {
      debugPrint('🌐 Network restored, processing offline queue');
      _processOfflineQueue();
    } else {
      debugPrint('📶 Network lost, uploads will be queued offline');
    }

    _uploadEventController.add(UploadEvent(
      type: UploadEventType.connectivityChanged,
      connectivity: connectivity,
    ));
  }

  /// Upload file with enhanced features
  Future<Upload> uploadFile({
    required String fileName,
    required Uint8List fileBytes,
    required String mimeType,
    int? userId,
    Map<String, String>? additionalFields,
    UploadPriority priority = UploadPriority.normal,
    bool allowBackgroundUpload = true,
    Function(double)? onProgress,
    Function(Upload)? onComplete,
    Function(String)? onError,
  }) async {
    final startTime = DateTime.now();

    // Track performance
    _performanceMonitor.startTracking('enhanced_upload');

    try {
      // Create upload instance
      final upload = Upload(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        fileName: fileName,
        filePath: fileName,
        fileSize: fileBytes.length,
        mimeType: mimeType,
        userId: userId,
        uploadedBy: _httpClient.currentUser?.id ?? 0,
        status: UploadStatus.pending,
        createdAt: DateTime.now(),
        metadata: {
          'priority': priority.name,
          'allowBackground': allowBackgroundUpload,
        },
      );

      // Create queue item
      final queueItem = EnhancedUploadQueueItem(
        upload: upload,
        fileBytes: fileBytes,
        priority: priority,
        allowBackgroundUpload: allowBackgroundUpload,
        retryCount: 0,
        onProgress: onProgress,
        onComplete: onComplete,
        onError: onError,
        queuedAt: DateTime.now(),
      );

      // Check connectivity
      final connectivity = await _connectivity.checkConnectivity();
      final isOnline = connectivity != ConnectivityResult.none;

      if (isOnline) {
        // Add to active uploads
        _activeUploads.add(queueItem);
        _processActiveUploads();
      } else if (allowBackgroundUpload) {
        // Add to offline queue
        _addToOfflineQueue(queueItem);
      } else {
        throw EnhancedUploadException('No internet connection and background upload not allowed');
      }

      // Emit event
      _uploadEventController.add(UploadEvent(
        type: UploadEventType.uploadQueued,
        upload: upload,
      ));

      // End performance tracking
      _performanceMonitor.endTracking('enhanced_upload', result: {
        'fileSize': fileBytes.length,
        'mimeType': mimeType,
        'isOnline': isOnline,
        'priority': priority.name,
      });

      return upload;
    } catch (e) {
      _performanceMonitor.endTracking('enhanced_upload', result: {'error': e.toString()});
      rethrow;
    }
  }

  /// Process active uploads
  void _processActiveUploads() {
    while (_activeUploadCount < _maxConcurrentUploads && _activeUploads.isNotEmpty) {
      // Sort by priority
      _activeUploads.sort((a, b) => b.priority.index.compareTo(a.priority.index));

      final queueItem = _activeUploads.removeAt(0);
      _activeUploadCount++;
      _processUpload(queueItem);
    }
  }

  /// Process individual upload
  Future<void> _processUpload(EnhancedUploadQueueItem queueItem) async {
    try {
      // Update status
      var currentUpload = queueItem.upload.copyWith(status: UploadStatus.uploading);
      _uploadEventController.add(UploadEvent(
        type: UploadEventType.uploadStarted,
        upload: currentUpload,
      ));

      // Perform upload
      final result = await _performUpload(currentUpload, queueItem);

      // Update status to completed
      final completedUpload = result.copyWith(
        status: UploadStatus.completed,
        progress: 1.0,
        completedAt: DateTime.now(),
      );

      _uploadEventController.add(UploadEvent(
        type: UploadEventType.uploadCompleted,
        upload: completedUpload,
      ));

      queueItem.onProgress?.call(1.0);
      queueItem.onComplete?.call(completedUpload);

    } catch (e) {
      // Handle failure
      await _handleUploadFailure(queueItem, e.toString());
    } finally {
      _activeUploadCount--;
      _processActiveUploads();
    }
  }

  /// Perform the actual upload
  Future<Upload> _performUpload(Upload upload, EnhancedUploadQueueItem queueItem) async {
    try {
      final response = await _httpClient.uploadFile(
        '/uploads',
        'file',
        queueItem.fileBytes ?? Uint8List(0),
        upload.fileName,
        upload.mimeType,
        fields: {
          'user_id': upload.userId?.toString() ?? '',
          'uploaded_by': upload.uploadedBy.toString(),
          'original_filename': upload.fileName,
        },
        onProgress: (progress) {
          final updatedUpload = upload.copyWith(progress: progress);
          _progressController.add(UploadProgress(
            uploadId: upload.id,
            progress: progress,
            uploadedBytes: (upload.fileSize * progress).toInt(),
            totalBytes: upload.fileSize,
          ));
          queueItem.onProgress?.call(progress);
        },
      );

      if (response.success && response.data != null) {
        final serverData = response.data as Map<String, dynamic>;
        return upload.copyWith(
          id: serverData['id'] ?? upload.id,
          serverUrl: serverData['url'],
          metadata: serverData['metadata'],
        );
      } else {
        throw EnhancedUploadException(response.message ?? 'Upload failed');
      }
    } catch (e) {
      if (e is EnhancedUploadException) rethrow;
      throw EnhancedUploadException('Upload failed: ${e.toString()}');
    }
  }

  /// Handle upload failure
  Future<void> _handleUploadFailure(EnhancedUploadQueueItem queueItem, String error) async {
    final newRetryCount = queueItem.retryCount + 1;
    final updatedQueueItem = queueItem.copyWith(retryCount: newRetryCount);

    if (newRetryCount < _maxRetries) {
      // Retry after delay
      Timer(_retryDelay * newRetryCount, () {
        if (updatedQueueItem.allowBackgroundUpload) {
          _addToOfflineQueue(updatedQueueItem);
        } else {
          _activeUploads.add(updatedQueueItem);
          _processActiveUploads();
        }
      });
    } else {
      // Max retries reached
      final failedUpload = updatedQueueItem.upload.copyWith(
        status: UploadStatus.failed,
        errorMessage: error,
        completedAt: DateTime.now(),
      );

      _failedUploads.add(updatedQueueItem.copyWith(upload: failedUpload));

      _uploadEventController.add(UploadEvent(
        type: UploadEventType.uploadFailed,
        upload: failedUpload,
        error: error,
      ));

      updatedQueueItem.onError?.call(error);
    }
  }

  /// Add item to offline queue
  void _addToOfflineQueue(EnhancedUploadQueueItem queueItem) {
    if (_offlineQueue.length >= _maxOfflineQueueSize) {
      // Remove oldest item if queue is full
      _offlineQueue.removeAt(0);
    }

    _offlineQueue.add(queueItem);
    _persistQueues();

    _uploadEventController.add(UploadEvent(
      type: UploadEventType.uploadQueuedOffline,
      upload: queueItem.upload,
    ));
  }

  /// Process offline queue
  Future<void> _processOfflineQueue() async {
    if (_offlineQueue.isEmpty) return;

    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    debugPrint('📤 Processing ${_offlineQueue.length} offline uploads');

    // Sort by priority and queue time
    _offlineQueue.sort((a, b) {
      if (a.priority != b.priority) {
        return b.priority.index.compareTo(a.priority.index);
      }
      return a.queuedAt.compareTo(b.queuedAt);
    });

    final itemsToProcess = _offlineQueue.take(_maxConcurrentUploads * 2).toList();

    for (final queueItem in itemsToProcess) {
      _offlineQueue.remove(queueItem);
      _activeUploads.add(queueItem);
    }

    _processActiveUploads();
  }

  /// Process offline queue in background
  Future<void> _processOfflineQueueInBackground() async {
    debugPrint('🔄 Background processing of offline queue');

    final connectivity = await _connectivity.checkConnectivity();
    if (connectivity == ConnectivityResult.none) return;

    final itemsToProcess = _offlineQueue.take(5).toList(); // Process fewer in background

    for (final queueItem in itemsToProcess) {
      try {
        _offlineQueue.remove(queueItem);
        final result = await _performUpload(queueItem.upload, queueItem);

        final completedUpload = result.copyWith(
          status: UploadStatus.completed,
          progress: 1.0,
          completedAt: DateTime.now(),
        );

        _uploadEventController.add(UploadEvent(
          type: UploadEventType.uploadCompleted,
          upload: completedUpload,
        ));

      } catch (e) {
        // Re-add to offline queue for retry
        _offlineQueue.add(queueItem);
      }
    }

    _persistQueues();
  }

  /// Retry failed upload
  Future<bool> retryFailedUpload(String uploadId) async {
    final failedIndex = _failedUploads.indexWhere((item) => item.upload.id == uploadId);
    if (failedIndex != -1) {
      final queueItem = _failedUploads.removeAt(failedIndex);
      final retriedUpload = queueItem.upload.copyWith(
        status: UploadStatus.pending,
        errorMessage: null,
        progress: 0.0,
      );

      _activeUploads.add(queueItem.copyWith(
        upload: retriedUpload,
        retryCount: 0,
      ));

      _processActiveUploads();
      return true;
    }
    return false;
  }

  /// Cancel upload
  Future<bool> cancelUpload(String uploadId) async {
    // Check active uploads
    final activeIndex = _activeUploads.indexWhere((item) => item.upload.id == uploadId);
    if (activeIndex != -1) {
      final queueItem = _activeUploads.removeAt(activeIndex);
      final cancelledUpload = queueItem.upload.copyWith(
        status: UploadStatus.cancelled,
        completedAt: DateTime.now(),
      );

      _uploadEventController.add(UploadEvent(
        type: UploadEventType.uploadCancelled,
        upload: cancelledUpload,
      ));

      queueItem.onError?.call('Upload cancelled');
      return true;
    }

    // Check offline queue
    final offlineIndex = _offlineQueue.indexWhere((item) => item.upload.id == uploadId);
    if (offlineIndex != -1) {
      final queueItem = _offlineQueue.removeAt(offlineIndex);
      final cancelledUpload = queueItem.upload.copyWith(
        status: UploadStatus.cancelled,
        completedAt: DateTime.now(),
      );

      _uploadEventController.add(UploadEvent(
        type: UploadEventType.uploadCancelled,
        upload: cancelledUpload,
      ));

      return true;
    }

    return false;
  }

  /// Persist queues to storage
  Future<void> _persistQueues() async {
    try {
      final offlineQueueData = _offlineQueue.map((item) => item.toJson()).toList();
      final failedUploadsData = _failedUploads.map((item) => item.toJson()).toList();

      await _prefs.setString('offline_upload_queue', jsonEncode(offlineQueueData));
      await _prefs.setString('failed_uploads', jsonEncode(failedUploadsData));
    } catch (e) {
      debugPrint('Error persisting queues: $e');
    }
  }

  /// Load persisted queues
  Future<void> _loadPersistedQueues() async {
    try {
      final offlineQueueJson = _prefs.getString('offline_upload_queue');
      final failedUploadsJson = _prefs.getString('failed_uploads');

      if (offlineQueueJson != null) {
        final offlineQueueData = jsonDecode(offlineQueueJson) as List;
        _offlineQueue.addAll(
          offlineQueueData.map((data) => EnhancedUploadQueueItem.fromJson(data)),
        );
      }

      if (failedUploadsJson != null) {
        final failedUploadsData = jsonDecode(failedUploadsJson) as List;
        _failedUploads.addAll(
          failedUploadsData.map((data) => EnhancedUploadQueueItem.fromJson(data)),
        );
      }
    } catch (e) {
      debugPrint('Error loading persisted queues: $e');
    }
  }

  /// Get upload by ID
  Upload? getUpload(String uploadId) {
    for (final item in [..._activeUploads, ..._offlineQueue, ..._failedUploads]) {
      if (item.upload.id == uploadId) {
        return item.upload;
      }
    }
    return null;
  }

  /// Clear completed uploads
  void clearCompletedUploads() {
    _activeUploads.removeWhere((item) => item.upload.status == UploadStatus.completed);
    _offlineQueue.removeWhere((item) => item.upload.status == UploadStatus.completed);
    _failedUploads.removeWhere((item) => item.upload.status == UploadStatus.completed);
    _persistQueues();
  }

  /// Clear all uploads
  void clearAllUploads() {
    for (final item in _activeUploads) {
      cancelUpload(item.upload.id);
    }
    _offlineQueue.clear();
    _failedUploads.clear();
    _persistQueues();
  }

  /// Dispose resources
  void dispose() {
    _queuePersistenceTimer?.cancel();
    _backgroundTaskTimer?.cancel();
    _uploadEventController.close();
    _progressController.close();
    clearAllUploads();
  }
}

/// Enhanced upload queue item with additional metadata
class EnhancedUploadQueueItem {
  final Upload upload;
  final Uint8List? fileBytes;
  final UploadPriority priority;
  final bool allowBackgroundUpload;
  final int retryCount;
  final Function(double)? onProgress;
  final Function(Upload)? onComplete;
  final Function(String)? onError;
  final DateTime queuedAt;

  const EnhancedUploadQueueItem({
    required this.upload,
    this.fileBytes,
    this.priority = UploadPriority.normal,
    this.allowBackgroundUpload = true,
    this.retryCount = 0,
    this.onProgress,
    this.onComplete,
    this.onError,
    required this.queuedAt,
  });

  EnhancedUploadQueueItem copyWith({
    Upload? upload,
    Uint8List? fileBytes,
    UploadPriority? priority,
    bool? allowBackgroundUpload,
    int? retryCount,
    Function(double)? onProgress,
    Function(Upload)? onComplete,
    Function(String)? onError,
    DateTime? queuedAt,
  }) {
    return EnhancedUploadQueueItem(
      upload: upload ?? this.upload,
      fileBytes: fileBytes ?? this.fileBytes,
      priority: priority ?? this.priority,
      allowBackgroundUpload: allowBackgroundUpload ?? this.allowBackgroundUpload,
      retryCount: retryCount ?? this.retryCount,
      onProgress: onProgress ?? this.onProgress,
      onComplete: onComplete ?? this.onComplete,
      onError: onError ?? this.onError,
      queuedAt: queuedAt ?? this.queuedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'upload': upload.toJson(),
      'fileBytes': fileBytes != null ? base64Encode(fileBytes!) : null,
      'priority': priority.name,
      'allowBackgroundUpload': allowBackgroundUpload,
      'retryCount': retryCount,
      'queuedAt': queuedAt.toIso8601String(),
    };
  }

  factory EnhancedUploadQueueItem.fromJson(Map<String, dynamic> json) {
    return EnhancedUploadQueueItem(
      upload: Upload.fromJson(json['upload']),
      fileBytes: json['fileBytes'] != null ? base64Decode(json['fileBytes']) : null,
      priority: UploadPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => UploadPriority.normal,
      ),
      allowBackgroundUpload: json['allowBackgroundUpload'] ?? true,
      retryCount: json['retryCount'] ?? 0,
      queuedAt: DateTime.parse(json['queuedAt']),
    );
  }
}

/// Upload priority levels
enum UploadPriority {
  low,
  normal,
  high,
  critical,
}

/// Upload event types
enum UploadEventType {
  uploadQueued,
  uploadStarted,
  uploadProgress,
  uploadCompleted,
  uploadFailed,
  uploadCancelled,
  uploadQueuedOffline,
  connectivityChanged,
}

/// Upload event data
class UploadEvent {
  final UploadEventType type;
  final Upload? upload;
  final String? error;
  final ConnectivityResult? connectivity;

  const UploadEvent({
    required this.type,
    this.upload,
    this.error,
    this.connectivity,
  });

  /// Get metadata associated with this upload event
  Map<String, dynamic>? get metadata {
    final Map<String, dynamic> meta = {};

    if (upload != null) {
      meta.addAll({
        'uploadId': upload!.id,
        'fileName': upload!.fileName,
        'fileSize': upload!.fileSize,
        'mimeType': upload!.mimeType,
        'userId': upload!.userId,
        'status': upload!.status.name,
        'progress': upload!.progress,
      });

      if (upload!.serverUrl != null) {
        meta['serverUrl'] = upload!.serverUrl;
      }

      if (upload!.errorMessage != null) {
        meta['errorMessage'] = upload!.errorMessage;
      }

      if (upload!.metadata != null) {
        meta.addAll(upload!.metadata!);
      }
    }

    if (error != null) {
      meta['error'] = error;
    }

    if (connectivity != null) {
      meta['connectivity'] = connectivity!.name;
    }

    meta['eventType'] = type.name;
    meta['timestamp'] = DateTime.now().toIso8601String();

    return meta.isNotEmpty ? meta : null;
  }
}

/// Upload progress data
class UploadProgress {
  final String uploadId;
  final double progress;
  final int uploadedBytes;
  final int totalBytes;

  const UploadProgress({
    required this.uploadId,
    required this.progress,
    required this.uploadedBytes,
    required this.totalBytes,
  });
}

/// Upload queue statistics
class UploadQueueStats {
  final int activeUploads;
  final int offlineQueueLength;
  final int failedUploads;
  final int maxConcurrentUploads;

  const UploadQueueStats({
    required this.activeUploads,
    required this.offlineQueueLength,
    required this.failedUploads,
    required this.maxConcurrentUploads,
  });

  bool get hasOfflineUploads => offlineQueueLength > 0;
  bool get hasFailedUploads => failedUploads > 0;
  bool get isAtCapacity => activeUploads >= maxConcurrentUploads;
}

/// Custom exception for enhanced upload errors
class EnhancedUploadException implements Exception {
  final String message;
  const EnhancedUploadException(this.message);

  @override
  String toString() => message;
}