import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/upload_service.dart';
import '../services/file_selection_service.dart';
import 'base_provider.dart';
import 'user_selection_provider.dart';

class UploadProvider extends BaseProvider {
  final UploadService _uploadService;
  final FileSelectionService _fileSelectionService;
  final UserSelectionProvider _userSelectionProvider;

  List<UploadModel> _uploadQueue = [];
  List<UploadModel> _completedUploads = [];
  List<UploadModel> _failedUploads = [];
  bool _isUploading = false;

  UploadProvider(
    this._uploadService,
    this._fileSelectionService,
    this._userSelectionProvider,
  );

  List<UploadModel> get uploadQueue => _uploadQueue;
  List<UploadModel> get completedUploads => _completedUploads;
  List<UploadModel> get failedUploads => _failedUploads;
  bool get isUploading => _isUploading;
  int get totalProgress => _uploadQueue.isEmpty ? 0 :
    (_completedUploads.length + _failedUploads.length) * 100 ~/ _uploadQueue.length;

  void addFilesToUpload(List<PlatformFile> files) {
    if (_userSelectionProvider.selectedUser == null) {
      setError('Please select a user before uploading files');
      return;
    }

    final newUploads = files.map((file) => UploadModel(
      id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + file.name,
      file: file,
      user: _userSelectionProvider.selectedUser!,
      status: UploadStatus.pending,
      progress: 0,
      createdAt: DateTime.now(),
    )).toList();

    _uploadQueue.addAll(newUploads);
    notifyListeners();
  }

  void removeFromQueue(String uploadId) {
    _uploadQueue.removeWhere((upload) => upload.id == uploadId);
    notifyListeners();
  }

  void clearQueue() {
    _uploadQueue.clear();
    notifyListeners();
  }

  void clearCompleted() {
    _completedUploads.clear();
    notifyListeners();
  }

  void clearFailed() {
    _failedUploads.clear();
    notifyListeners();
  }

  Future<void> startUpload() async {
    if (_uploadQueue.isEmpty) {
      setError('No files to upload');
      return;
    }

    if (_userSelectionProvider.selectedUser == null) {
      setError('Please select a user before uploading');
      return;
    }

    try {
      setLoading(true);
      clearError();
      _isUploading = true;

      // Process uploads sequentially to avoid overwhelming the server
      for (final upload in _uploadQueue) {
        if (upload.status == UploadStatus.uploading ||
            upload.status == UploadStatus.completed) {
          continue;
        }

        await _uploadFile(upload);
      }
    } catch (e) {
      setError(e.toString());
    } finally {
      setLoading(false);
      _isUploading = false;
    }
  }

  Future<void> _uploadFile(UploadModel upload) async {
    try {
      upload.status = UploadStatus.uploading;
      notifyListeners();

      final response = await _uploadService.uploadFile(
        fileName: upload.file.name,
        fileBytes: upload.file.bytes!,
        mimeType: upload.file.extension != null
          ? 'application/${upload.file.extension}'
          : 'application/octet-stream',
        userId: upload.user.id,
        onProgress: (progress) {
          upload.progress = progress;
          notifyListeners();
        },
      );

      if (response.success && response.data != null) {
        upload.status = UploadStatus.completed;
        upload.result = response.data;
        _completedUploads.add(upload);
      } else {
        upload.status = UploadStatus.failed;
        upload.error = response.message ?? 'Upload failed';
        _failedUploads.add(upload);
      }
    } catch (e) {
      upload.status = UploadStatus.failed;
      upload.error = e.toString();
      _failedUploads.add(upload);
    } finally {
      notifyListeners();
    }
  }

  Future<void> retryFailedUploads() async {
    if (_failedUploads.isEmpty) return;

    final failedCopy = List<UploadModel>.from(_failedUploads);
    _failedUploads.clear();
    _uploadQueue.addAll(failedCopy);

    for (final upload in failedCopy) {
      upload.status = UploadStatus.pending;
      upload.progress = 0;
      upload.error = null;
    }

    notifyListeners();
    await startUpload();
  }

  Future<void> retryUpload(String uploadId) async {
    final upload = _failedUploads.firstWhere(
      (upload) => upload.id == uploadId,
      orElse: () => throw Exception('Upload not found'),
    );

    _failedUploads.remove(upload);
    upload.status = UploadStatus.pending;
    upload.progress = 0;
    upload.error = null;
    _uploadQueue.add(upload);

    notifyListeners();
    await startUpload();
  }

  int get pendingCount => _uploadQueue.where((u) => u.status == UploadStatus.pending).length;
  int get uploadingCount => _uploadQueue.where((u) => u.status == UploadStatus.uploading).length;
  int get completedCount => _completedUploads.length;
  int get failedCount => _failedUploads.length;

  @override
  void onDispose() {
    clearQueue();
    clearCompleted();
    clearFailed();
    super.onDispose();
  }
}