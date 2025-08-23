import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/user_model.dart';
import '../../models/upload_model.dart';
import '../../services/upload_service.dart';
import '../../utils/responsive_config.dart';
import '../common/custom_button.dart';

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

    // Process uploads sequentially
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

        // Small delay between uploads for better UX
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

    // Notify parent when all uploads are complete
    if (widget.onUploadComplete != null) {
      widget.onUploadComplete!(_completedUploads);
    }

    // Show completion message
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
              // Header
              _buildHeader(responsive),

              // Upload queue
              Expanded(
                child: _buildUploadQueue(responsive),
              ),

              // Bottom controls
              _buildBottomControls(responsive),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ResponsiveConfig responsive) {
    final totalFiles = _uploadQueue.length;
    final completedFiles = _uploadQueue
        .where((item) => item.status == UploadStatus.completed)
        .length;
    final failedFiles = _uploadQueue
        .where((item) => item.status == UploadStatus.failed)
        .length;
    final uploadingFiles = _uploadQueue
        .where((item) => item.status == UploadStatus.uploading)
        .length;

    final overallProgress = totalFiles > 0
        ? _uploadQueue.fold<double>(0, (sum, item) => sum + item.progress) / totalFiles
        : 0.0;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // User info and progress
          Row(
            children: [
              if (widget.selectedUser != null)
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24.r,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          widget.selectedUser!.displayName.isNotEmpty
                              ? widget.selectedUser!.displayName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Uploading to: ${widget.selectedUser!.displayName}',
                              style: TextStyle(
                                fontSize: responsive.bodyFontSize,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (widget.selectedUser!.department != null)
                              Text(
                                widget.selectedUser!.department!,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

              // Progress summary
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Text(
                      '$completedFiles/$totalFiles',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Completed',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Overall progress bar
          LinearProgressIndicator(
            value: overallProgress,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(overallProgress, failedFiles > 0),
            ),
          ),

          SizedBox(height: 8.h),

          // Status indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatusIndicator(
                'Pending',
                _uploadQueue.where((item) => item.status == UploadStatus.pending).length,
                Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              _buildStatusIndicator(
                'Uploading',
                uploadingFiles,
                Theme.of(context).colorScheme.primary,
              ),
              _buildStatusIndicator(
                'Completed',
                completedFiles,
                Colors.green,
              ),
              _buildStatusIndicator(
                'Failed',
                failedFiles,
                Theme.of(context).colorScheme.error,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          '$label: $count',
          style: TextStyle(
            fontSize: 10.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadQueue(ResponsiveConfig responsive) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: _uploadQueue.length,
      itemBuilder: (context, index) {
        return _buildUploadItem(_uploadQueue[index], responsive);
      },
    );
  }

  Widget _buildUploadItem(UploadItem item, ResponsiveConfig responsive) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // File info and status
            Row(
              children: [
                // File icon
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: _getStatusColor(item.status).withAlpha((255 * 0.1).round()),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    _getFileIcon(item.file.extension),
                    color: _getStatusColor(item.status),
                    size: 24.sp,
                  ),
                ),

                SizedBox(width: 12.w),

                // File details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.file.name,
                        style: TextStyle(
                          fontSize: responsive.bodyFontSize,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        _formatFileSize(item.file.size),
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Status icon
                _buildStatusIcon(item),
              ],
            ),

            SizedBox(height: 12.h),

            // Progress bar
            LinearProgressIndicator(
              value: item.status == UploadStatus.uploading ? item.progress : null,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(item.status),
              ),
            ),

            SizedBox(height: 8.h),

            // Progress text
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _getStatusText(item),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (item.status == UploadStatus.uploading)
                  Text(
                    '${(item.progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),

            // Error message
            if (item.errorMessage != null) ...[
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  item.errorMessage!,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(UploadItem item) {
    switch (item.status) {
      case UploadStatus.pending:
        return Icon(
          Icons.schedule,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 20.sp,
        );
      case UploadStatus.uploading:
        return SizedBox(
          width: 20.w,
          height: 20.h,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),
        );
      case UploadStatus.completed:
        return Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 20.sp,
        );
      case UploadStatus.failed:
        return Icon(
          Icons.error,
          color: Theme.of(context).colorScheme.error,
          size: 20.sp,
        );
      case UploadStatus.cancelled:
        return Icon(
          Icons.cancel,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 20.sp,
        );
    }
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

  Color _getStatusColor(UploadStatus status) {
    switch (status) {
      case UploadStatus.pending:
        return Theme.of(context).colorScheme.onSurfaceVariant;
      case UploadStatus.uploading:
        return Theme.of(context).colorScheme.primary;
      case UploadStatus.completed:
        return Colors.green;
      case UploadStatus.failed:
        return Theme.of(context).colorScheme.error;
      case UploadStatus.cancelled:
        return Theme.of(context).colorScheme.onSurfaceVariant;
    }
  }

  Color _getProgressColor(double progress, bool hasErrors) {
    if (hasErrors) return Colors.orange;
    if (progress == 1.0) return Colors.green;
    return Theme.of(context).colorScheme.primary;
  }

  IconData _getFileIcon(String? extension) {
    if (extension == null) return Icons.insert_drive_file;

    final ext = extension.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'].contains(ext)) {
      return Icons.image;
    } else if (['pdf'].contains(ext)) {
      return Icons.picture_as_pdf;
    } else if (['doc', 'docx'].contains(ext)) {
      return Icons.description;
    } else {
      return Icons.insert_drive_file;
    }
  }

  String _getStatusText(UploadItem item) {
    switch (item.status) {
      case UploadStatus.pending:
        return 'Waiting to upload';
      case UploadStatus.uploading:
        return 'Uploading...';
      case UploadStatus.completed:
        return 'Upload completed';
      case UploadStatus.failed:
        return 'Upload failed';
      case UploadStatus.cancelled:
        return 'Upload cancelled';
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

enum UploadStatus {
  pending,
  uploading,
  completed,
  failed,
  cancelled,
}

class UploadItem {
  final PlatformFile file;
  final UserModel? user;
  UploadStatus status;
  double progress;
  UploadResult? result;
  String? errorMessage;

  UploadItem({
    required this.file,
    this.user,
    required this.status,
    required this.progress,
    this.result,
    this.errorMessage,
  });
}