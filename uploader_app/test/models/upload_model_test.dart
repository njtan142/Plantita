import 'package:flutter_test/flutter_test.dart';
import 'package:uploader_app/models/upload_model.dart';

void main() {
  group('Upload Model Tests', () {
    const testUploadJson = {
      'id': 'upload_123',
      'file_name': 'test_image.jpg',
      'file_path': '/uploads/test_image.jpg',
      'file_size': 1024000,
      'mime_type': 'image/jpeg',
      'user_id': 1,
      'uploaded_by': 1,
      'status': 'completed',
      'progress': 1.0,
      'error_message': null,
      'created_at': '2024-01-01T10:00:00Z',
      'completed_at': '2024-01-01T10:01:00Z',
      'server_url': 'https://cdn.example.com/uploads/test_image.jpg',
      'metadata': {'width': 1920, 'height': 1080},
    };

    test('Upload.fromJson creates Upload correctly', () {
      final upload = Upload.fromJson(testUploadJson);

      expect(upload.id, 'upload_123');
      expect(upload.fileName, 'test_image.jpg');
      expect(upload.filePath, '/uploads/test_image.jpg');
      expect(upload.fileSize, 1024000);
      expect(upload.mimeType, 'image/jpeg');
      expect(upload.userId, 1);
      expect(upload.uploadedBy, 1);
      expect(upload.status, UploadStatus.completed);
      expect(upload.progress, 1.0);
      expect(upload.errorMessage, null);
      expect(upload.createdAt, DateTime.parse('2024-01-01T10:00:00Z'));
      expect(upload.completedAt, DateTime.parse('2024-01-01T10:01:00Z'));
      expect(upload.serverUrl, 'https://cdn.example.com/uploads/test_image.jpg');
      expect(upload.metadata, {'width': 1920, 'height': 1080});
    });

    test('Upload.fromJson handles null optional fields', () {
      final minimalUploadJson = {
        'id': 'minimal_123',
        'file_name': 'minimal.txt',
        'file_path': '/uploads/minimal.txt',
        'file_size': 100,
        'mime_type': 'text/plain',
        'uploaded_by': 1,
        'status': 'pending',
        'created_at': '2024-01-01T10:00:00Z',
      };

      final upload = Upload.fromJson(minimalUploadJson);

      expect(upload.id, 'minimal_123');
      expect(upload.userId, null);
      expect(upload.progress, 0.0);
      expect(upload.errorMessage, null);
      expect(upload.completedAt, null);
      expect(upload.serverUrl, null);
      expect(upload.metadata, null);
    });

    test('Upload.toJson converts Upload to JSON correctly', () {
      final upload = Upload(
        id: 'upload_123',
        fileName: 'test_image.jpg',
        filePath: '/uploads/test_image.jpg',
        fileSize: 1024000,
        mimeType: 'image/jpeg',
        userId: 1,
        uploadedBy: 1,
        status: UploadStatus.completed,
        progress: 1.0,
        errorMessage: null,
        createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
        completedAt: DateTime.parse('2024-01-01T10:01:00Z'),
        serverUrl: 'https://cdn.example.com/uploads/test_image.jpg',
        metadata: {'width': 1920, 'height': 1080},
      );

      final json = upload.toJson();

      expect(json['id'], 'upload_123');
      expect(json['file_name'], 'test_image.jpg');
      expect(json['file_path'], '/uploads/test_image.jpg');
      expect(json['file_size'], 1024000);
      expect(json['mime_type'], 'image/jpeg');
      expect(json['user_id'], 1);
      expect(json['uploaded_by'], 1);
      expect(json['status'], 'completed');
      expect(json['progress'], 1.0);
      expect(json['error_message'], null);
      expect(json['created_at'], '2024-01-01T10:00:00.000Z');
      expect(json['completed_at'], '2024-01-01T10:01:00.000Z');
      expect(json['server_url'], 'https://cdn.example.com/uploads/test_image.jpg');
      expect(json['metadata'], {'width': 1920, 'height': 1080});
    });

    test('Upload.fileSizeFormatted formats file sizes correctly', () {
      final testCases = [
        {'size': 500, 'expected': '500 B'},
        {'size': 1024, 'expected': '1.0 KB'},
        {'size': 1536, 'expected': '1.5 KB'},
        {'size': 1048576, 'expected': '1.0 MB'},
        {'size': 1073741824, 'expected': '1.0 GB'},
      ];

      for (final testCase in testCases) {
        final upload = Upload(
          id: 'test',
          fileName: 'test.txt',
          filePath: '/test.txt',
          fileSize: testCase['size'] as int,
          mimeType: 'text/plain',
          uploadedBy: 1,
          createdAt: DateTime.now(),
        );

        expect(upload.fileSizeFormatted, testCase['expected']);
      }
    });

    test('Upload.isInProgress returns true for uploading status', () {
      final uploadingUpload = Upload(
        id: 'test',
        fileName: 'test.txt',
        filePath: '/test.txt',
        fileSize: 100,
        mimeType: 'text/plain',
        uploadedBy: 1,
        status: UploadStatus.uploading,
        createdAt: DateTime.now(),
      );

      expect(uploadingUpload.isInProgress, true);
    });

    test('Upload.isInProgress returns false for non-uploading status', () {
      final statuses = [
        UploadStatus.pending,
        UploadStatus.completed,
        UploadStatus.failed,
        UploadStatus.cancelled,
      ];

      for (final status in statuses) {
        final upload = Upload(
          id: 'test',
          fileName: 'test.txt',
          filePath: '/test.txt',
          fileSize: 100,
          mimeType: 'text/plain',
          uploadedBy: 1,
          status: status,
          createdAt: DateTime.now(),
        );

        expect(upload.isInProgress, false);
      }
    });

    test('Upload.isCompleted returns true for completed status', () {
      final completedUpload = Upload(
        id: 'test',
        fileName: 'test.txt',
        filePath: '/test.txt',
        fileSize: 100,
        mimeType: 'text/plain',
        uploadedBy: 1,
        status: UploadStatus.completed,
        createdAt: DateTime.now(),
      );

      expect(completedUpload.isCompleted, true);
    });

    test('Upload.isCompleted returns false for non-completed status', () {
      final statuses = [
        UploadStatus.pending,
        UploadStatus.uploading,
        UploadStatus.failed,
        UploadStatus.cancelled,
      ];

      for (final status in statuses) {
        final upload = Upload(
          id: 'test',
          fileName: 'test.txt',
          filePath: '/test.txt',
          fileSize: 100,
          mimeType: 'text/plain',
          uploadedBy: 1,
          status: status,
          createdAt: DateTime.now(),
        );

        expect(upload.isCompleted, false);
      }
    });

    test('Upload.hasError returns true for failed status with error message', () {
      final failedUpload = Upload(
        id: 'test',
        fileName: 'test.txt',
        filePath: '/test.txt',
        fileSize: 100,
        mimeType: 'text/plain',
        uploadedBy: 1,
        status: UploadStatus.failed,
        errorMessage: 'Upload failed',
        createdAt: DateTime.now(),
      );

      expect(failedUpload.hasError, true);
    });

    test('Upload.hasError returns false for non-failed status', () {
      final upload = Upload(
        id: 'test',
        fileName: 'test.txt',
        filePath: '/test.txt',
        fileSize: 100,
        mimeType: 'text/plain',
        uploadedBy: 1,
        status: UploadStatus.completed,
        createdAt: DateTime.now(),
      );

      expect(upload.hasError, false);
    });

    test('Upload.canRetry returns true for failed uploads with error message', () {
      final failedUpload = Upload(
        id: 'test',
        fileName: 'test.txt',
        filePath: '/test.txt',
        fileSize: 100,
        mimeType: 'text/plain',
        uploadedBy: 1,
        status: UploadStatus.failed,
        errorMessage: 'Network error',
        createdAt: DateTime.now(),
      );

      expect(failedUpload.canRetry, true);
    });

    test('Upload.canRetry returns false for failed uploads without error message', () {
      final failedUpload = Upload(
        id: 'test',
        fileName: 'test.txt',
        filePath: '/test.txt',
        fileSize: 100,
        mimeType: 'text/plain',
        uploadedBy: 1,
        status: UploadStatus.failed,
        errorMessage: null,
        createdAt: DateTime.now(),
      );

      expect(failedUpload.canRetry, false);
    });

    test('Upload.canCancel returns true for pending and uploading uploads', () {
      final pendingUpload = Upload(
        id: 'test1',
        fileName: 'test.txt',
        filePath: '/test.txt',
        fileSize: 100,
        mimeType: 'text/plain',
        uploadedBy: 1,
        status: UploadStatus.pending,
        createdAt: DateTime.now(),
      );

      final uploadingUpload = Upload(
        id: 'test2',
        fileName: 'test.txt',
        filePath: '/test.txt',
        fileSize: 100,
        mimeType: 'text/plain',
        uploadedBy: 1,
        status: UploadStatus.uploading,
        createdAt: DateTime.now(),
      );

      expect(pendingUpload.canCancel, true);
      expect(uploadingUpload.canCancel, true);
    });

    test('Upload.canCancel returns false for completed, failed, and cancelled uploads', () {
      final statuses = [
        UploadStatus.completed,
        UploadStatus.failed,
        UploadStatus.cancelled,
      ];

      for (final status in statuses) {
        final upload = Upload(
          id: 'test',
          fileName: 'test.txt',
          filePath: '/test.txt',
          fileSize: 100,
          mimeType: 'text/plain',
          uploadedBy: 1,
          status: status,
          createdAt: DateTime.now(),
        );

        expect(upload.canCancel, false);
      }
    });

    test('Upload.progressPercentage calculates correct percentage', () {
      final testCases = [
        {'progress': 0.0, 'expected': 0},
        {'progress': 0.5, 'expected': 50},
        {'progress': 1.0, 'expected': 100},
        {'progress': 0.25, 'expected': 25},
        {'progress': 0.75, 'expected': 75},
      ];

      for (final testCase in testCases) {
        final upload = Upload(
          id: 'test',
          fileName: 'test.txt',
          filePath: '/test.txt',
          fileSize: 100,
          mimeType: 'text/plain',
          uploadedBy: 1,
          progress: testCase['progress'] as double,
          createdAt: DateTime.now(),
        );

        expect(upload.progressPercentage, testCase['expected']);
      }
    });

    test('Upload.estimatedTimeRemaining returns null for edge progress values', () {
      final upload1 = Upload(
        id: 'test1',
        fileName: 'test.txt',
        filePath: '/test.txt',
        fileSize: 100,
        mimeType: 'text/plain',
        uploadedBy: 1,
        progress: 0.0,
        createdAt: DateTime.now(),
      );

      final upload2 = Upload(
        id: 'test2',
        fileName: 'test.txt',
        filePath: '/test.txt',
        fileSize: 100,
        mimeType: 'text/plain',
        uploadedBy: 1,
        progress: 1.0,
        createdAt: DateTime.now(),
      );

      expect(upload1.estimatedTimeRemaining, null);
      expect(upload2.estimatedTimeRemaining, null);
    });

    test('Upload.estimatedTimeRemaining calculates reasonable estimates', () {
      final upload = Upload(
        id: 'test',
        fileName: 'test.txt',
        filePath: '/test.txt',
        fileSize: 100,
        mimeType: 'text/plain',
        uploadedBy: 1,
        progress: 0.5,
        createdAt: DateTime.now(),
      );

      final estimate = upload.estimatedTimeRemaining;
      expect(estimate, isNotNull);
      expect(estimate, greaterThan(0));
      expect(estimate, lessThanOrEqualTo(15)); // Should be reasonable estimate
    });

    test('Upload.copyWith creates new Upload with updated fields', () {
      final upload = Upload(
        id: 'original',
        fileName: 'original.txt',
        filePath: '/original.txt',
        fileSize: 100,
        mimeType: 'text/plain',
        uploadedBy: 1,
        status: UploadStatus.pending,
        progress: 0.0,
        createdAt: DateTime.now(),
      );

      final updatedUpload = upload.copyWith(
        fileName: 'updated.txt',
        status: UploadStatus.uploading,
        progress: 0.5,
        errorMessage: 'Test error',
        serverUrl: 'https://example.com/uploaded.txt',
      );

      expect(updatedUpload.id, 'original');
      expect(updatedUpload.fileName, 'updated.txt');
      expect(updatedUpload.status, UploadStatus.uploading);
      expect(updatedUpload.progress, 0.5);
      expect(updatedUpload.errorMessage, 'Test error');
      expect(updatedUpload.serverUrl, 'https://example.com/uploaded.txt');
    });

    test('Upload.copyWith returns same object when no changes', () {
      final upload = Upload(
        id: 'test',
        fileName: 'test.txt',
        filePath: '/test.txt',
        fileSize: 100,
        mimeType: 'text/plain',
        uploadedBy: 1,
        createdAt: DateTime.now(),
      );

      final sameUpload = upload.copyWith();

      expect(sameUpload.id, upload.id);
      expect(sameUpload.fileName, upload.fileName);
    });

    test('Upload equality and hashCode work correctly', () {
      final upload1 = Upload(
        id: 'test',
        fileName: 'test.txt',
        filePath: '/test.txt',
        fileSize: 100,
        mimeType: 'text/plain',
        uploadedBy: 1,
        createdAt: DateTime.now(),
      );

      final upload2 = Upload(
        id: 'test',
        fileName: 'test.txt',
        filePath: '/test.txt',
        fileSize: 100,
        mimeType: 'text/plain',
        uploadedBy: 1,
        createdAt: DateTime.now(),
      );

      final upload3 = Upload(
        id: 'different',
        fileName: 'different.txt',
        filePath: '/different.txt',
        fileSize: 200,
        mimeType: 'image/jpeg',
        uploadedBy: 2,
        createdAt: DateTime.now(),
      );

      expect(upload1 == upload2, true);
      expect(upload1.hashCode, upload2.hashCode);
      expect(upload1 == upload3, false);
      expect(upload1.hashCode == upload3.hashCode, false);
    });

    test('Upload.toString returns correct string representation', () {
      final upload = Upload(
        id: 'test',
        fileName: 'test.txt',
        filePath: '/test.txt',
        fileSize: 100,
        mimeType: 'text/plain',
        uploadedBy: 1,
        status: UploadStatus.uploading,
        progress: 0.5,
        createdAt: DateTime.now(),
      );

      final toString = upload.toString();

      expect(toString, 'Upload(id: test, fileName: test.txt, status: uploading, progress: 50%)');
    });

    test('Upload serialization is reversible', () {
      final originalUpload = Upload(
        id: 'upload_123',
        fileName: 'test_image.jpg',
        filePath: '/uploads/test_image.jpg',
        fileSize: 1024000,
        mimeType: 'image/jpeg',
        userId: 1,
        uploadedBy: 1,
        status: UploadStatus.completed,
        progress: 1.0,
        errorMessage: null,
        createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
        completedAt: DateTime.parse('2024-01-01T10:01:00Z'),
        serverUrl: 'https://cdn.example.com/uploads/test_image.jpg',
        metadata: {'width': 1920, 'height': 1080},
      );

      final json = originalUpload.toJson();
      final deserializedUpload = Upload.fromJson(json);

      expect(deserializedUpload.id, originalUpload.id);
      expect(deserializedUpload.fileName, originalUpload.fileName);
      expect(deserializedUpload.filePath, originalUpload.filePath);
      expect(deserializedUpload.fileSize, originalUpload.fileSize);
      expect(deserializedUpload.mimeType, originalUpload.mimeType);
      expect(deserializedUpload.userId, originalUpload.userId);
      expect(deserializedUpload.uploadedBy, originalUpload.uploadedBy);
      expect(deserializedUpload.status, originalUpload.status);
      expect(deserializedUpload.progress, originalUpload.progress);
      expect(deserializedUpload.errorMessage, originalUpload.errorMessage);
      expect(deserializedUpload.createdAt, originalUpload.createdAt);
      expect(deserializedUpload.completedAt, originalUpload.completedAt);
      expect(deserializedUpload.serverUrl, originalUpload.serverUrl);
      expect(deserializedUpload.metadata, originalUpload.metadata);
    });
  });

  group('UploadQueueItem Tests', () {
    test('UploadQueueItem constructor creates object correctly', () {
      final upload = Upload(
        id: 'test',
        fileName: 'test.txt',
        filePath: '/test.txt',
        fileSize: 100,
        mimeType: 'text/plain',
        uploadedBy: 1,
        createdAt: DateTime.now(),
      );

      final queuedAt = DateTime.now();
      final queueItem = UploadQueueItem(
        upload: upload,
        multipartFile: null,
        webFile: null,
        onProgress: (progress) {},
        onComplete: (upload) {},
        onError: (error) {},
        queuedAt: queuedAt,
      );

      expect(queueItem.upload, upload);
      expect(queueItem.multipartFile, null);
      expect(queueItem.webFile, null);
      expect(queueItem.onProgress, isNotNull);
      expect(queueItem.onComplete, isNotNull);
      expect(queueItem.onError, isNotNull);
      expect(queueItem.queuedAt, queuedAt);
    });

    test('UploadQueueItem.copyWith creates new object with updated fields', () {
      final upload1 = Upload(
        id: 'test1',
        fileName: 'test1.txt',
        filePath: '/test1.txt',
        fileSize: 100,
        mimeType: 'text/plain',
        uploadedBy: 1,
        createdAt: DateTime.now(),
      );

      final upload2 = Upload(
        id: 'test2',
        fileName: 'test2.txt',
        filePath: '/test2.txt',
        fileSize: 200,
        mimeType: 'image/jpeg',
        uploadedBy: 1,
        createdAt: DateTime.now(),
      );

      final originalItem = UploadQueueItem(
        upload: upload1,
        queuedAt: DateTime.now(),
      );

      final updatedItem = originalItem.copyWith(
        upload: upload2,
        onProgress: null,
      );

      expect(updatedItem.upload, upload2);
      expect(updatedItem.onProgress, null);
      expect(updatedItem.queuedAt, originalItem.queuedAt);
    });
  });
}