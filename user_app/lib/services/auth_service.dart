
import 'package:user_app/services/api_service.dart';
import 'package:user_app/utils/logger.dart'; // Import the logger

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<bool> login(String username, String password) async {
    try {
      final response = await _apiService.post('auth/login', {
        'username': username,
        'password': password,
      });
      // Assuming the API returns a token or success status
      if (response['token'] != null) {
        logger.i('Login successful: ${response['token']}');
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
    // Clear stored token and perform any necessary cleanup
    logger.i('User logged out.');
  }

  // Future<bool> register(String username, String email, String password) async {
  //   try {
  //     final response = await _apiService.post('auth/register', {
  //       'username': username,
  //       'email': email,
  //       'password': password,
  //     });
  //     if (response['success'] == true) {
  //       logger.i('Registration successful.');
  //       return true;
  //     } else {
  //       logger.w('Registration failed: ${response['message']}');
  //       return false;
  //     }
  //   } catch (e) {
  //     logger.e('Registration error: $e');
  //     return false;
  //   }
  // }
}
