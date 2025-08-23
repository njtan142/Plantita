
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:user_app/services/api_service.dart';
import 'package:user_app/services/auth_service.dart';

// Create a MockApiService using Mockito
class MockApiService extends Mock implements ApiService {}

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      authService = AuthService(mockApiService);
    });

    test('login returns true on successful authentication', () async {
      when(mockApiService.post('auth/login', any))
          .thenAnswer((_) async => {'token': 'some_token'});

      final result = await authService.login('testuser', 'password');
      expect(result, true);
    });

    test('login returns false on failed authentication', () async {
      when(mockApiService.post('auth/login', any))
          .thenAnswer((_) async => {'message': 'Invalid credentials'});

      final result = await authService.login('wronguser', 'wrongpass');
      expect(result, false);
    });

    test('login returns false on API error', () async {
      when(mockApiService.post('auth/login', any))
          .thenThrow(Exception('Network error'));

      final result = await authService.login('testuser', 'password');
      expect(result, false);
    });

    test('logout performs necessary cleanup', () async {
      // No specific return value to check for logout, just ensure it runs without error
      await authService.logout();
      // Verify that no errors occurred
      verifyNever(mockApiService.post(any, any)); // Ensure no unexpected API calls
    });
  });
}
