import 'dart:io' if (dart.library.html) 'dart:html' as html;
import 'package:http/http.dart' as http;

/// Upload status enumeration
enum UploadStatus {
  pending,
  uploading,
  completed,
  failed,
  cancelled,
}

/// Extension to provide readable string representation of UploadStatus
extension UploadStatusExtension on UploadStatus {
  String get displayName {
    switch (this) {
      case UploadStatus.pending:
        return 'Pending';
      case UploadStatus.uploading:
        return 'Uploading';
      case UploadStatus.completed:
        return 'Completed';
      case UploadStatus.failed:
        return 'Failed';
      case UploadStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Upload model representing a file upload with progress tracking
class Upload {
  final String id;
  final String fileName;
  final String filePath;
  final int fileSize;
  final String mimeType;
  final int? userId;
  final int uploadedBy;
  final UploadStatus status;
  final double progress; // 0.0 to 1.0
  final String? errorMessage;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? serverUrl;
  final Map<String, dynamic>? metadata;

  const Upload({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.fileSize,
    required this.mimeType,
    this.userId,
    required this.uploadedBy,
    this.status = UploadStatus.pending,
    this.progress = 0.0,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
    this.serverUrl,
    this.metadata,
  });

  /// File size in human readable format
  String get fileSizeFormatted {
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = fileSize.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    // Don't show decimal places for bytes, but show for larger units
    if (unitIndex == 0) {
      return '${size.toInt()} ${units[unitIndex]}';
    } else {
      return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
    }
  }

  /// Check if upload is in progress
  bool get isInProgress => status == UploadStatus.uploading;

  /// Check if upload is completed successfully
  bool get isCompleted => status == UploadStatus.completed;

  /// Check if upload failed
  bool get hasError => status == UploadStatus.failed;

  /// Check if upload can be retried
  bool get canRetry => status == UploadStatus.failed && errorMessage != null;

  /// Check if upload can be cancelled
  bool get canCancel => status == UploadStatus.pending || status == UploadStatus.uploading;

  /// Progress percentage (0-100)
  int get progressPercentage => (progress * 100).round();

  /// Estimated remaining time based on current progress (in seconds)
  int? get estimatedTimeRemaining {
    if (progress <= 0 || progress >= 1) return null;
    // This is a simple estimation - in real implementation you'd track upload speed
    return ((1 - progress) * 30).round(); // Assume 30 seconds total for estimation
  }

  /// Create Upload from JSON response
  factory Upload.fromJson(Map<String, dynamic> json) {
    return Upload(
      id: json['id'] as String,
      fileName: json['file_name'] as String,
      filePath: json['file_path'] as String,
      fileSize: json['file_size'] as int,
      mimeType: json['mime_type'] as String,
      userId: json['user_id'] as int?,
      uploadedBy: json['uploaded_by'] as int,
      status: UploadStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => UploadStatus.pending,
      ),
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      errorMessage: json['error_message'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      serverUrl: json['server_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convert Upload to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'file_path': filePath,
      'file_size': fileSize,
      'mime_type': mimeType,
      'user_id': userId,
      'uploaded_by': uploadedBy,
      'status': status.name,
      'progress': progress,
      'error_message': errorMessage,
      'created_at': createdAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'server_url': serverUrl,
      'metadata': metadata,
    };
  }

  /// Create a copy of Upload with updated fields
  Upload copyWith({
    String? id,
    String? fileName,
    String? filePath,
    int? fileSize,
    String? mimeType,
    int? userId,
    int? uploadedBy,
    UploadStatus? status,
    double? progress,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? completedAt,
    String? serverUrl,
    Map<String, dynamic>? metadata,
  }) {
    return Upload(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      userId: userId ?? this.userId,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      serverUrl: serverUrl ?? this.serverUrl,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Upload && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Upload(id: $id, fileName: $fileName, status: ${status.name}, progress: $progressPercentage%)';
  }
}

/// Upload queue item for managing concurrent uploads
class UploadQueueItem {
  final Upload upload;
  final http.MultipartFile? multipartFile;
  final html.File? webFile;
  final Function(double)? onProgress;
  final Function(Upload)? onComplete;
  final Function(String)? onError;
  final DateTime queuedAt;

  const UploadQueueItem({
    required this.upload,
    this.multipartFile,
    this.webFile,
    this.onProgress,
    this.onComplete,
    this.onError,
    required this.queuedAt,
  });

  UploadQueueItem copyWith({
    Upload? upload,
    http.MultipartFile? multipartFile,
    html.File? webFile,
    Function(double)? onProgress,
    Function(Upload)? onComplete,
    Function(String)? onError,
    DateTime? queuedAt,
  }) {
    return UploadQueueItem(
      upload: upload ?? this.upload,
      multipartFile: multipartFile ?? this.multipartFile,
      webFile: webFile ?? this.webFile,
      onProgress: onProgress ?? this.onProgress,
      onComplete: onComplete ?? this.onComplete,
      onError: onError ?? this.onError,
      queuedAt: queuedAt ?? this.queuedAt,
    );
  }
}