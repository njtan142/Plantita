
import 'package:user_app/services/api_service.dart';

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
        // Store token securely (e.g., using shared_preferences)
        print('Login successful: ${response['token']}');
        return true;
      } else {
        print('Login failed: ${response['message']}');
        return false;
      }
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    // Clear stored token and perform any necessary cleanup
    print('User logged out.');
  }

  // Future<bool> register(String username, String email, String password) async {
  //   try {
  //     final response = await _apiService.post('auth/register', {
  //       'username': username,
  //       'email': email,
  //       'password': password,
  //     });
  //     if (response['success'] == true) {
  //       print('Registration successful.');
  //       return true;
  //     } else {
  //       print('Registration failed: ${response['message']}');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Registration error: $e');
  //     return false;
  //   }
  // }
}
