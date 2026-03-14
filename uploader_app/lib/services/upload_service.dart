import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:retry/retry.dart';
import '../models/models.dart';
import '../models/upload_service_models.dart';
import 'http_client_service.dart';

/// Upload service for handling file uploads with progress tracking
class UploadService {
  final HttpClientService _httpClient;
  final Connectivity _connectivity;

  // Upload queue management
  final List<UploadQueueItem> _uploadQueue = [];
  final StreamController<Upload> _uploadController = StreamController<Upload>.broadcast();
  final StreamController<double> _progressController = StreamController<double>.broadcast();

  // Configuration
  final int _maxConcurrentUploads;
  final Duration _retryDelay;
  final int _maxRetries;

  int _activeUploads = 0;

  UploadService({
    required HttpClientService httpClient,
    Connectivity? connectivity,
    int maxConcurrentUploads = 3,
    Duration retryDelay = const Duration(seconds: 2),
    int maxRetries = 3,
  })  : _httpClient = httpClient,
        _connectivity = connectivity ?? Connectivity(),
        _maxConcurrentUploads = maxConcurrentUploads,
        _retryDelay = retryDelay,
        _maxRetries = maxRetries;

  /// Stream of upload status updates
  Stream<Upload> get uploadStream => _uploadController.stream;

  /// Stream of overall progress (0.0 to 1.0)
  Stream<double> get progressStream => _progressController.stream;

  /// Current upload queue
  List<UploadQueueItem> get uploadQueue => List.unmodifiable(_uploadQueue);

  /// Number of active uploads
  int get activeUploads => _activeUploads;

  /// Number of queued uploads
  int get queuedUploads => _uploadQueue.length;

  /// Upload file with user association
  Future<ApiResponse<Upload>> uploadFile({
    required String fileName,
    required List<int> fileBytes,
    required String mimeType,
    int? userId,
    Map<String, String>? additionalFields,
    Function(double)? onProgress,
    Function(Upload)? onComplete,
    Function(String)? onError,
  }) async {
    // Create upload instance
    final upload = Upload(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: fileName,
      filePath: fileName, // For web files, path is the filename
      fileSize: fileBytes.length,
      mimeType: mimeType,
      userId: userId,
      uploadedBy: _httpClient.currentUser?.id ?? 0,
      status: UploadStatus.pending,
      createdAt: DateTime.now(),
    );

    // Create queue item
    final queueItem = UploadQueueItem(
      upload: upload,
      fileBytes: fileBytes,
      onProgress: onProgress,
      onComplete: onComplete,
      onError: onError,
      queuedAt: DateTime.now(),
    );

    // Add to queue
    _uploadQueue.add(queueItem);

    // Process queue
    _processUploadQueue();

    return ApiResponse.success(upload, message: 'Upload queued successfully');
  }

  /// Upload file from path with user association
  Future<ApiResponse<Upload>> uploadFileFromPath({
    required String filePath,
    required String fileName,
    required int fileSize,
    required String mimeType,
    int? userId,
    Map<String, String>? additionalFields,
    Function(double)? onProgress,
    Function(Upload)? onComplete,
    Function(String)? onError,
  }) async {
    // Create upload instance
    final upload = Upload(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: fileName,
      filePath: filePath,
      fileSize: fileSize,
      mimeType: mimeType,
      userId: userId,
      uploadedBy: _httpClient.currentUser?.id ?? 0,
      status: UploadStatus.pending,
      createdAt: DateTime.now(),
    );

    // Create queue item
    final queueItem = UploadQueueItem(
      upload: upload,
      filePath: filePath,
      onProgress: onProgress,
      onComplete: onComplete,
      onError: onError,
      queuedAt: DateTime.now(),
    );

    // Add to queue
    _uploadQueue.add(queueItem);

    // Process queue
    _processUploadQueue();

    return ApiResponse.success(upload, message: 'Upload queued successfully');
  }

  /// Process upload queue with concurrency control
  void _processUploadQueue() async {
    while (_activeUploads < _maxConcurrentUploads && _uploadQueue.isNotEmpty) {
      final queueItem = _uploadQueue.removeAt(0);
      _activeUploads++;
      _processUpload(queueItem);
    }
  }

  /// Process individual upload
  Future<void> _processUpload(UploadQueueItem queueItem) async {
    try {
      // Check connectivity
      final connectivity = await _connectivity.checkConnectivity();
      if (connectivity == ConnectivityResult.none) {
        throw UploadException('No internet connection');
      }

      // Update status to uploading
      var currentUpload = queueItem.upload.copyWith(status: UploadStatus.uploading);
      _uploadController.add(currentUpload);
      queueItem.onProgress?.call(0.0);

      // Perform upload with retry logic
      final result = await retry(
        () => _performUpload(currentUpload, queueItem),
        retryIf: (e) => e is UploadException && e.message.contains('Network error'),
        maxAttempts: _maxRetries,
        delayFactor: _retryDelay,
      );

      // Update status to completed
      final completedUpload = result.copyWith(
        status: UploadStatus.completed,
        progress: 1.0,
        completedAt: DateTime.now(),
      );

      _uploadController.add(completedUpload);
      queueItem.onProgress?.call(1.0);
      queueItem.onComplete?.call(completedUpload);

    } catch (e) {
      // Update status to failed
      final failedUpload = queueItem.upload.copyWith(
        status: UploadStatus.failed,
        errorMessage: e.toString(),
        completedAt: DateTime.now(),
      );

      _uploadController.add(failedUpload);
      queueItem.onError?.call(e.toString());
    } finally {
      _activeUploads--;
      _processUploadQueue(); // Continue processing queue
      _updateOverallProgress();
    }
  }

