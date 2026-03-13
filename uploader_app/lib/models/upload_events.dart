import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'upload_model.dart';

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
