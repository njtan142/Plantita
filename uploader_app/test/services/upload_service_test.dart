import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:uploader_app/models/models.dart';
import 'package:uploader_app/services/upload_service.dart';
import 'package:uploader_app/services/http_client_service.dart';
import 'upload_service_test.mocks.dart';

// Use GenerateNiceMocks to avoid MissingStubError on getters like currentUser
@GenerateNiceMocks([
  MockSpec<HttpClientService>(),
  MockSpec<Connectivity>(),
])
void main() {
  group('UploadService Tests', () {
    late MockHttpClientService mockHttpClient;
    late MockConnectivity mockConnectivity;
    late UploadService uploadService;

    setUp(() {
      mockHttpClient = MockHttpClientService();
      mockConnectivity = MockConnectivity();
      uploadService = UploadService(
        httpClient: mockHttpClient,
        connectivity: mockConnectivity,
        retryDelay: const Duration(milliseconds: 1),
      );
    });

    tearDown(() {
      uploadService.dispose();
    });

    test('uploadFile handles exception and updates status to failed', () async {
      // Arrange
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      final currentUser = Employee(
        id: 1,
        username: 'test',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: 'user',
        permissions: [],
        isActive: true,
        createdAt: DateTime.now(),
      );
      when(mockHttpClient.currentUser).thenReturn(currentUser);

      when(mockHttpClient.uploadFile(
        any,
        any,
        any,
        any,
        any,
        fields: anyNamed('fields'),
        headers: anyNamed('headers'),
        fromJson: anyNamed('fromJson'),
        onProgress: anyNamed('onProgress'),
      )).thenThrow(const UploadException('Simulated test exception'));

      bool errorCallbackCalled = false;
      String? caughtErrorMessage;

      // Listen to the uploadStream to capture the failed upload
      Upload? finalUpload;
      uploadService.uploadStream.listen((upload) {
        if (upload.status == UploadStatus.failed) {
          finalUpload = upload;
        }
      });

      // Act
      final result = await uploadService.uploadFile(
        fileName: 'test.jpg',
        fileBytes: [1, 2, 3],
        mimeType: 'image/jpeg',
        userId: 1,
        onError: (message) {
          errorCallbackCalled = true;
          caughtErrorMessage = message;
        },
      );

      // Assert successful queueing
      expect(result.success, true);

      // Wait for the asynchronous queue processing to finish
      await Future.delayed(const Duration(milliseconds: 100));

      // Note: _processUpload sets failed state but removes the item from _uploadQueue before it finishes.
      // So checking getUploadStats() would yield failedUploads == 0.
      // We must rely on `finalUpload` from `uploadStream`

      expect(finalUpload, isNotNull);
      expect(finalUpload!.status, UploadStatus.failed);
      expect(finalUpload!.errorMessage, contains('Simulated test exception'));

      expect(errorCallbackCalled, true);
      expect(caughtErrorMessage, contains('Simulated test exception'));
    });
  });
}
