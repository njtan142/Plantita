import 'dart:async';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;
import '../models/file_selection_models.dart';

/// File Selection Service for web file picker and image handling
class FileSelectionService {
  final ImagePicker _imagePicker = ImagePicker();
  final StreamController<List<SelectedFile>> _filesController = StreamController<List<SelectedFile>>.broadcast();
  final StreamController<double> _progressController = StreamController<double>.broadcast();

  final List<SelectedFile> _selectedFiles = [];
  FileSelectionConfig _config = const FileSelectionConfig();

  /// Stream of selected files
  Stream<List<SelectedFile>> get filesStream => _filesController.stream;

  /// Stream of operation progress (0.0 to 1.0)
  Stream<double> get progressStream => _progressController.stream;

  /// Current selected files
  List<SelectedFile> get selectedFiles => List.unmodifiable(_selectedFiles);

  /// Current configuration
  FileSelectionConfig get config => _config;

  /// Update configuration
  void updateConfig(FileSelectionConfig newConfig) {
    _config = newConfig;
  }

  /// Pick files from device storage
  Future<List<SelectedFile>> pickFiles({
    FileSelectionConfig? config,
    bool fromGallery = true,
  }) async {
    final useConfig = config ?? _config;

    try {
      if (kIsWeb) {
        return await _pickFilesWeb(useConfig);
      } else {
        return await _pickFilesMobile(useConfig, fromGallery: fromGallery);
      }
    } catch (e) {
      throw FileSelectionException('Failed to pick files: $e');
    }
  }

  /// Pick files on web platform
  Future<List<SelectedFile>> _pickFilesWeb(FileSelectionConfig config) async {
    final uploadInput = html.InputElement();
    uploadInput.type = 'file';
    uploadInput.multiple = config.allowMultiple;
    uploadInput.accept = config.allowedExtensions.map((ext) => 'image/$ext').join(',');

    final completer = Completer<List<SelectedFile>>();
    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files == null || files.isEmpty) {
        completer.complete([]);
        return;
      }

