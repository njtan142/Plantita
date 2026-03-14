import 'upload_model.dart';

/// Upload queue item for managing concurrent uploads
class UploadQueueItem {
  final Upload upload;
  final List<int>? fileBytes;
  final String? filePath;
  final Function(double)? onProgress;
  final Function(Upload)? onComplete;
  final Function(String)? onError;
  final DateTime queuedAt;

  const UploadQueueItem({
    required this.upload,
    this.fileBytes,
    this.filePath,
    this.onProgress,
    this.onComplete,
    this.onError,
    required this.queuedAt,
  });

  UploadQueueItem copyWith({
    Upload? upload,
    List<int>? fileBytes,
    String? filePath,
    Function(double)? onProgress,
    Function(Upload)? onComplete,
    Function(String)? onError,
    DateTime? queuedAt,
  }) {
    return UploadQueueItem(
      upload: upload ?? this.upload,
      fileBytes: fileBytes ?? this.fileBytes,
      filePath: filePath ?? this.filePath,
      onProgress: onProgress ?? this.onProgress,
      onComplete: onComplete ?? this.onComplete,
      onError: onError ?? this.onError,
      queuedAt: queuedAt ?? this.queuedAt,
    );
  }
}

/// Upload statistics model
class UploadStats {
  final int totalUploads;
  final int pendingUploads;
  final int uploadingUploads;
  final int completedUploads;
  final int failedUploads;
  final int cancelledUploads;
  final int totalSize;

  const UploadStats({
    required this.totalUploads,
    required this.pendingUploads,
    required this.uploadingUploads,
    required this.completedUploads,
    required this.failedUploads,
    required this.cancelledUploads,
    required this.totalSize,
  });

  /// Total size formatted
  String get formattedTotalSize {
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = totalSize.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  @override
  String toString() {
    return 'UploadStats(total: $totalUploads, pending: $pendingUploads, uploading: $uploadingUploads, completed: $completedUploads, failed: $failedUploads, cancelled: $cancelledUploads)';
  }
}

/// Custom exception for upload-related errors
class UploadException implements Exception {
  final String message;
  const UploadException(this.message);

  @override
  String toString() => message;
}
