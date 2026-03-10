import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/http_client_service.dart';
import '../constants/app_constants.dart';
import '../config/environment_config.dart';

class AuthProvider extends ChangeNotifier {
   late final HttpClientService _httpClient;
   late final AuthService _authService;
   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

   AuthProvider() {
     _httpClient = HttpClientService(baseUrl: EnvironmentConfig.apiBaseUrl);
     _authService = AuthService(httpClient: _httpClient);
   }

  Employee? _currentUser;
  AuthTokenModel? _authToken;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  // Getters
  Employee? get currentUser => _currentUser;
  AuthTokenModel? get authToken => _authToken;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null && _authToken != null && !_isTokenExpired;
  bool get isInitialized => _isInitialized;
  bool get _isTokenExpired {
    if (_authToken == null) return true;
    return _authToken!.isExpired;
  }

  // Initialize auth state
  Future<void> initialize() async {
    if (_isInitialized) return;

    _setLoading(true);
    _clearError();

    try {
      await _loadStoredAuthData();
      _isInitialized = true;
    } catch (e) {
      _setError('Failed to initialize authentication: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load stored authentication data
  Future<void> _loadStoredAuthData() async {
    try {
      final tokenString = await _secureStorage.read(key: AppConstants.tokenKey);
      final userString = await _secureStorage.read(key: AppConstants.userKey);

      if (tokenString != null && userString != null) {
        final token = AuthTokenModel.fromJson(tokenString);
        final userData = jsonDecode(userString);
        final user = Employee.fromJson(userData);

        if (!_isTokenExpired) {
          _authToken = token;
          _currentUser = user;
        } else {
          // Token expired, clear stored data
          await _clearStoredAuthData();
        }
      }
    } catch (e) {
      _setError('Failed to load authentication data: $e');
      await _clearStoredAuthData();
    }
  }

  // Login
  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.login(username, password);

      if (response.success && response.data != null) {
        _authToken = response.data;
        // User will be fetched by the AuthService internally
        _currentUser = _authService.currentUser;

        // Store auth data securely
        await _storeAuthData();

        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Login failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Register
  Future<bool> register(String username, String email, String password, String firstName, String lastName) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.register(
        username,
        email,
        password,
        firstName,
        lastName,
      );

      if (response.success && response.data != null) {
        _authToken = response.data;
        // User will be fetched by the AuthService internally
        _currentUser = _authService.currentUser;

        // Store auth data securely
        await _storeAuthData();

        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Registration failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.logout();
    } catch (e) {
      // Ignore logout errors
    }

    await _clearStoredAuthData();
    _clearAuthState();
    _setLoading(false);
    notifyListeners();
  }

  // Refresh token
  Future<bool> refreshToken() async {
    if (_authToken == null) return false;

    try {
      final response = await _authService.refreshToken();
      if (response.success && response.data != null) {
        _authToken = response.data;
        await _storeAuthData();
        notifyListeners();
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      await logout();
      return false;
    }
  }

  // Store authentication data
  Future<void> _storeAuthData() async {
    try {
      if (_authToken != null && _currentUser != null) {
        await _secureStorage.write(
          key: AppConstants.tokenKey,
          value: _authToken!.toJson(),
        );
        await _secureStorage.write(
          key: AppConstants.userKey,
          value: jsonEncode(_currentUser!.toJson()),
        );
      }
    } catch (e) {
      _setError('Failed to store authentication data: $e');
    }
  }

  // Clear stored authentication data
  Future<void> _clearStoredAuthData() async {
    try {
      await _secureStorage.delete(key: AppConstants.tokenKey);
      await _secureStorage.delete(key: AppConstants.userKey);
    } catch (e) {
      // Ignore storage errors
    }
  }

  // Clear authentication state
  void _clearAuthState() {
    _currentUser = null;
    _authToken = null;
  }

  // Update user profile
  Future<bool> updateProfile(Map<String, dynamic> updates) async {
    if (_currentUser == null || _authToken == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final firstName = updates['firstName'] as String?;
      final lastName = updates['lastName'] as String?;
      final email = updates['email'] as String?;

      final response = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        email: email,
      );

      if (response.success && response.data != null) {
        _currentUser = response.data;
        await _storeAuthData();

        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Profile update failed');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Reset provider
  void reset() {
    _clearAuthState();
    _isLoading = false;
    _errorMessage = null;
    _isInitialized = false;
    notifyListeners();
  }
}