import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:camera/camera.dart';
import '../../../models/user_model.dart';

class CameraOverlay extends StatelessWidget {
  final UserModel? selectedUser;
  final bool isFlashSupported;
  final FlashMode flashMode;
  final VoidCallback onToggleFlash;
  final VoidCallback onClose;

  const CameraOverlay({
    super.key,
    this.selectedUser,
    required this.isFlashSupported,
    required this.flashMode,
    required this.onToggleFlash,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Top bar
          Container(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Flash toggle
                if (isFlashSupported)
                  IconButton(
                    onPressed: onToggleFlash,
                    icon: Icon(
                      flashMode == FlashMode.torch
                          ? Icons.flash_on
                          : Icons.flash_off,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  )
                else
                  const SizedBox(),

                // Close button
                IconButton(
                  onPressed: onClose,
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),
              ],
            ),
          ),

          // Selected user info (if available)
          if (selectedUser != null)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha((255 * 0.7).round()),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16.r,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(
                      selectedUser!.displayName.isNotEmpty
                          ? selectedUser!.displayName[0].toUpperCase()
                          : '?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      selectedUser!.displayName,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const Spacer(),

          // Camera frame guide
          Container(
            margin: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withAlpha((255 * 0.3).round()),
                width: 2,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}
