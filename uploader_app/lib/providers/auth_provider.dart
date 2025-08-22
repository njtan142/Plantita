import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/user_model.dart';
import '../models/auth_token_model.dart';
import '../services/auth_service.dart';
import '../constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  UserModel? _currentUser;
  AuthTokenModel? _authToken;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  AuthTokenModel? get authToken => _authToken;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null && _authToken != null && !_isTokenExpired;
  bool get isInitialized => _isInitialized;
  bool get _isTokenExpired {
    if (_authToken == null) return true;
    return JwtDecoder.isExpired(_authToken!.accessToken);
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
        final user = UserModel.fromJson(userString);

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
      final authData = await _authService.login(username, password);

      _authToken = authData['token'];
      _currentUser = authData['user'];

      // Store auth data securely
      await _storeAuthData();

      _setLoading(false);
      notifyListeners();
      return true;
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
      final authData = await _authService.register(username, email, password, firstName, lastName);

      _authToken = authData['token'];
      _currentUser = authData['user'];

      // Store auth data securely
      await _storeAuthData();

      _setLoading(false);
      notifyListeners();
      return true;
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
      if (_authToken != null) {
        await _authService.logout(_authToken!.accessToken);
      }
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
      final newToken = await _authService.refreshToken(_authToken!.refreshToken);
      _authToken = newToken;
      await _storeAuthData();
      notifyListeners();
      return true;
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
          value: _currentUser!.toJson(),
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
      final updatedUser = await _authService.updateProfile(_authToken!.accessToken, updates);
      _currentUser = updatedUser;
      await _storeAuthData();

      _setLoading(false);
      notifyListeners();
      return true;
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