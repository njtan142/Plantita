import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:uploader_app/models/models.dart';
import 'package:uploader_app/providers/upload_provider.dart';
import 'package:uploader_app/services/upload_service.dart';
import 'package:uploader_app/providers/user_selection_provider.dart';

class MockUploadService extends Mock implements UploadService {
  @override
  Future<ApiResponse<Upload>> uploadFile({
    required String fileName,
    required List<int> fileBytes,
    required String mimeType,
    int? userId,
    Map<String, String>? additionalFields,
    Function(double)? onProgress,
    Function(Upload)? onComplete,
    Function(String)? onError,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    final upload = Upload(
      id: '123',
      fileName: fileName,
      filePath: fileName,
      fileSize: 1024,
      mimeType: mimeType,
      userId: userId,
      uploadedBy: 1,
      createdAt: DateTime.now(),
    );
    return ApiResponse<Upload>.success(
      upload,
    );
  }
}

class MockUserSelectionProvider extends Mock implements UserSelectionProvider {
  @override
  UserModel? get selectedUser => UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        isActive: true,
        createdAt: DateTime.now(),
      );
}

void main() {
  test('Performance test for uploading files', () async {
    final uploadService = MockUploadService();
    final userSelectionProvider = MockUserSelectionProvider();

    final provider = UploadModelProvider(
      uploadService,
      userSelectionProvider,
    );

    // Create 20 mock files
    final mockFiles = List.generate(
      20,
      (index) => PlatformFile(
        name: 'file_$index.jpg',
        size: 1024,
        bytes: Uint8List.fromList([0, 1, 2, 3]),
      ),
    );

    provider.addFilesToUploadModel(mockFiles);

    final stopwatch = Stopwatch()..start();
    await provider.startUploadModel();
    stopwatch.stop();

    debugPrint('Upload completed in ${stopwatch.elapsedMilliseconds}ms');
    expect(provider.completedUploadModels.length, 20);
  });
}
