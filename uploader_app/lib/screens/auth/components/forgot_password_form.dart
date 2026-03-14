import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../../../utils/responsive_config.dart';
import '../../../widgets/common/custom_button.dart';
import '../../../widgets/common/custom_text_field.dart';

class ForgotPasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onReset;
  final VoidCallback onBackToSignIn;
  final ResponsiveConfig responsive;

  const ForgotPasswordForm({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    this.errorMessage,
    required this.onReset,
    required this.onBackToSignIn,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Forgot Password?',
            style: TextStyle(
              fontSize: responsive.headerFontSize,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No worries! Enter your email and we\'ll help you reset it.',
            style: TextStyle(
              fontSize: responsive.bodyFontSize,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),

          SizedBox(height: 32.h),

          if (errorMessage != null)
            Container(
              padding: EdgeInsets.all(16.w),
              margin: EdgeInsets.only(bottom: 24.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: Theme.of(context).colorScheme.error,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: responsive.bodyFontSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          CustomTextField(
            controller: emailController,
            label: 'Email Address',
            hint: 'Enter your registered email',
            prefixIcon: Icons.email,
            keyboardType: TextInputType.emailAddress,
            validator: MultiValidator([
              RequiredValidator(errorText: 'Email is required'),
              EmailValidator(errorText: 'Enter a valid email address'),
            ]).call,
          ),

          SizedBox(height: 32.h),

          CustomButton(
            onPressed: isLoading ? null : onReset,
            text: isLoading ? 'Sending...' : 'Send Reset Link',
            isLoading: isLoading,
            minimumSize: Size(double.infinity, 56.h),
          ),

          SizedBox(height: 24.h),

          Center(
            child: TextButton(
              onPressed: onBackToSignIn,
              style: TextButton.styleFrom(
                minimumSize: Size(44.w, 44.h),
              ),
              child: Text(
                'Back to Sign In',
                style: TextStyle(
                  fontSize: responsive.bodyFontSize,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
