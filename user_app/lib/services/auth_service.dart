import 'package:flutter/foundation.dart';
import 'package:user_app/services/api_service.dart';
import 'package:user_app/utils/logger.dart';
import 'package:user_app/services/cache_service.dart';
import 'package:user_app/main.dart';

class AuthService {
  final ApiService _apiService;
  static const String _authTokenKey = 'authToken';
  
  // For testing
  dynamic _mockUser;

  AuthService(this._apiService);

  CacheService get _cacheService => getIt<CacheService>();

  bool get isAuthenticated => _cacheService.getData(_authTokenKey) != null;

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.post('auth/login', {
        'username': username,
        'password': password,
      });
      // Assuming the API returns a token or success status
      if (response['token'] != null) {
        final token = response['token'] as String;
        await _cacheService.saveData(_authTokenKey, token);
        logger.i('Login successful: $token');
        return true;
      } else {
        logger.w('Login failed: ${response['message']}');
        return false;
      }
    } catch (e) {
      logger.e('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _cacheService.removeData(_authTokenKey);
    logger.i('User logged out.');
  }

  String? getToken() {
    return _cacheService.getData(_authTokenKey);
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      final response = await _apiService.post('auth/register', {
        'username': username,
        'email': email,
        'password': password,
      });
      if (response['success'] == true) {
        logger.i('Registration successful.');
        return true;
      } else {
        logger.w('Registration failed: ${response['message']}');
        return false;
      }
    } catch (e) {
      logger.e('Registration error: $e');
      return false;
    }
  }

  @visibleForTesting
  void setUserForTesting(dynamic user) {
    _mockUser = user;
  }
  
  @visibleForTesting
  dynamic get mockUser => _mockUser;
}
