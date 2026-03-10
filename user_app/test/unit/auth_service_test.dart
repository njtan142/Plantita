import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:user_app/services/api_service.dart';
import 'package:user_app/services/auth_service.dart';
import 'package:user_app/services/cache_service.dart';
import 'package:user_app/main.dart'; // Import getIt

// Create a MockApiService using Mockito
class MockApiService extends Mock implements ApiService {}
class MockCacheService extends Mock implements CacheService {}

void main() {
  group('AuthService', () {
    late AuthService authService;
    late MockApiService mockApiService;
    late MockCacheService mockCacheService;

    setUp(() {
      mockApiService = MockApiService();
      mockCacheService = MockCacheService();

      // Register mockCacheService in getIt
      if (getIt.isRegistered<CacheService>()) {
        getIt.unregister<CacheService>();
      }
      getIt.registerSingleton<CacheService>(mockCacheService);

      authService = AuthService(mockApiService);
    });

    tearDown(() {
      if (getIt.isRegistered<CacheService>()) {
        getIt.unregister<CacheService>();
      }
    });

    test('isAuthenticated returns true when token is in cache', () {
      when(mockCacheService.getData('authToken')).thenReturn('some_token');
      expect(authService.isAuthenticated, isTrue);
    });

    test('isAuthenticated returns false when token is not in cache', () {
      when(mockCacheService.getData('authToken')).thenReturn(null);
      expect(authService.isAuthenticated, isFalse);
    });

    test('login returns true on successful authentication and saves token', () async {
      when(mockApiService.post('auth/login', any))
          .thenAnswer((_) async => {'token': 'some_token'});
      when(mockCacheService.saveData('authToken', 'some_token'))
          .thenAnswer((_) async => true);

      final result = await authService.login('testuser', 'password');
      expect(result, true);
      verify(mockCacheService.saveData('authToken', 'some_token')).called(1);
    });

    test('login returns false on failed authentication', () async {
      when(mockApiService.post('auth/login', any))
          .thenAnswer((_) async => {'message': 'Invalid credentials'});

      final result = await authService.login('wronguser', 'wrongpass');
      expect(result, false);
      verifyNever(mockCacheService.saveData(any, any));
    });

    test('login returns false on API error', () async {
      when(mockApiService.post('auth/login', any))
          .thenThrow(Exception('Network error'));

      final result = await authService.login('testuser', 'password');
      expect(result, false);
      verifyNever(mockCacheService.saveData(any, any));
    });

    test('logout performs necessary cleanup', () async {
      when(mockCacheService.removeData('authToken')).thenAnswer((_) async => true);

      await authService.logout();

      verify(mockCacheService.removeData('authToken')).called(1);
    });

    test('getToken returns token from cache', () {
      when(mockCacheService.getData('authToken')).thenReturn('my_cached_token');
      expect(authService.getToken(), 'my_cached_token');
    });

    test('getToken returns null if token not in cache', () {
      when(mockCacheService.getData('authToken')).thenReturn(null);
      expect(authService.getToken(), isNull);
    });

    test('register returns true on successful registration', () async {
      when(mockApiService.post('auth/register', any))
          .thenAnswer((_) async => {'success': true});

      final result = await authService.register('testuser', 'test@test.com', 'password');
      expect(result, isTrue);
    });

    test('register returns false on failed registration', () async {
      when(mockApiService.post('auth/register', any))
          .thenAnswer((_) async => {'success': false, 'message': 'Username taken'});

      final result = await authService.register('testuser', 'test@test.com', 'password');
      expect(result, isFalse);
    });

    test('register returns false on API error', () async {
      when(mockApiService.post('auth/register', any))
          .thenThrow(Exception('Network error'));

      final result = await authService.register('testuser', 'test@test.com', 'password');
      expect(result, isFalse);
    });
  });
}
