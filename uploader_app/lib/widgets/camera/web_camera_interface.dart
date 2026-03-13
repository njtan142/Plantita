import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../models/user_model.dart';
import '../../utils/responsive_config.dart';
import 'components/camera_overlay.dart';
import 'components/camera_controls.dart';
import 'components/image_preview_widget.dart';

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
  XFile? _capturedImage;
  Uint8List? _imageBytes;

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
      _captureAnimationController.forward().then((_) {
        _captureAnimationController.reverse();
      });

      final XFile image = await _cameraController!.takePicture();
      _capturedImage = image;
      _imageBytes = await image.readAsBytes();

      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }

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

        if (widget.onImageCaptured != null && _imageBytes != null) {
          widget.onImageCaptured!(_imageBytes!);
        }
      }
    } catch (e) {
      debugPrint('Error picking from gallery: $e');
      _showError('Failed to pick image from gallery');
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
    if (_capturedImage != null && _imageBytes != null) {
      return ImagePreviewWidget(
        imageBytes: _imageBytes!,
        onRetake: _retakePhoto,
        onUsePhoto: () {
          if (_imageBytes != null && widget.onImageCaptured != null) {
            widget.onImageCaptured!(_imageBytes!);
          }
          Navigator.of(context).pop();
        },
        onClose: () => Navigator.of(context).pop(),
        responsive: responsive,
      );
    }

    if (!_isCameraInitialized) {
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

    return Stack(
      fit: StackFit.expand,
      children: [
        if (_cameraController != null)
          CameraPreview(_cameraController!),

        CameraOverlay(
          selectedUser: widget.selectedUser,
          isFlashSupported: _isFlashSupported,
          flashMode: _flashMode,
          onToggleFlash: _toggleFlash,
          onClose: () => Navigator.of(context).pop(),
        ),

        CameraControls(
          isCapturing: _isCapturing,
          hasMultipleCameras: _cameras != null && _cameras!.length > 1,
          captureAnimation: _captureAnimation,
          onPickFromGallery: _pickFromGallery,
          onCapture: _capturePhoto,
          onSwitchCamera: _switchCamera,
        ),
      ],
    );
  }
}
