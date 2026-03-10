@TestOn('browser')
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:uploader_app/models/upload_model.dart';
import 'package:uploader_app/models/employee_model.dart';
import 'package:uploader_app/services/upload_service.dart';
import '../mocks/mocks.mocks.dart';

void main() {
  group('UploadService Tests', () {
    late MockHttpClientService mockHttpClient;
    late MockConnectivity mockConnectivity;
    late UploadService uploadService;

    setUp(() {
      mockHttpClient = MockHttpClientService();
      mockConnectivity = MockConnectivity();

      when(mockHttpClient.currentUser).thenReturn(
        Employee(
          id: 1,
          username: 'testuser',
          firstName: 'Test',
          lastName: 'User',
          email: 'test@example.com',
          role: 'Admin',
          permissions: [],
          isActive: true,
          createdAt: DateTime.now(),
        )
      );

      uploadService = UploadService(
        httpClient: mockHttpClient,
        connectivity: mockConnectivity,
        maxConcurrentUploads: 1,
        retryDelay: const Duration(milliseconds: 1),
        maxRetries: 0,
      );
    });

    test('upload fails gracefully when there is an exception', () async {
      // Setup mock connectivity
      when(mockConnectivity.checkConnectivity())
          .thenAnswer((_) async => [ConnectivityResult.wifi]);

      // Setup mock to throw an exception
      when(mockHttpClient.uploadFile(
        any,
        any,
        any,
        any,
        any,
        fields: anyNamed('fields'),
        onProgress: anyNamed('onProgress'),
      )).thenThrow(Exception('Network error'));

      final response = await uploadService.uploadFile(
        fileName: 'test.jpg',
        fileBytes: [1, 2, 3],
        mimeType: 'image/jpeg',
      );

      // Verify response logic
      expect(response.success, isTrue); // Queued successfully!
      expect(response.data, isNotNull);

      // Ensure that the queued upload eventually fails.
      await expectLater(
        uploadService.uploadStream,
        emitsThrough(
          isA<Upload>()
              .having((u) => u.status, 'status', UploadStatus.failed)
              .having((u) => u.errorMessage, 'errorMessage', contains('Network error')),
        ),
      );
    });
  });
}
