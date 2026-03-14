import 'dart:async';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import '../models/image_models.dart';

/// Image optimization service for processing and compressing images
class ImageOptimizationService {
  // Configuration
  final int _maxWidth;
  final int _maxHeight;
  final int _quality;
  final int _maxFileSize;

  // Memory management
  final Map<String, WeakReference<Uint8List>> _imageCache = {};
  final Map<String, Completer<Uint8List>> _processingQueue = {};

  ImageOptimizationService({
    int maxWidth = 1920,
    int maxHeight = 1080,
    int quality = 85,
    int maxFileSize = 1024 * 1024, // 1MB
    Duration timeout = const Duration(seconds: 30),
  })  : _maxWidth = maxWidth,
        _maxHeight = maxHeight,
        _quality = quality,
        _maxFileSize = maxFileSize;

  /// Optimize image from bytes with platform-specific processing
  Future<OptimizedImage> optimizeImage(
    Uint8List imageBytes, {
    String? filename,
    ImageQuality quality = ImageQuality.high,
    ImageFormat format = ImageFormat.auto,
    bool maintainAspectRatio = true,
    Function(double)? onProgress,
  }) async {
    final startTime = DateTime.now();

    try {
      // Check cache first
      final cacheKey = _generateCacheKey(imageBytes);
      if (_imageCache.containsKey(cacheKey)) {
        final cached = _imageCache[cacheKey]?.target;
        if (cached != null) {
          return OptimizedImage(
            originalBytes: imageBytes,
            optimizedBytes: cached,
            originalSize: imageBytes.length,
            optimizedSize: cached.length,
            width: 0,
            height: 0,
            format: format,
            processingTime: DateTime.now().difference(startTime),
          );
        }
      }

      // Process image
      final result = await _processImage(
        imageBytes,
        quality: quality,
        format: format,
        maintainAspectRatio: maintainAspectRatio,
        onProgress: onProgress,
      );

      // Cache result
      _imageCache[cacheKey] = WeakReference(result.optimizedBytes);

      return result;
    } catch (e) {
      throw ImageOptimizationException('Failed to optimize image: $e');
    }
  }

  /// Batch optimize multiple images
  Future<List<OptimizedImage>> optimizeImages(
    List<Uint8List> images, {
    ImageQuality quality = ImageQuality.high,
    ImageFormat format = ImageFormat.auto,
    bool maintainAspectRatio = true,
    Function(double)? onProgress,
  }) async {
    final results = <OptimizedImage>[];
    final totalImages = images.length;

    for (int i = 0; i < totalImages; i++) {
      try {
        final result = await optimizeImage(
          images[i],
          quality: quality,
          format: format,
          maintainAspectRatio: maintainAspectRatio,
          onProgress: (progress) {
            final overallProgress = (i + progress) / totalImages;
            onProgress?.call(overallProgress);
          },
        );
        results.add(result);
      } catch (e) {
        // Log error but continue processing other images
        debugPrint('Failed to optimize image ${i + 1}: $e');
      }
    }

    return results;
  }

