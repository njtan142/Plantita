import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

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

  /// Start camera stream with specific device
  Future<void> startStream([CameraDevice? device]) async {
    if (!_isInitialized) {
      throw CameraException('Camera service not initialized');
    }

    if (_isStreaming) {
      await stopStream();
    }

    try {
      final constraints = {
        'video': device != null
            ? {'deviceId': {'exact': device.deviceId}}
            : {'facingMode': 'user'}
      };

      _mediaStream = await html.window.navigator.mediaDevices!.getUserMedia(constraints);
      _videoElement!.srcObject = _mediaStream;

      // Wait for video to be ready
      await _videoElement!.onLoadedMetadata.first;

      _isStreaming = true;
      _currentDevice = device;
      _deviceController.add(device);
      _streamingController.add(true);
    } catch (e) {
      throw CameraException('Failed to access camera: $e');
    }
  }

  /// Stop camera stream
  Future<void> stopStream() async {
    if (!_isStreaming) return;

    try {
      if (_mediaStream != null) {
        _mediaStream!.getTracks().forEach((track) => track.stop());
        _mediaStream = null;
      }

      if (_videoElement != null) {
        _videoElement!.srcObject = null;
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

  /// Get video element for web preview (returns widget key for Flutter)
  String getPreviewElementId() {
    if (!kIsWeb) {
      throw CameraException('Video element ID only available on web');
    }
    return _videoElementId;
  }

  /// Get camera controller for mobile preview (not available on web)
  dynamic getMobileCameraController() {
    if (kIsWeb) {
      throw CameraException('Camera controller only available on mobile');
    }
    return null;
  }

  /// Check camera permissions
  Future<bool> checkPermissions() async {
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

  /// Request camera permissions
  Future<bool> requestPermissions() async {
    try {
      await html.window.navigator.mediaDevices!.getUserMedia({'video': true});
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Dispose camera service and clean up resources
  Future<void> dispose() async {
    await stopStream();

    _videoElement = null;
    _canvasElement = null;
    _canvasContext = null;

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