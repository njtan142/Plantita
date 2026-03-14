import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../upload_types.dart';
import '../../../utils/responsive_config.dart';

class UploadQueueItem extends StatelessWidget {
  final UploadItem item;
  final ResponsiveConfig responsive;

  const UploadQueueItem({
    super.key,
    required this.item,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
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
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: _getStatusColor(context, item.status).withAlpha((255 * 0.1).round()),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    _getFileIcon(item.file.extension),
                    color: _getStatusColor(context, item.status),
                    size: 24.sp,
                  ),
                ),

                SizedBox(width: 12.w),

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

                _buildStatusIcon(context, item),
              ],
            ),

            SizedBox(height: 12.h),

            LinearProgressIndicator(
              value: item.status == UploadStatus.uploading ? item.progress : 
                     item.status == UploadStatus.completed ? 1.0 : 0.0,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getStatusColor(context, item.status),
              ),
            ),

            SizedBox(height: 8.h),

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

  Widget _buildStatusIcon(BuildContext context, UploadItem item) {
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

  Color _getStatusColor(BuildContext context, UploadStatus status) {
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
