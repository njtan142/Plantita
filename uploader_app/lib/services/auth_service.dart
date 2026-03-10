import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';
import 'http_client_service.dart';

/// Employee Authentication Service for handling login, logout, and token management
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  final HttpClientService _httpClient;
  final FlutterSecureStorage _secureStorage;

  // Authentication state
  AuthTokenModel? _currentToken;
  Employee? _currentUser;
  bool _isInitialized = false;

  AuthService({
    required HttpClientService httpClient,
    FlutterSecureStorage? secureStorage,
  })  : _httpClient = httpClient,
        _secureStorage = secureStorage ?? const FlutterSecureStorage();

  /// Current authentication token
  AuthTokenModel? get currentToken => _currentToken;

  /// Current authenticated user
  Employee? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentToken != null && !_currentToken!.isExpired;

  /// Check if user is admin
  bool get isAdmin => _currentUser?.isAdmin ?? false;

  /// Check if user is uploader
  bool get isUploader => _currentUser?.isUploader ?? false;

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize service by loading stored authentication data
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Load stored token
      final tokenJson = await _secureStorage.read(key: _tokenKey);
      if (tokenJson != null) {
        final tokenData = jsonDecode(tokenJson);
        _currentToken = AuthTokenModel.fromJson(tokenData);

        // Check if token is still valid
        if (_currentToken!.isExpired) {
          await _clearStoredAuth();
        } else {
          _httpClient.setToken(_currentToken!);
        }
      }

      // Load stored user
      final userJson = await _secureStorage.read(key: _userKey);
      if (userJson != null) {
        final userData = jsonDecode(userJson);
        _currentUser = Employee.fromJson(userData);
        _httpClient.setUser(_currentUser!);
      }

      _isInitialized = true;
    } catch (e) {
      // Clear corrupted data
      await _clearStoredAuth();
      _isInitialized = true;
    }
  }

  /// Login with username and password
  Future<ApiResponse<AuthTokenModel>> login(String username, String password) async {
    try {
      final response = await _httpClient.post<AuthTokenModel>(
        '/auth/login',
        body: {
          'username': username,
          'password': password,
        },
        fromJson: (json) => AuthTokenModel.fromMap(json),
        retryOnFailure: false, // Don't retry auth requests
      );

      if (response.success && response.data != null) {
        _currentToken = response.data;

        // Store token securely
        await _secureStorage.write(
          key: _tokenKey,
          value: jsonEncode(_currentToken!.toJson()),
        );

        // Set token in HTTP client
        _httpClient.setToken(_currentToken!);

        // Fetch user profile
        await _fetchUserProfile();
      }

      return response;
    } catch (e) {
      return ApiResponse.error(message: 'Login failed: ${e.toString()}');
    }
  }

  /// Register new employee
  Future<ApiResponse<AuthTokenModel>> register(
    String username,
    String email,
    String password,
    String firstName,
    String lastName,
  ) async {
    try {
      final response = await _httpClient.post<AuthTokenModel>(
        '/auth/register',
        body: {
          'username': username,
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
        },
        fromJson: (json) => AuthTokenModel.fromMap(json),
        retryOnFailure: false, // Don't retry auth requests
      );

      if (response.success && response.data != null) {
        _currentToken = response.data;

        // Store token securely
        await _secureStorage.write(
          key: _tokenKey,
          value: jsonEncode(_currentToken!.toJson()),
        );

        // Set token in HTTP client
        _httpClient.setToken(_currentToken!);

        // Fetch user profile
        await _fetchUserProfile();
      }

      return response;
    } catch (e) {
      return ApiResponse.error(message: 'Registration failed: ${e.toString()}');
    }
  }

  /// Refresh authentication token
  Future<ApiResponse<AuthTokenModel>> refreshToken() async {
    if (_currentToken?.refreshToken == null) {
      return ApiResponse.error(message: 'No refresh token available');
    }

    try {
      final response = await _httpClient.post<AuthTokenModel>(
        '/auth/refresh',
        body: {
          'refresh_token': _currentToken!.refreshToken,
        },
        fromJson: (json) => AuthTokenModel.fromMap(json),
        retryOnFailure: false,
      );

      if (response.success && response.data != null) {
        _currentToken = response.data;

        // Store updated token
        await _secureStorage.write(
          key: _tokenKey,
          value: jsonEncode(_currentToken!.toJson()),
        );

        // Update HTTP client
        _httpClient.setToken(_currentToken!);
      }

      return response;
    } catch (e) {
      return ApiResponse.error(message: 'Token refresh failed: ${e.toString()}');
    }
  }

  /// Logout and clear authentication
  Future<void> logout() async {
    try {
      // Call logout endpoint if authenticated
      if (isAuthenticated) {
        await _httpClient.post('/auth/logout');
      }
    } catch (e) {
      // Continue with local logout even if API call fails
    } finally {
      await _clearStoredAuth();
    }
  }

  /// Fetch user profile after successful authentication
  Future<void> _fetchUserProfile() async {
    try {
      final response = await _httpClient.get<Employee>(
        '/auth/profile',
        fromJson: (json) => Employee.fromJson(json),
      );

      if (response.success && response.data != null) {
        _currentUser = response.data;

        // Store user data
        await _secureStorage.write(
          key: _userKey,
          value: jsonEncode(_currentUser!.toJson()),
        );

        // Set user in HTTP client
        _httpClient.setUser(_currentUser!);
      }
    } catch (e) {
      // User profile fetch failed, but auth was successful
      // This is not critical, user can continue
    }
  }

  /// Clear stored authentication data
  Future<void> _clearStoredAuth() async {
    _currentToken = null;
    _currentUser = null;

    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userKey);

    _httpClient.clearAuth();
  }

  /// Check if token needs refresh and refresh if necessary
  Future<bool> ensureValidToken() async {
    if (!isAuthenticated) return false;

    if (_currentToken!.needsRefresh) {
      final refreshResponse = await refreshToken();
      return refreshResponse.success;
    }

    return true;
  }

  /// Change password
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!isAuthenticated) {
      return ApiResponse.error(message: 'User not authenticated');
    }

    try {
      final response = await _httpClient.post(
        '/auth/change-password',
        body: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      return response;
    } catch (e) {
      return ApiResponse.error(message: 'Password change failed: ${e.toString()}');
    }
  }

  /// Update user profile
  Future<ApiResponse<Employee>> updateProfile({
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    if (!isAuthenticated || _currentUser == null) {
      return ApiResponse.error(message: 'User not authenticated');
    }

    try {
      final updateData = <String, dynamic>{};
      if (firstName != null) updateData['first_name'] = firstName;
      if (lastName != null) updateData['last_name'] = lastName;
      if (email != null) updateData['email'] = email;

      final response = await _httpClient.put<Employee>(
        '/auth/profile',
        body: updateData,
        fromJson: (json) => Employee.fromJson(json),
      );

      if (response.success && response.data != null) {
        _currentUser = response.data;

        // Update stored user data
        await _secureStorage.write(
          key: _userKey,
          value: jsonEncode(_currentUser!.toJson()),
        );

        _httpClient.setUser(_currentUser!);
      }

      return response;
    } catch (e) {
      return ApiResponse.error(message: 'Profile update failed: ${e.toString()}');
    }
  }

  /// Check if user has specific permission
  bool hasPermission(String permission) {
    return _currentUser?.hasPermission(permission) ?? false;
  }

  /// Dispose service and clean up resources
  void dispose() {
    // No resources to clean up currently
  }
}