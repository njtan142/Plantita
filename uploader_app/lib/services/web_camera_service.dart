import 'dart:async';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'dart:ui' as ui;

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

/// Web Camera Service for browser camera access and photo capture
class WebCameraService {
  static const String _videoElementId = 'camera-preview';

  // Web-specific properties
  html.MediaStream? _mediaStream;
  html.VideoElement? _videoElement;
  html.CanvasElement? _canvasElement;
  html.CanvasRenderingContext2D? _canvasContext;

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
      if (kIsWeb) {
        await _initializeWebCamera();
      } else {
        await _initializeMobileCamera();
      }
      _isInitialized = true;
    } catch (e) {
      throw CameraException('Failed to initialize camera: $e');
    }
  }

  /// Initialize web camera
  Future<void> _initializeWebCamera() async {
    // Check if mediaDevices API is available
    if (html.window.navigator.mediaDevices == null) {
      throw CameraException('Camera access not supported in this browser');
    }

    // Create video element for preview
    _videoElement = html.VideoElement()
      ..id = _videoElementId
      ..autoplay = true
      ..muted = true
      ..style.width = '100%'
      ..style.height = '100%';

    // Create canvas for image capture
    _canvasElement = html.CanvasElement();
    _canvasContext = _canvasElement!.context2D as html.CanvasRenderingContext2D?;
  }

  /// Initialize mobile camera
  Future<void> _initializeMobileCamera() async {
    try {
      _availableCameras = await availableCameras();
    } catch (e) {
      throw CameraException('Failed to get available cameras: $e');
    }
  }

  /// Get available camera devices
  Future<List<CameraDevice>> getAvailableCameras() async {
    if (!_isInitialized) {
      throw CameraException('Camera service not initialized');
    }

    if (kIsWeb) {
      return await _getWebCameraDevices();
    } else {
      return await _getMobileCameraDevices();
    }
  }

  /// Get web camera devices
  Future<List<CameraDevice>> _getWebCameraDevices() async {
    try {
      final devices = await html.window.navigator.mediaDevices!.enumerateDevices();
      final videoDevices = devices
          .where((device) => device.kind == 'videoinput')
          .map((device) => CameraDevice(
                deviceId: device.deviceId!,
                label: device.label ?? 'Camera ${device.deviceId}',
                isFrontCamera: device.label?.toLowerCase().contains('front') ?? false,
              ))
          .toList();

      return videoDevices;
    } catch (e) {
      throw CameraException('Failed to enumerate camera devices: $e');
    }
  }

  /// Get mobile camera devices
  Future<List<CameraDevice>> _getMobileCameraDevices() async {
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
      if (kIsWeb) {
        await _startWebStream(device);
      } else {
        await _startMobileStream(device);
      }

      _isStreaming = true;
      _currentDevice = device;
      _deviceController.add(device);
      _streamingController.add(true);
    } catch (e) {
      throw CameraException('Failed to start camera stream: $e');
    }
  }

  /// Start web camera stream
  Future<void> _startWebStream([CameraDevice? device]) async {
    final constraints = {
      'video': device != null
          ? {'deviceId': {'exact': device.deviceId}}
          : {'facingMode': 'user'}
    };

    try {
      _mediaStream = await html.window.navigator.mediaDevices!.getUserMedia(constraints);
      _videoElement!.srcObject = _mediaStream;

      // Wait for video to be ready
      await _videoElement!.onLoadedMetadata.first;
    } catch (e) {
      throw CameraException('Failed to access camera: $e');
    }
  }

  /// Start mobile camera stream
  Future<void> _startMobileStream([CameraDevice? device]) async {
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
  }

  /// Stop camera stream
  Future<void> stopStream() async {
    if (!_isStreaming) return;

    try {
      if (kIsWeb) {
        await _stopWebStream();
      } else {
        await _stopMobileStream();
      }

      _isStreaming = false;
      _currentDevice = null;
      _deviceController.add(null);
      _streamingController.add(false);
    } catch (e) {
      // Continue with cleanup even if there's an error
    }
  }

  /// Stop web camera stream
  Future<void> _stopWebStream() async {
    if (_mediaStream != null) {
      _mediaStream!.getTracks().forEach((track) => track.stop());
      _mediaStream = null;
    }

    if (_videoElement != null) {
      _videoElement!.srcObject = null;
    }
  }

  /// Stop mobile camera stream
  Future<void> _stopMobileStream() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
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

    if (kIsWeb) {
      return await _captureWebPhoto(quality: quality, maxWidth: maxWidth, maxHeight: maxHeight);
    } else {
      return await _captureMobilePhoto(quality: quality, maxWidth: maxWidth, maxHeight: maxHeight);
    }
  }

  /// Capture photo on web
  Future<CameraCapture> _captureWebPhoto({
    double quality = 0.8,
    int? maxWidth,
    int? maxHeight,
  }) async {
    if (_videoElement == null || _canvasElement == null || _canvasContext == null) {
      throw CameraException('Camera elements not initialized');
    }

    final videoWidth = _videoElement!.videoWidth!;
    final videoHeight = _videoElement!.videoHeight!;

    // Calculate dimensions
    int targetWidth = maxWidth ?? videoWidth;
    int targetHeight = maxHeight ?? videoHeight;

    // Maintain aspect ratio
    if (maxWidth != null && maxHeight != null) {
      final aspectRatio = videoWidth / videoHeight;
      if (targetWidth / targetHeight > aspectRatio) {
        targetWidth = (targetHeight * aspectRatio).round();
      } else {
        targetHeight = (targetWidth / aspectRatio).round();
      }
    }

    // Set canvas size
    _canvasElement!.width = targetWidth;
    _canvasElement!.height = targetHeight;

    // Draw current video frame to canvas
    _canvasContext!.drawImageScaled(
      _videoElement!,
      0,
      0,
      targetWidth.toDouble(),
      targetHeight.toDouble(),
    );

    // Convert to blob
    final blob = await _canvasElement!.toBlob('image/jpeg', quality);
    final reader = html.FileReader();
    reader.readAsArrayBuffer(blob);

    await reader.onLoadEnd.first;
    final uint8List = reader.result as Uint8List;

    return CameraCapture(
      imageData: uint8List,
      width: targetWidth,
      height: targetHeight,
      mimeType: 'image/jpeg',
      capturedAt: DateTime.now(),
    );
  }

  /// Capture photo on mobile
  Future<CameraCapture> _captureMobilePhoto({
    double quality = 0.8,
    int? maxWidth,
    int? maxHeight,
  }) async {
    if (_cameraController == null) {
      throw CameraException('Camera controller not initialized');
    }

    final file = await _cameraController!.takePicture();
    final bytes = await file.readAsBytes();

    return CameraCapture(
      imageData: bytes,
      width: maxWidth ?? 1920, // Default resolution
      height: maxHeight ?? 1080,
      mimeType: 'image/jpeg',
      capturedAt: DateTime.now(),
    );
  }

  /// Get video element for web preview (returns widget key for Flutter)
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
    if (kIsWeb) {
      return await _checkWebPermissions();
    } else {
      return await _checkMobilePermissions();
    }
  }

  /// Check web permissions
  Future<bool> _checkWebPermissions() async {
    try {
      if (html.window.navigator.permissions == null) {
        return true; // Assume granted if permissions API not available
      }

      final permission = await html.window.navigator.permissions!.query({'name': 'camera'});
      return permission.state == 'granted';
    } catch (e) {
      return false;
    }
  }

  /// Check mobile permissions
  Future<bool> _checkMobilePermissions() async {
    // On mobile, permissions are handled by the camera plugin
    // We'll check by trying to initialize the camera
    try {
      if (_availableCameras == null) {
        _availableCameras = await availableCameras();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Request camera permissions
  Future<bool> requestPermissions() async {
    if (kIsWeb) {
      return await _requestWebPermissions();
    } else {
      return await _requestMobilePermissions();
    }
  }

  /// Request web permissions
  Future<bool> _requestWebPermissions() async {
    try {
      await html.window.navigator.mediaDevices!.getUserMedia({'video': true});
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Request mobile permissions
  Future<bool> _requestMobilePermissions() async {
    // On mobile, permissions are requested when initializing the camera
    return await checkPermissions();
  }

  /// Dispose camera service and clean up resources
  Future<void> dispose() async {
    await stopStream();

    if (kIsWeb) {
      _videoElement = null;
      _canvasElement = null;
      _canvasContext = null;
    } else {
      _cameraController = null;
      _availableCameras = null;
    }

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