import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:provider_test/provider_test.dart';
import 'package:faker/faker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:uploader_app/models/models.dart';
import 'package:uploader_app/services/services.dart';
import 'package:uploader_app/providers/providers.dart';

// Generate mocks
@GenerateMocks([
  HttpClientService,
  AuthService,
  UserService,
  UploadService,
  WebCameraService,
  FileSelectionService,
  SharedPreferences,
  Connectivity,
])
void main() {}

// Test utilities and helpers
class TestUtils {
  static final Faker faker = Faker();

  // Setup mock SharedPreferences
  static Future<void> setupMockSharedPreferences() async {
    SharedPreferences.setMockInitialValues({});
  }

  // Create a test widget with providers
  static Widget createTestWidget({
    required Widget child,
    Map<String, dynamic>? providers,
  }) {
    return MultiProvider(
      providers: [
        if (providers != null) ...providers.entries.map(
          (entry) => ChangeNotifierProvider.value(value: entry.value),
        ),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  // Create mock data
  static UserModel createMockUser() {
    return UserModel(
      id: faker.randomGenerator.integer(1000),
      name: faker.person.name(),
      email: faker.internet.email(),
      avatar: faker.internet.httpUrl(),
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  static Employee createMockEmployee() {
    return Employee(
      id: faker.randomGenerator.integer(1000),
      name: faker.person.name(),
      email: faker.internet.email(),
      department: faker.company.name(),
      position: faker.job.title(),
      avatar: faker.internet.httpUrl(),
      isActive: faker.randomGenerator.boolean(),
      createdAt: DateTime.now().toIso8601String(),
      updatedAt: DateTime.now().toIso8601String(),
    );
  }

  static AuthToken createMockAuthToken() {
    return AuthToken(
      accessToken: faker.jwt.secret,
      refreshToken: faker.jwt.secret,
      tokenType: 'Bearer',
      expiresIn: 3600,
      scope: 'read write',
    );
  }

  static UploadModel createMockUpload() {
    return UploadModel(
      id: faker.randomGenerator.string(10),
      fileName: faker.lorem.word(),
      filePath: faker.internet.httpUrl(),
      fileSize: faker.randomGenerator.integer(1000000),
      mimeType: 'image/jpeg',
      status: UploadStatus.pending,
      progress: 0.0,
      userId: faker.randomGenerator.integer(1000),
      createdAt: DateTime.now(),
    );
  }

  // HTTP response helpers
  static http.Response createMockResponse({
    required String body,
    int statusCode = 200,
    Map<String, String>? headers,
  }) {
    return http.Response(
      body,
      statusCode,
      headers: headers ?? {'content-type': 'application/json'},
    );
  }

  // Exception helpers
  static Exception createNetworkException() {
    return Exception('Network error');
  }

  static Exception createTimeoutException() {
    return Exception('Request timeout');
  }
}

// Custom matchers for common test scenarios
class TestMatchers {
  static Matcher equalsUser(UserModel expected) {
    return isA<UserModel>()
        .having((u) => u.id, 'id', expected.id)
        .having((u) => u.name, 'name', expected.name)
        .having((u) => u.email, 'email', expected.email);
  }

  static Matcher equalsEmployee(Employee expected) {
    return isA<Employee>()
        .having((e) => e.id, 'id', expected.id)
        .having((e) => e.name, 'name', expected.name)
        .having((e) => e.email, 'email', expected.email)
        .having((e) => e.department, 'department', expected.department)
        .having((e) => e.position, 'position', expected.position);
  }

  static Matcher equalsUpload(UploadModel expected) {
    return isA<UploadModel>()
        .having((u) => u.id, 'id', expected.id)
        .having((u) => u.fileName, 'fileName', expected.fileName)
        .having((u) => u.status, 'status', expected.status)
        .having((u) => u.userId, 'userId', expected.userId);
  }

  static Matcher isApiResponseSuccess() {
    return isA<ApiResponse>()
        .having((r) => r.success, 'success', true);
  }

  static Matcher isApiResponseError() {
    return isA<ApiResponse>()
        .having((r) => r.success, 'success', false);
  }
}

// Test constants
class TestConstants {
  static const String mockBaseUrl = 'https://api.test.com';
  static const String mockAccessToken = 'mock_access_token';
  static const String mockRefreshToken = 'mock_refresh_token';
  static const Duration testTimeout = Duration(seconds: 5);
  static const int testUserId = 123;
  static const int testEmployeeId = 456;

  // Mock API responses
  static const Map<String, dynamic> mockLoginResponse = {
    'success': true,
    'data': {
      'user': {
        'id': 1,
        'name': 'Test User',
        'email': 'test@example.com',
        'avatar': 'https://example.com/avatar.jpg',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      },
      'token': {
        'access_token': 'mock_access_token',
        'refresh_token': 'mock_refresh_token',
        'token_type': 'Bearer',
        'expires_in': 3600,
        'scope': 'read write',
      }
    },
    'message': 'Login successful'
  };

  static const Map<String, dynamic> mockErrorResponse = {
    'success': false,
    'data': null,
    'message': 'An error occurred'
  };

  static const Map<String, dynamic> mockUsersResponse = {
    'success': true,
    'data': [
      {
        'id': 1,
        'name': 'User 1',
        'email': 'user1@example.com',
        'avatar': 'https://example.com/avatar1.jpg',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      },
      {
        'id': 2,
        'name': 'User 2',
        'email': 'user2@example.com',
        'avatar': 'https://example.com/avatar2.jpg',
        'created_at': '2024-01-01T00:00:00Z',
        'updated_at': '2024-01-01T00:00:00Z',
      }
    ],
    'message': 'Users retrieved successfully'
  };
}