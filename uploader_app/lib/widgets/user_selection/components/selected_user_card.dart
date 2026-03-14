import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/user_model.dart';
import '../../../utils/responsive_config.dart';

class SelectedUserCard extends StatelessWidget {
  final UserModel user;
  final ResponsiveConfig responsive;

  const SelectedUserCard({
    super.key,
    required this.user,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.only(top: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withAlpha((255 * 0.3).round()),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: theme.colorScheme.primaryContainer,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              user.displayName.isNotEmpty
                  ? user.displayName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
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
                  user.displayName,
                  style: TextStyle(
                    fontSize: responsive.bodyFontSize,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (user.email.isNotEmpty)
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (user.department != null &&
                    user.department!.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: 12.sp,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        user.department!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (user.employeeId != null &&
              user.employeeId!.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 4.h,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Text(
                user.employeeId!,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
