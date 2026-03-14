import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../models/user_model.dart';
import '../../../utils/responsive_config.dart';

class UserSuggestionItem extends StatelessWidget {
  final UserModel user;
  final ResponsiveConfig responsive;

  const UserSuggestionItem({
    super.key,
    required this.user,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              user.displayName.isNotEmpty
                  ? user.displayName[0].toUpperCase()
                  : '?',
              style: TextStyle(
                color: theme.colorScheme.onPrimaryContainer,
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
                if (user.department != null && user.department!.isNotEmpty)
                  Text(
                    user.department!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          if (user.employeeId != null && user.employeeId!.isNotEmpty)
            Text(
              '#${user.employeeId}',
              style: TextStyle(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
