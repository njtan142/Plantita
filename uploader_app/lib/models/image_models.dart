import 'dart:typed_data';

/// Image quality settings
enum ImageQuality {
  low,
  medium,
  high,
  original,
}

/// Image format options
enum ImageFormat {
  auto,
  jpeg,
  png,
  webp,
}

/// Optimized image result
class OptimizedImage {
  final Uint8List originalBytes;
  final Uint8List optimizedBytes;
  final int originalSize;
  final int optimizedSize;
  final int width;
  final int height;
  final ImageFormat format;
  final Duration processingTime;

  const OptimizedImage({
    required this.originalBytes,
    required this.optimizedBytes,
    required this.originalSize,
    required this.optimizedSize,
    required this.width,
    required this.height,
    required this.format,
    required this.processingTime,
  });

  double get compressionRatio => originalSize > 0 ? optimizedSize / originalSize : 0;
  double get sizeReduction => (originalSize - optimizedSize).toDouble();
  double get processingSpeed => originalSize / processingTime.inMilliseconds; // bytes per ms

  @override
  String toString() {
    return 'OptimizedImage(size: ${optimizedSize ~/ 1024}KB, ratio: ${(compressionRatio * 100).toStringAsFixed(1)}%, time: ${processingTime.inMilliseconds}ms)';
  }
}

/// Image dimensions
class ImageDimensions {
  final int width;
  final int height;
  final double aspectRatio;

  const ImageDimensions({
    required this.width,
    required this.height,
    required this.aspectRatio,
  });
}

/// Custom exception for image optimization errors
class ImageOptimizationException implements Exception {
  final String message;
  const ImageOptimizationException(this.message);

  @override
  String toString() => message;
}
