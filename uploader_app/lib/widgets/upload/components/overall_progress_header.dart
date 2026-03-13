import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../upload_types.dart';
import '../../models/user_model.dart';
import '../../utils/responsive_config.dart';

class OverallProgressHeader extends StatelessWidget {
  final List<UploadItem> uploadQueue;
  final UserModel? selectedUser;
  final ResponsiveConfig responsive;

  const OverallProgressHeader({
    super.key,
    required this.uploadQueue,
    this.selectedUser,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final totalFiles = uploadQueue.length;
    final completedFiles = uploadQueue
        .where((item) => item.status == UploadStatus.completed)
        .length;
    final failedFiles = uploadQueue
        .where((item) => item.status == UploadStatus.failed)
        .length;
    final uploadingFiles = uploadQueue
        .where((item) => item.status == UploadStatus.uploading)
        .length;

    final overallProgress = totalFiles > 0
        ? uploadQueue.fold<double>(0, (sum, item) => sum + item.progress) / totalFiles
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
          Row(
            children: [
              if (selectedUser != null)
                Expanded(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 24.r,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          selectedUser!.displayName.isNotEmpty
                              ? selectedUser!.displayName[0].toUpperCase()
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
                              'Uploading to: ${selectedUser!.displayName}',
                              style: TextStyle(
                                fontSize: responsive.bodyFontSize,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            if (selectedUser!.department != null)
                              Text(
                                selectedUser!.department!,
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

          LinearProgressIndicator(
            value: overallProgress,
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              _getProgressColor(context, overallProgress, failedFiles > 0),
            ),
          ),

          SizedBox(height: 8.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatusIndicator(
                context,
                'Pending',
                uploadQueue.where((item) => item.status == UploadStatus.pending).length,
                Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              _buildStatusIndicator(
                context,
                'Uploading',
                uploadingFiles,
                Theme.of(context).colorScheme.primary,
              ),
              _buildStatusIndicator(
                context,
                'Completed',
                Colors.green,
              ),
              _buildStatusIndicator(
                context,
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

  Widget _buildStatusIndicator(BuildContext context, String label, int count, Color color) {
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

  Color _getProgressColor(BuildContext context, double progress, bool hasErrors) {
    if (hasErrors) return Colors.orange;
    if (progress == 1.0) return Colors.green;
    return Theme.of(context).colorScheme.primary;
  }
}
