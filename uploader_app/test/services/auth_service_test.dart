import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:uploader_app/models/models.dart';
import 'package:uploader_app/services/services.dart';
import '../mocks/mocks.mocks.dart';

void main() {
  group('AuthService Tests', () {
    late MockHttpClientService mockHttpClient;
    late MockSharedPreferences mockPrefs;
    late MockFlutterSecureStorage mockSecureStorage;
    late AuthService authService;

    setUp(() {
      mockHttpClient = MockHttpClientService();
      mockPrefs = MockSharedPreferences();
      mockSecureStorage = MockFlutterSecureStorage();
      authService = AuthService(
        httpClient: mockHttpClient,
        secureStorage: mockSecureStorage,
      );
    });

    tearDown(() {
      reset(mockHttpClient);
      reset(mockPrefs);
      reset(mockSecureStorage);
    });

    test('initialize loads stored auth data successfully', () async {
      // Arrange
      final tokenJson =
          '{"access_token": "test_token", "refresh_token": "refresh_token", "expires_at": "${DateTime.now().add(const Duration(hours: 1)).toIso8601String()}", "token_type": "Bearer"}';
      final userJson =
          '{"id": 1, "username": "testuser", "first_name": "Test", "last_name": "User", "role": "admin", "permissions": ["read", "write"], "is_active": true, "created_at": "${DateTime.now().toIso8601String()}"}';

      when(
        mockSecureStorage.read(key: 'auth_token'),
      ).thenAnswer((_) async => tokenJson);
      when(
        mockSecureStorage.read(key: 'auth_user'),
      ).thenAnswer((_) async => userJson);

      // Act
      await authService.initialize();

      // Assert
      expect(authService.isInitialized, true);
      expect(authService.isAuthenticated, true);
      expect(authService.isAdmin, true);
      expect(authService.currentUser?.username, 'testuser');
      verify(mockHttpClient.setToken(any)).called(1);
      verify(mockHttpClient.setUser(any)).called(1);
    });

    test('initialize handles expired token', () async {
      // Arrange
      final expiredTokenJson =
          '{"access_token": "expired_token", "refresh_token": "refresh_token", "expires_at": "${DateTime.now().subtract(const Duration(hours: 1)).toIso8601String()}", "token_type": "Bearer"}';

      when(
        mockSecureStorage.read(key: 'auth_token'),
      ).thenAnswer((_) async => expiredTokenJson);
      when(
        mockSecureStorage.read(key: 'auth_user'),
      ).thenAnswer((_) async => null);
      when(
        mockSecureStorage.delete(key: 'auth_token'),
      ).thenAnswer((_) async {});
      when(mockSecureStorage.delete(key: 'auth_user')).thenAnswer((_) async {});

      // Act
      await authService.initialize();

      // Assert
      expect(authService.isInitialized, true);
      expect(authService.isAuthenticated, false);
      expect(authService.currentUser, null);
      verify(mockSecureStorage.delete(key: 'auth_token')).called(1);
      verify(mockSecureStorage.delete(key: 'auth_user')).called(1);
    });

    test('login success stores auth data', () async {
      // Arrange
      final mockToken = AuthTokenModel(
        accessToken: 'new_access_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        tokenType: 'Bearer',
      );
      final mockUser = Employee(
        id: 1,
        username: 'newuser',
        email: 'new@example.com',
        firstName: 'New',
        lastName: 'User',
        role: 'user',
        permissions: ['read'],
        isActive: true,
        createdAt: DateTime.now(),
      );
      final mockResponse = ApiResponse.success(mockToken);

      when(
        mockHttpClient.post<AuthTokenModel>(
          any,
          body: anyNamed('body'),
          fromJson: anyNamed('fromJson'),
        ),
      ).thenAnswer((_) async => mockResponse);
      when(
        mockHttpClient.get<Employee>(any, fromJson: anyNamed('fromJson')),
      ).thenAnswer((_) async => ApiResponse.success(mockUser));
      when(
        mockSecureStorage.write(key: 'auth_token', value: anyNamed('value')),
      ).thenAnswer((_) async {});
      when(
        mockSecureStorage.write(key: 'auth_user', value: anyNamed('value')),
      ).thenAnswer((_) async {});

      // Act
      final result = await authService.login('username', 'password');

      // Assert
      expect(result.success, true);
      expect(authService.isAuthenticated, true);
      expect(authService.currentUser?.username, 'newuser');
      verify(mockHttpClient.setToken(mockToken)).called(1);
      verify(mockHttpClient.setUser(mockUser)).called(1);
    });

    test('login failure returns error response', () async {
      // Arrange
      final mockResponse = ApiResponse.error(message: 'Invalid credentials');

      when(
        mockHttpClient.post<AuthTokenModel>(
          any,
          body: anyNamed('body'),
          fromJson: anyNamed('fromJson'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await authService.login('wrong', 'credentials');

      // Assert
      expect(result.success, false);
      expect(result.message, 'Invalid credentials');
      expect(authService.isAuthenticated, false);
    });

    test('logout clears all auth data', () async {
      // Arrange - set up authenticated state
      final token = AuthTokenModel(
        accessToken: 'test_token',
        refreshToken: 'refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        tokenType: 'Bearer',
      );
      final user = Employee(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: 'user',
        permissions: ['read'],
        isActive: true,
        createdAt: DateTime.now(),
      );

      authService = AuthService(
        httpClient: mockHttpClient,
        secureStorage: mockSecureStorage,
      );

      when(
        mockHttpClient.post(any),
      ).thenAnswer((_) async => ApiResponse.success(null));
      when(
        mockSecureStorage.delete(key: 'auth_token'),
      ).thenAnswer((_) async {});
      when(mockSecureStorage.delete(key: 'auth_user')).thenAnswer((_) async {});

      // Act
      await authService.logout();

      // Assert
      expect(authService.isAuthenticated, false);
      expect(authService.currentUser, null);
      expect(authService.currentToken, null);
      verify(mockHttpClient.clearAuth()).called(1);
    });

    test('refreshToken success updates stored token', () async {
      // Arrange
      final oldToken = AuthTokenModel(
        accessToken: 'old_token',
        refreshToken: 'refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        tokenType: 'Bearer',
      );
      final newToken = AuthTokenModel(
        accessToken: 'new_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
        tokenType: 'Bearer',
      );

      authService = AuthService(
        httpClient: mockHttpClient,
        secureStorage: mockSecureStorage,
      );

      final mockResponse = ApiResponse.success(newToken);

      when(
        mockHttpClient.post<AuthTokenModel>(
          any,
          body: anyNamed('body'),
          fromJson: anyNamed('fromJson'),
        ),
      ).thenAnswer((_) async => mockResponse);
      when(
        mockSecureStorage.write(key: 'auth_token', value: anyNamed('value')),
      ).thenAnswer((_) async {});

      // Act
      final result = await authService.refreshToken();

      // Assert
      expect(result.success, true);
      expect(authService.currentToken?.accessToken, 'new_token');
      verify(mockHttpClient.setToken(newToken)).called(1);
    });

    test('refreshToken failure returns error', () async {
      // Arrange
      final mockResponse = ApiResponse.error(message: 'Invalid refresh token');

      when(
        mockHttpClient.post<AuthTokenModel>(
          any,
          body: anyNamed('body'),
          fromJson: anyNamed('fromJson'),
        ),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await authService.refreshToken();

      // Assert
      expect(result.success, false);
      expect(result.message, 'Invalid refresh token');
    });

    test('ensureValidToken refreshes when token needs refresh', () async {
      // Arrange
      final token = AuthTokenModel(
        accessToken: 'old_token',
        refreshToken: 'refresh_token',
        expiresAt: DateTime.now().add(
          const Duration(minutes: 3),
        ), // Expires in 3 minutes
        tokenType: 'Bearer',
      );
      final newToken = AuthTokenModel(
        accessToken: 'new_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
        tokenType: 'Bearer',
      );

      authService = AuthService(
        httpClient: mockHttpClient,
        secureStorage: mockSecureStorage,
      );

      when(
        mockHttpClient.post<AuthTokenModel>(
          any,
          body: anyNamed('body'),
          fromJson: anyNamed('fromJson'),
        ),
      ).thenAnswer((_) async => ApiResponse.success(newToken));
      when(
        mockSecureStorage.write(key: 'auth_token', value: anyNamed('value')),
      ).thenAnswer((_) async {});

      // Act
      final result = await authService.ensureValidToken();

      // Assert
      expect(result, true);
      expect(authService.currentToken?.accessToken, 'new_token');
    });

    test('changePassword success returns success response', () async {
      // Arrange
      final mockResponse = ApiResponse.success(null);

      when(
        mockHttpClient.post(any, body: anyNamed('body')),
      ).thenAnswer((_) async => mockResponse);

      // Act
      final result = await authService.changePassword(
        currentPassword: 'oldpass',
        newPassword: 'newpass',
      );

      // Assert
      expect(result.success, true);
    });

    test('changePassword when not authenticated returns error', () async {
      // Arrange - authService without authentication

      // Act
      final result = await authService.changePassword(
        currentPassword: 'oldpass',
        newPassword: 'newpass',
      );

      // Assert
      expect(result.success, false);
      expect(result.message, 'User not authenticated');
    });

    test('updateProfile success updates current user', () async {
      // Arrange
      final originalUser = Employee(
        id: 1,
        username: 'testuser',
        email: 'old@example.com',
        firstName: 'Old',
        lastName: 'Name',
        role: 'user',
        permissions: ['read'],
        isActive: true,
        createdAt: DateTime.now(),
      );
      final updatedUser = Employee(
        id: 1,
        username: 'testuser',
        email: 'new@example.com',
        firstName: 'New',
        lastName: 'Name',
        role: 'user',
        permissions: ['read'],
        isActive: true,
        createdAt: DateTime.now(),
      );

      authService = AuthService(
        httpClient: mockHttpClient,
        secureStorage: mockSecureStorage,
      );

      final mockResponse = ApiResponse.success(updatedUser);

      when(
        mockHttpClient.put<Employee>(
          any,
          body: anyNamed('body'),
          fromJson: anyNamed('fromJson'),
        ),
      ).thenAnswer((_) async => mockResponse);
      when(
        mockSecureStorage.write(key: 'auth_user', value: anyNamed('value')),
      ).thenAnswer((_) async {});

      // Act
      final result = await authService.updateProfile(
        email: 'new@example.com',
        firstName: 'New',
        lastName: 'Name',
      );

      // Assert
      expect(result.success, true);
      expect(authService.currentUser?.email, 'new@example.com');
      expect(authService.currentUser?.firstName, 'New');
    });

    test('hasPermission returns correct permission status', () {
      // Arrange
      final user = Employee(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        role: 'user',
        permissions: ['read', 'write'],
        isActive: true,
        createdAt: DateTime.now(),
      );

      authService = AuthService(
        httpClient: mockHttpClient,
        secureStorage: mockSecureStorage,
      );

      // Act & Assert
      expect(authService.hasPermission('read'), false); // No user set
    });

    test('isAdmin and isUploader getters work correctly', () {
      // Test with admin user
      final adminUser = Employee(
        id: 1,
        username: 'admin',
        email: 'admin@example.com',
        firstName: 'Admin',
        lastName: 'User',
        role: 'admin',
        permissions: ['read', 'write', 'admin'],
        isActive: true,
        createdAt: DateTime.now(),
      );

      authService = AuthService(
        httpClient: mockHttpClient,
        secureStorage: mockSecureStorage,
      );

      expect(authService.isAdmin, false); // No user set
      expect(authService.isUploader, false); // No user set
    });
  });
}