  /// Perform the actual upload
  Future<Upload> _performUpload(Upload upload, UploadQueueItem queueItem) async {
    try {
      final response = await _httpClient.uploadFile(
        '/uploads',
        'file',
        queueItem.fileBytes ?? [],
        upload.fileName,
        upload.mimeType,
        fields: {
          'user_id': upload.userId?.toString() ?? '',
          'uploaded_by': upload.uploadedBy.toString(),
          'original_filename': upload.fileName,
        },
        onProgress: (progress) {
          final updatedUpload = upload.copyWith(progress: progress);
          _uploadController.add(updatedUpload);
          queueItem.onProgress?.call(progress);
          _updateOverallProgress();
        },
      );

      if (response.success && response.data != null) {
        // Parse server response
        final serverData = response.data as Map<String, dynamic>;
        return upload.copyWith(
          id: serverData['id'] ?? upload.id,
          serverUrl: serverData['url'],
          metadata: serverData['metadata'],
        );
      } else {
        throw UploadException(response.message ?? 'Upload failed');
      }
    } catch (e) {
      if (e is UploadException) rethrow;
      throw UploadException('Upload failed: ${e.toString()}');
    }
  }

  /// Cancel upload by ID
  Future<bool> cancelUpload(String uploadId) async {
    final index = _uploadQueue.indexWhere((item) => item.upload.id == uploadId);
    if (index != -1) {
      final queueItem = _uploadQueue.removeAt(index);
      final cancelledUpload = queueItem.upload.copyWith(
        status: UploadStatus.cancelled,
        completedAt: DateTime.now(),
      );
      _uploadController.add(cancelledUpload);
      return true;
    }
    return false;
  }

  /// Cancel all uploads
  void cancelAllUploads() {
    for (final queueItem in _uploadQueue) {
      final cancelledUpload = queueItem.upload.copyWith(
        status: UploadStatus.cancelled,
        completedAt: DateTime.now(),
      );
      _uploadController.add(cancelledUpload);
      queueItem.onError?.call('Upload cancelled');
    }
    _uploadQueue.clear();
    _activeUploads = 0;
  }

  /// Retry failed upload
  Future<bool> retryUpload(String uploadId) async {
    // Find failed upload
    final failedUploads = _uploadQueue.where(
      (item) => item.upload.id == uploadId && item.upload.status == UploadStatus.failed
    ).toList();

    if (failedUploads.isNotEmpty) {
      final queueItem = failedUploads.first;
      final retriedUpload = queueItem.upload.copyWith(
        status: UploadStatus.pending,
        errorMessage: null,
        progress: 0.0,
      );

      // Remove old failed item and add new one
      _uploadQueue.remove(queueItem);
      _uploadQueue.add(queueItem.copyWith(upload: retriedUpload));

      _processUploadQueue();
      return true;
    }

    return false;
  }

  /// Get upload statistics
  UploadStats getUploadStats() {
    final total = _uploadQueue.length + _activeUploads;
    final pending = _uploadQueue.where((item) => item.upload.status == UploadStatus.pending).length;
    final uploading = _activeUploads;
    final completed = _uploadQueue.where((item) => item.upload.status == UploadStatus.completed).length;
    final failed = _uploadQueue.where((item) => item.upload.status == UploadStatus.failed).length;
    final cancelled = _uploadQueue.where((item) => item.upload.status == UploadStatus.cancelled).length;

    final totalSize = _uploadQueue.fold<int>(
      0,
      (sum, item) => sum + item.upload.fileSize,
    );

    return UploadStats(
      totalUploads: total,
      pendingUploads: pending,
      uploadingUploads: uploading,
      completedUploads: completed,
      failedUploads: failed,
      cancelledUploads: cancelled,
      totalSize: totalSize,
    );
  }

  /// Update overall progress
  void _updateOverallProgress() {
    if (_uploadQueue.isEmpty && _activeUploads == 0) {
      _progressController.add(1.0);
      return;
    }

    double totalProgress = 0.0;
    int totalUploads = _uploadQueue.length + _activeUploads;

    for (final item in _uploadQueue) {
      totalProgress += item.upload.progress;
    }

    // Add progress for active uploads (assume 50% progress if no specific progress available)
    totalProgress += _activeUploads * 0.5;

    _progressController.add(totalProgress / totalUploads);
  }

  /// Clear completed uploads from queue
  void clearCompletedUploads() {
    _uploadQueue.removeWhere(
      (item) => item.upload.status == UploadStatus.completed ||
               item.upload.status == UploadStatus.cancelled
    );
  }

  /// Dispose service and clean up resources
  void dispose() {
    cancelAllUploads();
    _uploadController.close();
    _progressController.close();
  }
}
