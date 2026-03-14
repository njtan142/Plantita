import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/responsive_config.dart';
import '../../../widgets/common/custom_button.dart';

class ForgotPasswordSuccess extends StatelessWidget {
  final VoidCallback onBackToSignIn;
  final VoidCallback onResend;
  final ResponsiveConfig responsive;

  const ForgotPasswordSuccess({
    super.key,
    required this.onBackToSignIn,
    required this.onResend,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(
          Icons.mark_email_read,
          size: 64.sp,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: 24.h),
        Text(
          'Email Sent!',
          style: TextStyle(
            fontSize: responsive.headerFontSize,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 16.h),
        Text(
          'Please check your inbox and follow the instructions to reset your password.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: responsive.bodyFontSize,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 32.h),
        CustomButton(
          onPressed: onBackToSignIn,
          text: 'Back to Sign In',
          minimumSize: Size(double.infinity, 56.h),
        ),
        SizedBox(height: 16.h),
        TextButton(
          onPressed: onResend,
          style: TextButton.styleFrom(
            minimumSize: Size(44.w, 44.h),
          ),
          child: Text(
            'Resend Email',
            style: TextStyle(
              fontSize: responsive.bodyFontSize,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }
}
