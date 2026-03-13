import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

/// Selected file information
class SelectedFile {
  final String name;
  final String path;
  final int size;
  final String mimeType;
  final DateTime selectedAt;
  final Uint8List? previewData;
  final Map<String, dynamic>? metadata;

  const SelectedFile({
    required this.name,
    required this.path,
    required this.size,
    required this.mimeType,
    required this.selectedAt,
    this.previewData,
    this.metadata,
  });

  /// Get file size in human readable format
  String get formattedSize {
    const units = ['B', 'KB', 'MB', 'GB'];
    var fileSize = size.toDouble();
    var unitIndex = 0;

    while (fileSize >= 1024 && unitIndex < units.length - 1) {
      fileSize /= 1024;
      unitIndex++;
    }

    return '${fileSize.toStringAsFixed(1)} ${units[unitIndex]}';
  }

  /// Check if file is an image
  bool get isImage => mimeType.startsWith('image/');

  /// Check if file is a video
  bool get isVideo => mimeType.startsWith('video/');

  /// Get file extension
  String get extension => name.split('.').last.toLowerCase();

  /// Create SelectedFile from web file
  factory SelectedFile.fromWebFile(dynamic file, {Uint8List? previewData}) {
    return SelectedFile(
      name: _getWebFileName(file),
      path: _getWebFileName(file), // Web files don't have paths
      size: _getWebFileSize(file),
      mimeType: _getWebFileType(file),
      selectedAt: DateTime.now(),
      previewData: previewData,
    );
  }

  /// Create SelectedFile from platform file
  factory SelectedFile.fromPlatformFile(PlatformFile file, {Uint8List? previewData}) {
    return SelectedFile(
      name: file.name,
      path: file.path ?? '',
      size: file.size,
      mimeType: file.extension != null
          ? 'image/${file.extension}'
          : 'application/octet-stream',
      selectedAt: DateTime.now(),
      previewData: previewData,
    );
  }

  // Helper methods for web file properties
  static String _getWebFileName(dynamic file) {
    try {
      return file.name ?? 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  static int _getWebFileSize(dynamic file) {
    try {
      return file.size ?? 0;
    } catch (e) {
      return 0;
    }
  }

  static String _getWebFileType(dynamic file) {
    try {
      return file.type ?? 'application/octet-stream';
    } catch (e) {
      return 'application/octet-stream';
    }
  }

  @override
  String toString() {
    return 'SelectedFile(name: $name, size: $formattedSize, type: $mimeType)';
  }
}

/// File selection configuration
class FileSelectionConfig {
  final List<String> allowedExtensions;
  final int maxFileSize; // bytes
  final int maxFilesCount;
  final bool allowMultiple;
  final bool compressImages;
  final int maxWidth;
  final int maxHeight;
  final int imageQuality;

  const FileSelectionConfig({
    this.allowedExtensions = const ['jpg', 'jpeg', 'png', 'gif', 'webp'],
    this.maxFileSize = 10 * 1024 * 1024, // 10MB
    this.maxFilesCount = 10,
    this.allowMultiple = true,
    this.compressImages = true,
    this.maxWidth = 1920,
    this.maxHeight = 1080,
    this.imageQuality = 85,
  });

  /// Create config for images only
  factory FileSelectionConfig.imagesOnly() {
    return const FileSelectionConfig(
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      maxFileSize: 5 * 1024 * 1024, // 5MB
      maxFilesCount: 5,
      allowMultiple: true,
      compressImages: true,
    );
  }

  /// Create config for single file selection
  factory FileSelectionConfig.singleFile() {
    return const FileSelectionConfig(
      maxFilesCount: 1,
      allowMultiple: false,
    );
  }
}

/// Custom exception for file selection errors
class FileSelectionException implements Exception {
  final String message;
  const FileSelectionException(this.message);

  @override
  String toString() => message;
}
