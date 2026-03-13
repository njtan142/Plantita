import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/responsive_config.dart';
import '../../common/custom_button.dart';

class ImagePreviewWidget extends StatelessWidget {
  final Uint8List imageBytes;
  final VoidCallback onRetake;
  final VoidCallback onUsePhoto;
  final VoidCallback onClose;
  final ResponsiveConfig responsive;

  const ImagePreviewWidget({
    super.key,
    required this.imageBytes,
    required this.onRetake,
    required this.onUsePhoto,
    required this.onClose,
    required this.responsive,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image preview
        Image.memory(
          imageBytes,
          fit: BoxFit.cover,
        ),

        // Preview overlay
        SafeArea(
          child: Column(
            children: [
              // Top bar
              Container(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: onRetake,
                      icon: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                      label: Text(
                        'Retake',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: responsive.bodyFontSize,
                        ),
                      ),
                    ),
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

              const Spacer(),

              // Bottom controls
              Container(
                padding: EdgeInsets.all(32.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CustomButton(
                      onPressed: onRetake,
                      text: 'Retake',
                      backgroundColor: Colors.transparent,
                      textColor: Colors.white,
                      borderRadius: 8.r,
                      isOutlined: true,
                    ),
                    CustomButton(
                      onPressed: onUsePhoto,
                      text: 'Use Photo',
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      textColor: Colors.white,
                      borderRadius: 8.r,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
