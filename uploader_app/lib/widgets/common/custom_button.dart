import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CustomButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String text;
  final bool isLoading;
  final Size? minimumSize;
  final Color? backgroundColor;
  final Color? textColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final Widget? leadingIcon;
  final bool isOutlined;

  const CustomButton({
    super.key,
    this.onPressed,
    required this.text,
    this.isLoading = false,
    this.minimumSize,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.leadingIcon,
    this.isOutlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultMinSize = minimumSize ?? Size(double.infinity, 48.h);

    final buttonStyle = isOutlined
        ? OutlinedButton.styleFrom(
            minimumSize: defaultMinSize,
            backgroundColor: Colors.transparent,
            foregroundColor: backgroundColor ?? theme.colorScheme.primary,
            side: BorderSide(
              color: backgroundColor ?? theme.colorScheme.primary,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
            ),
            padding: padding ?? EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            elevation: 0,
          )
        : ElevatedButton.styleFrom(
            minimumSize: defaultMinSize,
            backgroundColor: backgroundColor ?? theme.colorScheme.primary,
            foregroundColor: textColor ?? theme.colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 12.r),
            ),
            padding: padding ?? EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            elevation: 2,
            shadowColor: (backgroundColor ?? theme.colorScheme.primary).withAlpha((255 * 0.3).round()),
          );

    final buttonChild = isLoading
        ? SizedBox(
            height: 20.h,
            width: 20.w,
            child: SpinKitThreeBounce(
              color: isOutlined
                  ? (backgroundColor ?? theme.colorScheme.primary)
                  : (textColor ?? theme.colorScheme.onPrimary),
              size: 20.sp,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (leadingIcon != null) ...[
                leadingIcon!,
                SizedBox(width: 8.w),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          );

    return isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: buttonStyle,
            child: buttonChild,
          );
  }
}