      try {
        final selectedFilesList = <SelectedFile>[];
        final totalFiles = files.length;

        for (int i = 0; i < totalFiles && i < config.maxFilesCount; i++) {
          final file = files[i];
          _progressController.add(i / totalFiles);

          if (!await _validateWebFile(file, config)) {
            continue;
          }

          final processedFile = await _processWebFile(file, config);
          selectedFilesList.add(processedFile);
        }

        _selectedFiles.addAll(selectedFilesList);
        _filesController.add(_selectedFiles);
        _progressController.add(1.0);
        completer.complete(selectedFilesList);
      } catch (e) {
        completer.completeError(e);
      }
    });

    uploadInput.click();
    return completer.future;
  }

  /// Pick files on mobile platform
  Future<List<SelectedFile>> _pickFilesMobile(FileSelectionConfig config, {bool fromGallery = true}) async {
    try {
      if (fromGallery) {
        final pickedFiles = <SelectedFile>[];
        final totalFiles = config.allowMultiple ? config.maxFilesCount : 1;

        if (config.allowMultiple) {
          final images = await _imagePicker.pickMultiImage(
            maxWidth: config.maxWidth.toDouble(),
            maxHeight: config.maxHeight.toDouble(),
            imageQuality: config.imageQuality,
          );

          for (int i = 0; i < images.length && i < totalFiles; i++) {
            _progressController.add(i / images.length);
            final image = images[i];
            final processedFile = await _processMobileFile(image, config);
            pickedFiles.add(processedFile);
          }
        } else {
          final image = await _imagePicker.pickImage(
            source: ImageSource.gallery,
            maxWidth: config.maxWidth.toDouble(),
            maxHeight: config.maxHeight.toDouble(),
            imageQuality: config.imageQuality,
          );

          if (image != null) {
            _progressController.add(1.0);
            final processedFile = await _processMobileFile(image, config);
            pickedFiles.add(processedFile);
          }
        }

        _selectedFiles.addAll(pickedFiles);
        _filesController.add(_selectedFiles);
        return pickedFiles;
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: config.allowedExtensions,
          allowMultiple: config.allowMultiple,
        );

        if (result != null && result.files.isNotEmpty) {
          final pickedFiles = <SelectedFile>[];

          for (int i = 0; i < result.files.length && i < config.maxFilesCount; i++) {
            final file = result.files[i];
            _progressController.add(i / result.files.length);

            if (file.path == null) continue;

            if (!await _validatePlatformFile(file, config)) {
              continue;
            }

            final processedFile = await _processPlatformFile(file, config);
            pickedFiles.add(processedFile);
          }

          _selectedFiles.addAll(pickedFiles);
          _filesController.add(_selectedFiles);
          return pickedFiles;
        }
      }

      return [];
    } catch (e) {
      throw FileSelectionException('Failed to pick files: $e');
    }
  }

  /// Validate web file
  Future<bool> _validateWebFile(dynamic file, FileSelectionConfig config) async {
    try {
      final size = _getWebFileSize(file);
      if (size > config.maxFileSize) {
        throw FileSelectionException('File "${_getWebFileName(file)}" exceeds maximum size of ${config.maxFileSize ~/ (1024 * 1024)}MB');
      }

      final name = _getWebFileName(file);
      final extension = name.split('.').last.toLowerCase();
      if (!config.allowedExtensions.contains(extension)) {
        throw FileSelectionException('File type "$extension" is not allowed');
      }

      return true;
    } catch (e) {
      rethrow;
    }
  }

  /// Validate platform file
  Future<bool> _validatePlatformFile(PlatformFile file, FileSelectionConfig config) async {
    if (file.size > config.maxFileSize) {
      throw FileSelectionException('File "${file.name}" exceeds maximum size of ${config.maxFileSize ~/ (1024 * 1024)}MB');
    }

    if (file.extension != null && !config.allowedExtensions.contains(file.extension!.toLowerCase())) {
      throw FileSelectionException('File type "${file.extension}" is not allowed');
    }

    return true;
  }

  /// Process web file
  Future<SelectedFile> _processWebFile(dynamic file, FileSelectionConfig config) async {
    Uint8List? previewData;
    final type = _getWebFileType(file);
    if (config.compressImages && type.startsWith('image/')) {
      previewData = await _generateWebImagePreview(file, config);
    }

    return SelectedFile.fromWebFile(file, previewData: previewData);
  }

  /// Process mobile file
  Future<SelectedFile> _processMobileFile(XFile file, FileSelectionConfig config) async {
    Uint8List? previewData;
    if (config.compressImages) {
      previewData = await file.readAsBytes();
    }

    return SelectedFile(
      name: file.name,
      path: file.path,
      size: await file.length(),
      mimeType: 'image/jpeg',
      selectedAt: DateTime.now(),
      previewData: previewData,
    );
  }

  /// Process platform file
  Future<SelectedFile> _processPlatformFile(PlatformFile file, FileSelectionConfig config) async {
    Uint8List? previewData;
    if (config.compressImages && file.extension != null &&
        ['jpg', 'jpeg', 'png', 'webp'].contains(file.extension!.toLowerCase())) {
      previewData = await _generatePlatformImagePreview(file, config);
    }

    return SelectedFile.fromPlatformFile(file, previewData: previewData);
  }

  /// Generate image preview for web files
  Future<Uint8List> _generateWebImagePreview(dynamic file, FileSelectionConfig config) async {
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);

    await reader.onLoadEnd.first;
    final arrayBuffer = reader.result as Uint8List;

    if (config.compressImages) {
      return await FlutterImageCompress.compressWithList(
        arrayBuffer,
        minWidth: config.maxWidth,
        minHeight: config.maxHeight,
        quality: config.imageQuality,
      );
    }

    return arrayBuffer;
  }

  /// Generate image preview for platform files
  Future<Uint8List> _generatePlatformImagePreview(PlatformFile file, FileSelectionConfig config) async {
    if (file.path == null) return Uint8List(0);

    final originalData = await File(file.path!).readAsBytes();

    if (config.compressImages) {
      return await FlutterImageCompress.compressWithList(
        originalData,
        minWidth: config.maxWidth,
        minHeight: config.maxHeight,
        quality: config.imageQuality,
      );
    }

    return originalData;
  }

  // Helper methods for web file properties
  String _getWebFileName(dynamic file) {
    try {
      return file.name ?? 'unknown';
    } catch (e) {
      return 'unknown';
    }
  }

  int _getWebFileSize(dynamic file) {
    try {
      return file.size ?? 0;
    } catch (e) {
      return 0;
    }
  }

  String _getWebFileType(dynamic file) {
    try {
      return file.type ?? 'application/octet-stream';
    } catch (e) {
      return 'application/octet-stream';
    }
  }

  /// Clear selected files
  void clearFiles() {
    _selectedFiles.clear();
    _filesController.add([]);
  }

  /// Remove specific file
  void removeFile(SelectedFile file) {
    _selectedFiles.remove(file);
    _filesController.add(_selectedFiles);
  }

  /// Get total size of selected files
  int get totalSize => _selectedFiles.fold(0, (sum, file) => sum + file.size);

  /// Get formatted total size
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

  /// Dispose service and clean up resources
  void dispose() {
    _filesController.close();
    _progressController.close();
  }
}
