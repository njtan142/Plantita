import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/user_model.dart';
import '../../../utils/responsive_config.dart';

class FilePickerHeader extends StatelessWidget {
  final UserModel? selectedUser;
  final int selectedFilesCount;
  final int maxFiles;
  final ResponsiveConfig responsive;

  const FilePickerHeader({
    super.key,
    this.selectedUser,
    required this.selectedFilesCount,
    required this.maxFiles,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Row(
        children: [
          if (selectedUser != null)
            Expanded(
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20.r,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    child: Text(
                      selectedUser!.displayName.isNotEmpty
                          ? selectedUser!.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedUser!.displayName,
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
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: selectedFilesCount >= maxFiles
                  ? Theme.of(context).colorScheme.errorContainer
                  : Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              '$selectedFilesCount/$maxFiles',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: selectedFilesCount >= maxFiles
                    ? Theme.of(context).colorScheme.error
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
