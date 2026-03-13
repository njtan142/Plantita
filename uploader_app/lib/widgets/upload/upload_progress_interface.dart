import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/user_model.dart';
import '../../models/upload_model.dart';
import '../../services/upload_service.dart';
import '../../utils/responsive_config.dart';
import '../common/custom_button.dart';
import 'upload_types.dart';
import 'components/overall_progress_header.dart';
import 'components/upload_queue_item.dart';

class UploadProgressInterface extends StatefulWidget {
  final UserModel? selectedUser;
  final List<PlatformFile> selectedFiles;
  final Function(List<UploadResult> results)? onUploadComplete;

  const UploadProgressInterface({
    super.key,
    this.selectedUser,
    required this.selectedFiles,
    this.onUploadComplete,
  });

  @override
  State<UploadProgressInterface> createState() => _UploadProgressInterfaceState();
}

class _UploadProgressInterfaceState extends State<UploadProgressInterface>
    with TickerProviderStateMixin {
  final List<UploadItem> _uploadQueue = [];
  final List<UploadResult> _completedUploads = [];
  bool _isUploading = false;
  bool _isCancelled = false;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _prepareUploadQueue();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  void _prepareUploadQueue() {
    _uploadQueue.clear();
    for (final file in widget.selectedFiles) {
      _uploadQueue.add(UploadItem(
        file: file,
        user: widget.selectedUser,
        status: UploadStatus.pending,
        progress: 0.0,
      ));
    }
  }

  Future<void> _startUpload() async {
    if (_uploadQueue.isEmpty || _isUploading) return;

    setState(() {
      _isUploading = true;
      _isCancelled = false;
    });

    final uploadService = Provider.of<UploadService>(context, listen: false);

    for (final uploadItem in _uploadQueue) {
      if (_isCancelled) break;

      setState(() {
        uploadItem.status = UploadStatus.uploading;
      });

      try {
        final result = await uploadService.uploadFile(
          fileName: uploadItem.file.name,
          fileBytes: uploadItem.file.bytes!,
          mimeType: uploadItem.file.extension != null
            ? 'application/${uploadItem.file.extension}'
            : 'application/octet-stream',
          userId: uploadItem.user?.id,
          onProgress: (progress) {
            if (mounted && !_isCancelled) {
              setState(() {
                uploadItem.progress = progress;
              });
            }
          },
        );

        setState(() {
          uploadItem.status = UploadStatus.completed;
          final uploadResult = UploadResult.success(
            fileName: uploadItem.file.name,
            message: result.message ?? 'Upload completed successfully',
            fileUrl: result.data?.serverUrl,
            fileId: result.data?.id,
          );
          uploadItem.result = uploadResult;
          _completedUploads.add(uploadResult);
        });

        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        setState(() {
          uploadItem.status = UploadStatus.failed;
          uploadItem.errorMessage = e.toString();
          _completedUploads.add(UploadResult(
            fileName: uploadItem.file.name,
            success: false,
            message: e.toString(),
          ));
        });
      }
    }

    setState(() {
      _isUploading = false;
    });

    if (widget.onUploadComplete != null) {
      widget.onUploadComplete!(_completedUploads);
    }

    _showCompletionMessage();
  }

  void _cancelUpload() {
    setState(() {
      _isCancelled = true;
      _isUploading = false;
      for (final item in _uploadQueue) {
        if (item.status == UploadStatus.uploading) {
          item.status = UploadStatus.cancelled;
        }
      }
    });
  }

  void _retryFailedUploads() {
    final failedUploads = _uploadQueue
        .where((item) => item.status == UploadStatus.failed)
        .toList();

    for (final item in failedUploads) {
      item.status = UploadStatus.pending;
      item.progress = 0.0;
      item.errorMessage = null;
    }

    _startUpload();
  }

  void _showCompletionMessage() {
    final successCount = _completedUploads.where((r) => r.success).length;
    final totalCount = _completedUploads.length;

    String message;
    Color backgroundColor;

    if (successCount == totalCount) {
      message = 'All $totalCount files uploaded successfully!';
      backgroundColor = Colors.green;
    } else if (successCount > 0) {
      message = 'Uploaded $successCount of $totalCount files. Some failed.';
      backgroundColor = Colors.orange;
    } else {
      message = 'All $totalCount uploads failed.';
      backgroundColor = Colors.red;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 4),
        action: successCount < totalCount
            ? SnackBarAction(
                label: 'Retry Failed',
                textColor: Colors.white,
                onPressed: _retryFailedUploads,
              )
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveConfig(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              OverallProgressHeader(
                uploadQueue: _uploadQueue,
                selectedUser: widget.selectedUser,
                responsive: responsive,
              ),

              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: _uploadQueue.length,
                  itemBuilder: (context, index) {
                    return UploadQueueItem(
                      item: _uploadQueue[index],
                      responsive: responsive,
                    );
                  },
                ),
              ),

              _buildBottomControls(responsive),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomControls(ResponsiveConfig responsive) {
    final hasFailedUploads = _uploadQueue.any((item) => item.status == UploadStatus.failed);
    final hasPendingUploads = _uploadQueue.any((item) => item.status == UploadStatus.pending);
    final isAllCompleted = _uploadQueue.every((item) =>
        item.status == UploadStatus.completed ||
        item.status == UploadStatus.failed ||
        item.status == UploadStatus.cancelled);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (hasFailedUploads) ...[
            TextButton.icon(
              onPressed: _retryFailedUploads,
              icon: Icon(
                Icons.refresh,
                size: 18.sp,
              ),
              label: Text(
                'Retry Failed',
                style: TextStyle(fontSize: responsive.bodyFontSize),
              ),
            ),
            SizedBox(width: 16.w),
          ],

          if (_isUploading) ...[
            TextButton.icon(
              onPressed: _cancelUpload,
              icon: Icon(
                Icons.cancel,
                size: 18.sp,
              ),
              label: Text(
                'Cancel',
                style: TextStyle(fontSize: responsive.bodyFontSize),
              ),
            ),
            SizedBox(width: 16.w),
          ],

          Expanded(
            child: Row(
              children: [
                if (hasPendingUploads && !_isUploading) ...[
                  CustomButton(
                    onPressed: _startUpload,
                    text: 'Start Upload',
                    leadingIcon: const Icon(Icons.upload),
                    minimumSize: Size(140.w, 48.h),
                  ),
                  SizedBox(width: 16.w),
                ],
                CustomButton(
                  onPressed: () => Navigator.of(context).pop(),
                  text: isAllCompleted ? 'Done' : 'Close',
                  minimumSize: Size(120.w, 48.h),
                  isOutlined: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
