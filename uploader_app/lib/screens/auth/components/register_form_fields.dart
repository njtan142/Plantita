import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:form_field_validator/form_field_validator.dart';
import '../../../widgets/common/custom_text_field.dart';

class RegisterFormFields extends StatelessWidget {
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePassword;
  final VoidCallback onToggleConfirmPassword;

  const RegisterFormFields({
    super.key,
    required this.firstNameController,
    required this.lastNameController,
    required this.usernameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePassword,
    required this.onToggleConfirmPassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: firstNameController,
                label: 'First Name',
                hint: 'Enter first name',
                prefixIcon: Icons.person,
                validator: RequiredValidator(
                  errorText: 'First name is required',
                ).call,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: CustomTextField(
                controller: lastNameController,
                label: 'Last Name',
                hint: 'Enter last name',
                prefixIcon: Icons.person,
                validator: RequiredValidator(
                  errorText: 'Last name is required',
                ).call,
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        CustomTextField(
          controller: usernameController,
          label: 'Username',
          hint: 'Choose a username',
          prefixIcon: Icons.account_circle,
          validator: MultiValidator([
            RequiredValidator(errorText: 'Username is required'),
            MinLengthValidator(3, errorText: 'Username must be at least 3 characters'),
          ]).call,
        ),
        SizedBox(height: 24.h),
        CustomTextField(
          controller: emailController,
          label: 'Email',
          hint: 'Enter your email address',
          prefixIcon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: MultiValidator([
            RequiredValidator(errorText: 'Email is required'),
            EmailValidator(errorText: 'Enter a valid email address'),
          ]).call,
        ),
        SizedBox(height: 24.h),
        CustomTextField(
          controller: passwordController,
          label: 'Password',
          hint: 'Create a strong password',
          prefixIcon: Icons.lock,
          obscureText: obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              obscurePassword ? Icons.visibility : Icons.visibility_off,
              size: 20.sp,
            ),
            onPressed: onTogglePassword,
          ),
          validator: MultiValidator([
            RequiredValidator(errorText: 'Password is required'),
            MinLengthValidator(8, errorText: 'Password must be at least 8 characters'),
            PatternValidator(
              r'(?=.*[a-z])(?=.*[A-Z])(?=.*\d)',
              errorText: 'Password must contain uppercase, lowercase, and number',
            ),
          ]).call,
        ),
        SizedBox(height: 24.h),
        CustomTextField(
          controller: confirmPasswordController,
          label: 'Confirm Password',
          hint: 'Re-enter your password',
          prefixIcon: Icons.lock_outline,
          obscureText: obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
              size: 20.sp,
            ),
            onPressed: onToggleConfirmPassword,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }
}
