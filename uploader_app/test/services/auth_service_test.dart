import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:uploader_app/models/models.dart';
import 'package:uploader_app/services/services.dart';
import '../mocks/mocks.mocks.dart';

void main() {
  group('AuthService Tests', () {
    late MockHttpClientService mockHttpClient;
    late MockFlutterSecureStorage mockSecureStorage;
    late AuthService authService;

    setUp(() {
      mockHttpClient = MockHttpClientService();
      mockSecureStorage = MockFlutterSecureStorage();
      
      // Broad default stubs for HttpClient
      when(mockHttpClient.post<AuthTokenModel>(
        any,
        body: anyNamed('body'),
        headers: anyNamed('headers'),
        fromJson: anyNamed('fromJson'),
        retryOnFailure: anyNamed('retryOnFailure'),
      )).thenAnswer((_) async => ApiResponse<AuthTokenModel>.error(message: 'Stubbed error'));

      when(mockHttpClient.get<Employee>(
        any, 
        headers: anyNamed('headers'),
        queryParams: anyNamed('queryParams'),
        fromJson: anyNamed('fromJson'),
        retryOnFailure: anyNamed('retryOnFailure'),
      )).thenAnswer((_) async => ApiResponse<Employee>.error(message: 'Stubbed error'));

      when(mockHttpClient.put<Employee>(
        any,
        body: anyNamed('body'),
        headers: anyNamed('headers'),
        fromJson: anyNamed('fromJson'),
        retryOnFailure: anyNamed('retryOnFailure'),
      )).thenAnswer((_) async => ApiResponse<Employee>.error(message: 'Stubbed error'));

      when(mockHttpClient.post<dynamic>(
        any,
        body: anyNamed('body'),
        headers: anyNamed('headers'),
        fromJson: anyNamed('fromJson'),
        retryOnFailure: anyNamed('retryOnFailure'),
      )).thenAnswer((_) async => ApiResponse<dynamic>.success(null));

      // Default stubs for SecureStorage
      when(mockSecureStorage.read(key: anyNamed('key')))
          .thenAnswer((_) async => null);
      when(mockSecureStorage.write(key: anyNamed('key'), value: anyNamed('value')))
          .thenAnswer((_) async {});
      when(mockSecureStorage.delete(key: anyNamed('key')))
          .thenAnswer((_) async {});

      authService = AuthService(
        httpClient: mockHttpClient,
        secureStorage: mockSecureStorage,
      );
    });

    tearDown(() {
      reset(mockHttpClient);
      reset(mockSecureStorage);
    });

    test('initialize loads stored auth data successfully', () async {
      // Arrange
      final nowStr = DateTime.now().add(const Duration(hours: 1)).toIso8601String();
      final tokenJson =
          '{"access_token": "test_token", "refresh_token": "refresh_token", "expires_at": "$nowStr", "token_type": "Bearer"}';
      final userJson =
          '{"id": 1, "username": "testuser", "email": "test@example.com", "first_name": "Test", "last_name": "User", "role": "admin", "permissions": ["read", "write"], "is_active": true, "created_at": "${DateTime.now().toIso8601String()}"}';

      when(mockSecureStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => tokenJson);
      when(mockSecureStorage.read(key: 'auth_user'))
          .thenAnswer((_) async => userJson);

      // Act
      await authService.initialize();

      // Assert
      expect(authService.isInitialized, true);
      expect(authService.isAuthenticated, true);
      expect(authService.isAdmin, true);
      expect(authService.currentUser?.username, 'testuser');
    });

    test('initialize handles expired token', () async {
      // Arrange
      final pastStr = DateTime.now().subtract(const Duration(hours: 1)).toIso8601String();
      final expiredTokenJson =
          '{"access_token": "expired_token", "refresh_token": "refresh_token", "expires_at": "$pastStr", "token_type": "Bearer"}';

      when(mockSecureStorage.read(key: 'auth_token'))
          .thenAnswer((_) async => expiredTokenJson);

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
      
      when(mockHttpClient.post<AuthTokenModel>(
        any,
        body: anyNamed('body'),
        headers: anyNamed('headers'),
        fromJson: anyNamed('fromJson'),
        retryOnFailure: anyNamed('retryOnFailure'),
      )).thenAnswer((_) async => ApiResponse<AuthTokenModel>.success(mockToken));
      
      when(mockHttpClient.get<Employee>(
        any, 
        headers: anyNamed('headers'),
        queryParams: anyNamed('queryParams'),
        fromJson: anyNamed('fromJson'),
        retryOnFailure: anyNamed('retryOnFailure'),
      )).thenAnswer((_) async => ApiResponse<Employee>.success(mockUser));

      // Act
      final result = await authService.login('username', 'password');

      // Assert
      expect(result.success, true);
      expect(authService.isAuthenticated, true);
      expect(authService.currentUser?.username, 'newuser');
      verify(mockSecureStorage.write(key: 'auth_token', value: any)).called(1);
      verify(mockSecureStorage.write(key: 'auth_user', value: any)).called(1);
    });

    test('login failure returns error response', () async {
      // Arrange
      when(mockHttpClient.post<AuthTokenModel>(
        any,
        body: anyNamed('body'),
        headers: anyNamed('headers'),
        fromJson: anyNamed('fromJson'),
        retryOnFailure: anyNamed('retryOnFailure'),
      )).thenAnswer((_) async => ApiResponse<AuthTokenModel>.error(message: 'Invalid credentials'));

      // Act
      final result = await authService.login('wrong', 'credentials');

      // Assert
      expect(result.success, false);
      expect(result.message, 'Invalid credentials');
      expect(authService.isAuthenticated, false);
    });

    test('logout clears all auth data', () async {
      // Arrange
      when(mockHttpClient.post<dynamic>(
        any,
        body: anyNamed('body'),
        headers: anyNamed('headers'),
        fromJson: anyNamed('fromJson'),
        retryOnFailure: anyNamed('retryOnFailure'),
      )).thenAnswer((_) async => ApiResponse<dynamic>.success(null));

      // Act
      await authService.logout();

      // Assert
      expect(authService.isAuthenticated, false);
      expect(authService.currentUser, null);
      verify(mockSecureStorage.delete(key: 'auth_token')).called(1);
      verify(mockSecureStorage.delete(key: 'auth_user')).called(1);
      verify(mockHttpClient.clearAuth()).called(1);
    });

    test('refreshToken success updates stored token', () async {
      // Arrange
      final newToken = AuthTokenModel(
        accessToken: 'new_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
        tokenType: 'Bearer',
      );

      when(mockHttpClient.post<AuthTokenModel>(
        any,
        body: anyNamed('body'),
        headers: anyNamed('headers'),
        fromJson: anyNamed('fromJson'),
        retryOnFailure: anyNamed('retryOnFailure'),
      )).thenAnswer((_) async => ApiResponse<AuthTokenModel>.success(newToken));

      // Act
      final result = await authService.refreshToken();

      // Assert
      expect(result.success, true);
      expect(authService.currentToken?.accessToken, 'new_token');
      verify(mockSecureStorage.write(key: 'auth_token', value: any)).called(1);
    });

    test('changePassword success returns success response', () async {
      // Arrange
      final user = Employee(id: 1, username: 'u', email: 'e', firstName: 'F', lastName: 'L', role: 'u', permissions: [], isActive: true, createdAt: DateTime.now());
      authService.setUserForTesting(user);
      
      when(mockHttpClient.post<dynamic>(
        any,
        body: anyNamed('body'),
        headers: anyNamed('headers'),
        fromJson: anyNamed('fromJson'),
        retryOnFailure: anyNamed('retryOnFailure'),
      )).thenAnswer((_) async => ApiResponse<dynamic>.success(null));

      // Act
      final result = await authService.changePassword(
        currentPassword: 'oldpass',
        newPassword: 'newpass',
      );

      // Assert
      expect(result.success, true);
    });

    test('updateProfile success updates current user', () async {
      // Arrange
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
      
      authService.setUserForTesting(updatedUser);

      when(mockHttpClient.put<Employee>(
        any,
        body: anyNamed('body'),
        headers: anyNamed('headers'),
        fromJson: anyNamed('fromJson'),
        retryOnFailure: anyNamed('retryOnFailure'),
      )).thenAnswer((_) async => ApiResponse<Employee>.success(updatedUser));

      // Act
      final result = await authService.updateProfile(
        email: 'new@example.com',
        firstName: 'New',
        lastName: 'Name',
      );

      // Assert
      expect(result.success, true);
      expect(authService.currentUser?.email, 'new@example.com');
    });
  });
}