  /// Get image dimensions without loading full image
  Future<ImageDimensions> getImageDimensions(Uint8List imageBytes) async {
    try {
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        throw ImageOptimizationException('Failed to decode image for dimensions');
      }
      return ImageDimensions(
        width: decodedImage.width,
        height: decodedImage.height,
        aspectRatio: decodedImage.width / decodedImage.height,
      );
    } catch (e) {
      throw ImageOptimizationException('Failed to get image dimensions: $e');
    }
  }

  /// Resize image to specific dimensions
  Future<Uint8List> resizeImage(
    Uint8List imageBytes, {
    required int width,
    required int height,
    bool maintainAspectRatio = true,
  }) async {
    try {
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw ImageOptimizationException('Failed to decode image');
      }

      late img.Image resizedImage;
      resizedImage = img.copyResize(
        originalImage,
        width: width,
        height: height,
        interpolation: img.Interpolation.cubic,
      );

      return Uint8List.fromList(img.encodeJpg(resizedImage, quality: _quality));
    } catch (e) {
      throw ImageOptimizationException('Failed to resize image: $e');
    }
  }

  /// Convert image format
  Future<Uint8List> convertImageFormat(
    Uint8List imageBytes,
    ImageFormat format, {
    int quality = 85,
  }) async {
    try {
      final image = img.decodeImage(imageBytes);
      if (image == null) {
        throw ImageOptimizationException('Failed to decode image');
      }

      switch (format) {
        case ImageFormat.jpeg:
          return Uint8List.fromList(img.encodeJpg(image, quality: quality));
        case ImageFormat.png:
          return Uint8List.fromList(img.encodePng(image));
        case ImageFormat.webp:
          // WebP encoding not available in image package, fallback to JPEG
          debugPrint('WebP encoding not supported, falling back to JPEG');
          return Uint8List.fromList(img.encodeJpg(image, quality: quality));
        default:
          return imageBytes;
      }
    } catch (e) {
      throw ImageOptimizationException('Failed to convert image format: $e');
    }
  }

  /// Platform-specific image processing
  Future<OptimizedImage> _processImage(
    Uint8List imageBytes, {
    required ImageQuality quality,
    required ImageFormat format,
    required bool maintainAspectRatio,
    Function(double)? onProgress,
  }) async {
    if (kIsWeb) {
      return await _processImageWeb(
        imageBytes,
        quality: quality,
        format: format,
        maintainAspectRatio: maintainAspectRatio,
        onProgress: onProgress,
      );
    } else {
      return await _processImageMobile(
        imageBytes,
        quality: quality,
        format: format,
        maintainAspectRatio: maintainAspectRatio,
        onProgress: onProgress,
      );
    }
  }

  /// Web-specific image processing
  Future<OptimizedImage> _processImageWeb(
    Uint8List imageBytes, {
    required ImageQuality quality,
    required ImageFormat format,
    required bool maintainAspectRatio,
    Function(double)? onProgress,
  }) async {
    final startTime = DateTime.now();

    // Get original dimensions
    final dimensions = await getImageDimensions(imageBytes);
    onProgress?.call(0.1);

    // Calculate target dimensions
    final targetSize = _calculateTargetSize(dimensions, quality);
    onProgress?.call(0.2);

    // Resize if needed
    Uint8List processedBytes = imageBytes;
    if (dimensions.width > targetSize.width || dimensions.height > targetSize.height) {
      processedBytes = await resizeImage(
        imageBytes,
        width: targetSize.width,
        height: targetSize.height,
        maintainAspectRatio: maintainAspectRatio,
      );
    }
    onProgress?.call(0.5);

    // Convert format if needed
    if (format != ImageFormat.auto) {
      processedBytes = await convertImageFormat(
        processedBytes,
        format,
        quality: _getQualityValue(quality),
      );
    }
    onProgress?.call(0.8);

    // Final compression check
    if (processedBytes.length > _maxFileSize) {
      processedBytes = await _compressToSize(
        processedBytes,
        _maxFileSize,
        onProgress: (progress) => onProgress?.call(0.8 + progress * 0.2),
      );
    }
    onProgress?.call(1.0);

    return OptimizedImage(
      originalBytes: imageBytes,
      optimizedBytes: processedBytes,
      originalSize: imageBytes.length,
      optimizedSize: processedBytes.length,
      width: targetSize.width,
      height: targetSize.height,
      format: format,
      processingTime: DateTime.now().difference(startTime),
    );
  }

  /// Mobile-specific image processing using flutter_image_compress
  Future<OptimizedImage> _processImageMobile(
    Uint8List imageBytes, {
    required ImageQuality quality,
    required ImageFormat format,
    required bool maintainAspectRatio,
    Function(double)? onProgress,
  }) async {
    final startTime = DateTime.now();

    // Get original dimensions
    final dimensions = await getImageDimensions(imageBytes);
    onProgress?.call(0.1);

    // Calculate target dimensions
    final targetSize = _calculateTargetSize(dimensions, quality);
    onProgress?.call(0.2);

    // Use flutter_image_compress for mobile
    final compressedBytes = await FlutterImageCompress.compressWithList(
      imageBytes,
      minWidth: targetSize.width,
      minHeight: targetSize.height,
      quality: _getQualityValue(quality),
      format: _getCompressFormat(format),
    );
    onProgress?.call(0.6);

    // Final size check
    Uint8List finalBytes = compressedBytes;
    if (compressedBytes.length > _maxFileSize) {
      finalBytes = await _compressToSize(
        compressedBytes,
        _maxFileSize,
        onProgress: (progress) => onProgress?.call(0.6 + progress * 0.4),
      );
    }
    onProgress?.call(1.0);

    return OptimizedImage(
      originalBytes: imageBytes,
      optimizedBytes: finalBytes,
      originalSize: imageBytes.length,
      optimizedSize: finalBytes.length,
      width: targetSize.width,
      height: targetSize.height,
      format: format,
      processingTime: DateTime.now().difference(startTime),
    );
  }

  /// Compress image to fit within size limit
  Future<Uint8List> _compressToSize(
    Uint8List imageBytes,
    int maxSize, {
    Function(double)? onProgress,
  }) async {
    int quality = 90;
    const int minQuality = 30;
    const int qualityStep = 10;

    while (quality >= minQuality) {
      final compressed = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: quality,
        format: CompressFormat.jpeg,
      );

      if (compressed.length <= maxSize) {
        return compressed;
      }

      quality -= qualityStep;
      onProgress?.call((90 - quality) / 60); // Progress from 0 to 1
    }

    // If still too large, resize
    final dimensions = await getImageDimensions(imageBytes);
    final scale = maxSize / imageBytes.length;
    final newWidth = (dimensions.width * scale * 0.8).toInt();
    final newHeight = (dimensions.height * scale * 0.8).toInt();

    return await resizeImage(
      imageBytes,
      width: newWidth.clamp(100, dimensions.width),
      height: newHeight.clamp(100, dimensions.height),
      maintainAspectRatio: true,
    );
  }

  /// Calculate target size based on quality setting
  ImageDimensions _calculateTargetSize(ImageDimensions original, ImageQuality quality) {
    final scale = _getScaleFactor(quality);
    return ImageDimensions(
      width: (original.width * scale).toInt().clamp(100, _maxWidth),
      height: (original.height * scale).toInt().clamp(100, _maxHeight),
      aspectRatio: original.aspectRatio,
    );
  }

  /// Get scale factor for quality setting
  double _getScaleFactor(ImageQuality quality) {
    switch (quality) {
      case ImageQuality.low:
        return 0.3;
      case ImageQuality.medium:
        return 0.6;
      case ImageQuality.high:
        return 0.9;
      case ImageQuality.original:
        return 1.0;
    }
  }

  /// Get quality value for compression
  int _getQualityValue(ImageQuality quality) {
    switch (quality) {
      case ImageQuality.low:
        return 50;
      case ImageQuality.medium:
        return 75;
      case ImageQuality.high:
        return 90;
      case ImageQuality.original:
        return 95;
    }
  }

  /// Get compress format for flutter_image_compress
  CompressFormat _getCompressFormat(ImageFormat format) {
    switch (format) {
      case ImageFormat.jpeg:
        return CompressFormat.jpeg;
      case ImageFormat.png:
        return CompressFormat.png;
      case ImageFormat.webp:
        return CompressFormat.webp;
      default:
        return CompressFormat.jpeg;
    }
  }

  /// Generate cache key for image
  String _generateCacheKey(Uint8List bytes) {
    // Simple hash for caching
    var hash = 0;
    for (var byte in bytes) {
      hash = (hash * 31 + byte) & 0xFFFFFFFF;
    }
    return hash.toString();
  }

  /// Clear image cache
  void clearCache() {
    _imageCache.clear();
    _processingQueue.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cachedImages': _imageCache.length,
      'activeProcessing': _processingQueue.length,
      'maxWidth': _maxWidth,
      'maxHeight': _maxHeight,
      'quality': _quality,
      'maxFileSize': _maxFileSize,
    };
  }
}
