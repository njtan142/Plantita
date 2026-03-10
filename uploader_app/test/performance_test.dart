import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:uploader_app/models/models.dart';
import 'package:uploader_app/providers/upload_provider.dart';
import 'package:uploader_app/services/file_selection_service.dart';
import 'package:uploader_app/services/upload_service.dart';
import 'package:uploader_app/providers/user_selection_provider.dart';

class MockUploadService extends Mock implements UploadService {
  @override
  Future<ApiResponse<Upload>> uploadFile({
    required String fileName,
    required List<int> fileBytes,
    required String mimeType,
    required String userId,
    Function(double)? onProgress,
    Map<String, String>? additionalFields,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    return ApiResponse<Upload>(
      success: true,
      data: Upload(
        id: '123',
        mediaUrl: 'http://example.com/\$fileName',
        thumbnailUrl: null,
        type: 'image',
        createdAt: DateTime.now(),
        fileName: fileName,
        fileSize: 1024,
        mimeType: mimeType,
      ),
    );
  }
}

class MockFileSelectionService extends Mock implements FileSelectionService {}

class MockUserSelectionProvider extends Mock implements UserSelectionProvider {
  @override
  UserModel? get selectedUser => const UserModel(
        id: 'user1',
        username: 'testuser',
        email: 'test@example.com',
        displayName: 'Test User',
        followersCount: 0,
        followingCount: 0,
        createdAt: null,
      );
}

void main() {
  test('Performance test for uploading files', () async {
    final uploadService = MockUploadService();
    final fileSelectionService = MockFileSelectionService();
    final userSelectionProvider = MockUserSelectionProvider();

    final provider = UploadModelProvider(
      uploadService,
      fileSelectionService,
      userSelectionProvider,
    );

    // Create 20 mock files
    final mockFiles = List.generate(
      20,
      (index) => PlatformFile(
        name: 'file_\$index.jpg',
        size: 1024,
        bytes: Uint8List.fromList([0, 1, 2, 3]),
      ),
    );

    provider.addFilesToUploadModel(mockFiles);

    final stopwatch = Stopwatch()..start();
    await provider.startUploadModel();
    stopwatch.stop();

    print('Upload completed in \${stopwatch.elapsedMilliseconds}ms');
    expect(provider.completedUploadModels.length, 20);
  });
}
