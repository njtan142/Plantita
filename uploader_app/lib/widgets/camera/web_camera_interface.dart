import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../models/user_model.dart';
import '../../utils/responsive_config.dart';
import '../common/custom_button.dart';

class WebCameraInterface extends StatefulWidget {
  final UserModel? selectedUser;
  final Function(Uint8List imageData)? onImageCaptured;

  const WebCameraInterface({
    super.key,
    this.selectedUser,
    this.onImageCaptured,
  });

  @override
  State<WebCameraInterface> createState() => _WebCameraInterfaceState();
}

class _WebCameraInterfaceState extends State<WebCameraInterface>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCapturing = false;
  final bool _isProcessing = false;
  XFile? _capturedImage;
  Uint8List? _imageBytes;

  // Camera settings
  FlashMode _flashMode = FlashMode.off;
  bool _isFlashSupported = false;

  late AnimationController _captureAnimationController;
  late Animation<double> _captureAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeCamera();
  }

  void _setupAnimations() {
    _captureAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _captureAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _captureAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _captureAnimationController.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        await _setupCameraController(_cameras!.first);
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      _showError('Camera initialization failed');
    }
  }

  Future<void> _setupCameraController(CameraDescription camera) async {
    try {
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      // Check flash support
      _isFlashSupported = _cameraController!.value.flashMode != null;

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error setting up camera controller: $e');
      _showError('Camera setup failed');
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showError('Camera not ready');
      return;
    }

    if (_isCapturing) return;

    setState(() {
      _isCapturing = true;
    });

    try {
      // Animate capture
      _captureAnimationController.forward().then((_) {
        _captureAnimationController.reverse();
      });

      // Capture image
      final XFile image = await _cameraController!.takePicture();
      _capturedImage = image;

      // Convert to bytes
      _imageBytes = await image.readAsBytes();

      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }

      // Notify parent
      if (widget.onImageCaptured != null && _imageBytes != null) {
        widget.onImageCaptured!(_imageBytes!);
      }
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      _showError('Failed to capture photo');
      setState(() {
        _isCapturing = false;
      });
    }
  }

  Future<void> _toggleFlash() async {
    if (!_isFlashSupported || _cameraController == null) return;

    try {
      final newFlashMode = _flashMode == FlashMode.off
          ? FlashMode.torch
          : FlashMode.off;

      await _cameraController!.setFlashMode(newFlashMode);

      setState(() {
        _flashMode = newFlashMode;
      });
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  Future<void> _switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) return;

    try {
      final currentCamera = _cameraController!.description;
      final newCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection != currentCamera.lensDirection,
      );

      await _setupCameraController(newCamera);
    } catch (e) {
      debugPrint('Error switching camera: $e');
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImage = null;
      _imageBytes = null;
    });
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveConfig(context);

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black,
      child: _buildCameraContent(responsive),
    );
  }

  Widget _buildCameraContent(ResponsiveConfig responsive) {
    if (_capturedImage != null) {
      return _buildImagePreview(responsive);
    }

    if (!_isCameraInitialized) {
      return _buildLoadingState(responsive);
    }

    return _buildCameraPreview(responsive);
  }

  Widget _buildLoadingState(ResponsiveConfig responsive) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpinKitCircle(
            color: Colors.white,
            size: 50.sp,
          ),
          SizedBox(height: 20.h),
          Text(
            'Initializing camera...',
            style: TextStyle(
              color: Colors.white,
              fontSize: responsive.bodyFontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraPreview(ResponsiveConfig responsive) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Camera preview
        if (_cameraController != null)
          CameraPreview(_cameraController!),

        // Camera overlay
        _buildCameraOverlay(responsive),

        // Camera controls
        _buildCameraControls(responsive),
      ],
    );
  }

  Widget _buildCameraOverlay(ResponsiveConfig responsive) {
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
                if (_isFlashSupported)
                  IconButton(
                    onPressed: _toggleFlash,
                    icon: Icon(
                      _flashMode == FlashMode.torch
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
                  onPressed: () => Navigator.of(context).pop(),
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
          if (widget.selectedUser != null)
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
                      widget.selectedUser!.displayName.isNotEmpty
                          ? widget.selectedUser!.displayName[0].toUpperCase()
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
                      widget.selectedUser!.displayName,
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

  Widget _buildCameraControls(ResponsiveConfig responsive) {
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
                  onPressed: _pickFromGallery,
                  icon: Icon(
                    Icons.photo_library,
                    color: Colors.white,
                    size: 28.sp,
                  ),
                ),

                // Capture button
                GestureDetector(
                  onTap: _isCapturing ? null : _capturePhoto,
                  child: AnimatedBuilder(
                    animation: _captureAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _isCapturing ? 1.2 : _captureAnimation.value,
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
                          child: _isCapturing
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
                if (_cameras != null && _cameras!.length > 1)
                  IconButton(
                    onPressed: _switchCamera,
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

  Widget _buildImagePreview(ResponsiveConfig responsive) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Image preview
        if (_imageBytes != null)
          Image.memory(
            _imageBytes!,
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
                      onPressed: _retakePhoto,
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
                      onPressed: () => Navigator.of(context).pop(),
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
                      onPressed: _retakePhoto,
                      text: 'Retake',
                      backgroundColor: Colors.transparent,
                      textColor: Colors.white,
                      borderRadius: 8.r,
                      isOutlined: true,
                    ),
                    CustomButton(
                      onPressed: () {
                        if (_imageBytes != null && widget.onImageCaptured != null) {
                          widget.onImageCaptured!(_imageBytes!);
                        }
                        Navigator.of(context).pop();
                      },
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

  Future<void> _pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        _capturedImage = image;
        _imageBytes = await image.readAsBytes();

        if (mounted) {
          setState(() {});
        }

        // Notify parent
        if (widget.onImageCaptured != null && _imageBytes != null) {
          widget.onImageCaptured!(_imageBytes!);
        }
      }
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
      _showError('Failed to pick image from gallery');
    }
  }
}