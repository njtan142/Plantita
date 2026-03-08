import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:camera/camera.dart';

/// Camera device information
class CameraDevice {
  final String deviceId;
  final String label;
  final bool isFrontCamera;

  const CameraDevice({
    required this.deviceId,
    required this.label,
    this.isFrontCamera = false,
  });

  @override
  String toString() => label.isNotEmpty ? label : 'Camera $deviceId';
}

/// Camera capture result
class CameraCapture {
  final Uint8List imageData;
  final int width;
  final int height;
  final String mimeType;
  final DateTime capturedAt;

  const CameraCapture({
    required this.imageData,
    required this.width,
    required this.height,
    required this.mimeType,
    required this.capturedAt,
  });

  /// Get image size in bytes
  int get sizeInBytes => imageData.length;

  /// Get formatted file size
  String get formattedSize {
    const units = ['B', 'KB', 'MB', 'GB'];
    var size = sizeInBytes.toDouble();
    var unitIndex = 0;

    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }

    return '${size.toStringAsFixed(1)} ${units[unitIndex]}';
  }
}

/// Web Camera Service for mobile camera access and photo capture
class WebCameraService {
  static const String _videoElementId = 'camera-preview';

  // Mobile-specific properties
  CameraController? _cameraController;
  List<CameraDescription>? _availableCameras;

  // Service state
  bool _isInitialized = false;
  bool _isStreaming = false;
  CameraDevice? _currentDevice;
  final StreamController<CameraDevice?> _deviceController = StreamController<CameraDevice?>.broadcast();
  final StreamController<bool> _streamingController = StreamController<bool>.broadcast();

  /// Stream of current camera device changes
  Stream<CameraDevice?> get deviceStream => _deviceController.stream;

  /// Stream of streaming state changes
  Stream<bool> get streamingStream => _streamingController.stream;

  /// Current camera device
  CameraDevice? get currentDevice => _currentDevice;

  /// Check if camera is currently streaming
  bool get isStreaming => _isStreaming;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the camera service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      _availableCameras = await availableCameras();
      _isInitialized = true;
    } catch (e) {
      throw CameraException('Failed to initialize camera: $e');
    }
  }

  /// Get available camera devices
  Future<List<CameraDevice>> getAvailableCameras() async {
    if (!_isInitialized) {
      throw CameraException('Camera service not initialized');
    }

    if (_availableCameras == null) {
      throw CameraException('No cameras available');
    }

    return _availableCameras!
        .map((camera) => CameraDevice(
              deviceId: camera.name,
              label: camera.name,
              isFrontCamera: camera.lensDirection == CameraLensDirection.front,
            ))
        .toList();
  }

  /// Start camera stream with specific device
  Future<void> startStream([CameraDevice? device]) async {
    if (!_isInitialized) {
      throw CameraException('Camera service not initialized');
    }

    if (_isStreaming) {
      await stopStream();
    }

    try {
      if (_availableCameras == null || _availableCameras!.isEmpty) {
        throw CameraException('No cameras available');
      }

      final camera = device != null
          ? _availableCameras!.firstWhere((cam) => cam.name == device.deviceId)
          : _availableCameras!.first;

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      _isStreaming = true;
      _currentDevice = device;
      _deviceController.add(device);
      _streamingController.add(true);
    } catch (e) {
      throw CameraException('Failed to start camera stream: $e');
    }
  }

  /// Stop camera stream
  Future<void> stopStream() async {
    if (!_isStreaming) return;

    try {
      if (_cameraController != null) {
        await _cameraController!.dispose();
        _cameraController = null;
      }

      _isStreaming = false;
      _currentDevice = null;
      _deviceController.add(null);
      _streamingController.add(false);
    } catch (e) {
      // Continue with cleanup even if there's an error
    }
  }

  /// Capture photo from current stream
  Future<CameraCapture> capturePhoto({
    double quality = 0.8,
    int? maxWidth,
    int? maxHeight,
  }) async {
    if (!_isStreaming) {
      throw CameraException('Camera is not streaming');
    }

    if (_cameraController == null) {
      throw CameraException('Camera controller not initialized');
    }

    try {
      final file = await _cameraController!.takePicture();
      final bytes = await file.readAsBytes();

      return CameraCapture(
        imageData: bytes,
        width: maxWidth ?? 1920, // Default resolution
        height: maxHeight ?? 1080,
        mimeType: 'image/jpeg',
        capturedAt: DateTime.now(),
      );
    } catch (e) {
      throw CameraException('Failed to capture photo: $e');
    }
  }

  /// Get video element for web preview (not available on mobile)
  String getPreviewElementId() {
    if (!kIsWeb) {
      throw CameraException('Video element ID only available on web');
    }
    return _videoElementId;
  }

  /// Get camera controller for mobile preview
  CameraController? getMobileCameraController() {
    if (kIsWeb) {
      throw CameraException('Camera controller only available on mobile');
    }
    return _cameraController;
  }

  /// Check camera permissions
  Future<bool> checkPermissions() async {
    // On mobile, permissions are handled by the camera plugin
    // We'll check by trying to get available cameras
    try {
      _availableCameras ??= await availableCameras();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Request camera permissions
  Future<bool> requestPermissions() async {
    // On mobile, permissions are requested when initializing the camera
    return await checkPermissions();
  }

  /// Dispose camera service and clean up resources
  Future<void> dispose() async {
    await stopStream();

    _cameraController = null;
    _availableCameras = null;

    await _deviceController.close();
    await _streamingController.close();

    _isInitialized = false;
  }
}

/// Custom exception for camera-related errors
class CameraException implements Exception {
  final String message;
  const CameraException(this.message);

  @override
  String toString() => message;
}