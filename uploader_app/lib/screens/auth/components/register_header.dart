import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/responsive_config.dart';

class RegisterHeader extends StatelessWidget {
  final ResponsiveConfig responsive;

  const RegisterHeader({
    super.key,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40.h),
        Icon(
          Icons.person_add,
          size: responsive.iconSize * 2,
          color: Colors.white,
        ),
        SizedBox(height: 16.h),
        Text(
          'Create Account',
          style: TextStyle(
            fontSize: responsive.titleFontSize * 0.8,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Join Plantita Media Management',
          style: TextStyle(
            fontSize: responsive.subtitleFontSize,
            color: Colors.white.withAlpha((255 * 0.9).round()),
          ),
        ),
        SizedBox(height: 40.h),
      ],
    );
  }
}
