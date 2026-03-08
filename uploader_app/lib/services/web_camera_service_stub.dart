// Stub implementation for when no platform is matched
// This should not be used in practice - platform-specific implementations should be provided

import 'dart:typed_data';

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

/// Web Camera Service interface
abstract class WebCameraService {
  static const String _videoElementId = 'camera-preview';

  /// Stream of current camera device changes
  Stream<CameraDevice?> get deviceStream;

  /// Stream of streaming state changes
  Stream<bool> get streamingStream;

  /// Current camera device
  CameraDevice? get currentDevice;

  /// Check if camera is currently streaming
  bool get isStreaming;

  /// Check if service is initialized
  bool get isInitialized;

  /// Initialize the camera service
  Future<void> initialize();

  /// Get available camera devices
  Future<List<CameraDevice>> getAvailableCameras();

  /// Start camera stream with specific device
  Future<void> startStream([CameraDevice? device]);

  /// Stop camera stream
  Future<void> stopStream();

  /// Capture photo from current stream
  Future<CameraCapture> capturePhoto({
    double quality = 0.8,
    int? maxWidth,
    int? maxHeight,
  });

  /// Get video element for web preview (returns widget key for Flutter)
  String getPreviewElementId();

  /// Get camera controller for mobile preview
  dynamic getMobileCameraController();

  /// Check camera permissions
  Future<bool> checkPermissions();

  /// Request camera permissions
  Future<bool> requestPermissions();

  /// Dispose camera service and clean up resources
  Future<void> dispose();
}

/// Custom exception for camera-related errors
class CameraException implements Exception {
  final String message;
  const CameraException(this.message);

  @override
  String toString() => message;
}