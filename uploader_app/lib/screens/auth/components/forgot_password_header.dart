import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/responsive_config.dart';

class ForgotPasswordHeader extends StatelessWidget {
  final bool emailSent;
  final String email;
  final ResponsiveConfig responsive;

  const ForgotPasswordHeader({
    super.key,
    required this.emailSent,
    required this.email,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 60.h),
        Icon(
          emailSent ? Icons.check_circle : Icons.lock_reset,
          size: responsive.iconSize * 3,
          color: Colors.white,
        ),
        SizedBox(height: 20.h),
        Text(
          emailSent ? 'Check Your Email' : 'Reset Password',
          style: TextStyle(
            fontSize: responsive.titleFontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          emailSent
              ? 'We\'ve sent a password reset link to\n$email'
              : 'Enter your email address and we\'ll send you\na link to reset your password',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: responsive.subtitleFontSize,
            color: Colors.white.withAlpha((255 * 0.9).round()),
          ),
        ),
        SizedBox(height: 60.h),
      ],
    );
  }
}
