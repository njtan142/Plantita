import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/upload_service.dart';
import '../services/file_selection_service.dart';
import 'base_provider.dart';
import 'user_selection_provider.dart';

class UploadModelProvider extends BaseProvider {
  final UploadService _uploadService;
  final FileSelectionService _fileSelectionService;
  final UserSelectionProvider _userSelectionProvider;

  List<UploadModel> _uploadQueue = [];
  List<UploadModel> _completedUploadModels = [];
  List<UploadModel> _failedUploadModels = [];
  bool _isUploadModeling = false;

  UploadModelProvider(
    this._uploadService,
    this._fileSelectionService,
    this._userSelectionProvider,
  );

  List<UploadModel> get uploadQueue => _uploadQueue;
  List<UploadModel> get completedUploadModels => _completedUploadModels;
  List<UploadModel> get failedUploadModels => _failedUploadModels;
  bool get isUploadModeling => _isUploadModeling;
  int get totalProgress => _uploadQueue.isEmpty ? 0 :
    (_completedUploadModels.length + _failedUploadModels.length) * 100 ~/ _uploadQueue.length;

  void addFilesToUploadModel(List<PlatformFile> files) {
    if (_userSelectionProvider.selectedUser == null) {
      setError('Please select a user before uploading files');
      return;
    }

    final newUploadModels = files.map((file) => UploadModel(
      id: DateTime.now().millisecondsSinceEpoch.toString() + '_' + file.name,
      file: file,
      user: _userSelectionProvider.selectedUser!,
      status: UploadStatus.pending,
      progress: 0,
      createdAt: DateTime.now(),
    )).toList();

    _uploadQueue.addAll(newUploadModels);
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
    _completedUploadModels.clear();
    notifyListeners();
  }

  void clearFailed() {
    _failedUploadModels.clear();
    notifyListeners();
  }

  Future<void> startUploadModel() async {
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
      _isUploadModeling = true;

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
      _isUploadModeling = false;
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
        _completedUploadModels.add(upload);
      } else {
        upload.status = UploadStatus.failed;
        upload.error = response.message ?? 'UploadModel failed';
        _failedUploadModels.add(upload);
      }
    } catch (e) {
      upload.status = UploadStatus.failed;
      upload.error = e.toString();
      _failedUploadModels.add(upload);
    } finally {
      notifyListeners();
    }
  }

  Future<void> retryFailedUploadModels() async {
    if (_failedUploadModels.isEmpty) return;

    final failedCopy = List<UploadModel>.from(_failedUploadModels);
    _failedUploadModels.clear();
    _uploadQueue.addAll(failedCopy);

    for (final upload in failedCopy) {
      upload.status = UploadStatus.pending;
      upload.progress = 0;
      upload.error = null;
    }

    notifyListeners();
    await startUploadModel();
  }

  Future<void> retryUploadModel(String uploadId) async {
    final upload = _failedUploadModels.firstWhere(
      (upload) => upload.id == uploadId,
      orElse: () => throw Exception('UploadModel not found'),
    );

    _failedUploadModels.remove(upload);
    upload.status = UploadStatus.pending;
    upload.progress = 0;
    upload.error = null;
    _uploadQueue.add(upload);

    notifyListeners();
    await startUploadModel();
  }

  int get pendingCount => _uploadQueue.where((u) => u.status == UploadStatus.pending).length;
  int get uploadingCount => _uploadQueue.where((u) => u.status == UploadStatus.uploading).length;
  int get completedCount => _completedUploadModels.length;
  int get failedCount => _failedUploadModels.length;

  @override
  void onDispose() {
    clearQueue();
    clearCompleted();
    clearFailed();
    super.onDispose();
  }
}