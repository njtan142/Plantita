
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:user_app/services/auth_service.dart';
import 'package:user_app/state_management/auth_provider.dart';

// Create a MockAuthService using Mockito
class MockAuthService extends Mock implements AuthService {}

void main() {
  group('AuthProvider', () {
    late AuthProvider authProvider;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      authProvider = AuthProvider(mockAuthService);
    });

    test('isAuthenticated is false initially', () {
      expect(authProvider.isAuthenticated, false);
    });

    test('login sets isAuthenticated to true on success', () async {
      when(mockAuthService.login('testuser', 'password')).thenAnswer((_) async => true);

      await authProvider.login('testuser', 'password');
      expect(authProvider.isAuthenticated, true);
    });

    test('login sets isAuthenticated to false on failure', () async {
      when(mockAuthService.login('wronguser', 'wrongpass')).thenAnswer((_) async => false);

      await authProvider.login('wronguser', 'wrongpass');
      expect(authProvider.isAuthenticated, false);
    });

    test('logout sets isAuthenticated to false', () async {
      // Simulate a logged-in state
      when(mockAuthService.login('testuser', 'password')).thenAnswer((_) async => true);
      await authProvider.login('testuser', 'password');
      expect(authProvider.isAuthenticated, true);

      await authProvider.logout();
      expect(authProvider.isAuthenticated, false);
    });
  });
}
