import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class CameraControls extends StatelessWidget {
  final bool isCapturing;
  final bool hasMultipleCameras;
  final Animation<double> captureAnimation;
  final VoidCallback onPickFromGallery;
  final VoidCallback onCapture;
  final VoidCallback onSwitchCamera;

  const CameraControls({
    super.key,
    required this.isCapturing,
    required this.hasMultipleCameras,
    required this.captureAnimation,
    required this.onPickFromGallery,
    required this.onCapture,
    required this.onSwitchCamera,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bottom controls
          Container(
            padding: EdgeInsets.all(32.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery button
                IconButton(
                  onPressed: onPickFromGallery,
                  icon: Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),

                // Capture button
                GestureDetector(
                  onTap: isCapturing ? null : onCapture,
                  child: AnimatedBuilder(
                    animation: captureAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: isCapturing ? 1.2 : captureAnimation.value,
                        child: Container(
                          width: 80.w,
                          height: 80.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all( 
                              color: Colors.white.withAlpha((255 * 0.3).round()),
                              width: 4,
                            ),
                          ),
                          child: isCapturing
                              ? SpinKitCircle(
                                  color: Colors.black,
                                  size: 30.sp,
                                )
                              : const SizedBox(),
                        ),
                      );
                    },
                  ),
                ),

                // Switch camera button
                if (hasMultipleCameras)
                  IconButton(
                    onPressed: onSwitchCamera,
                    icon: Icon(
                      Icons.cameraswitch,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  )
                else
                  const SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
