import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:user_app/services/api_service.dart';
import 'package:user_app/services/auth_service.dart';
import 'package:user_app/config/environment_config.dart';
import 'package:user_app/main.dart';

@GenerateMocks([http.Client, AuthService, EnvironmentConfig])
import 'api_service_test.mocks.dart';

void main() {
  group('ApiService', () {
    late ApiService apiService;
    late MockClient mockClient;
    late MockAuthService mockAuthService;
    late MockEnvironmentConfig mockEnvironmentConfig;

    const String baseUrl = 'https://api.example.com';
    const String endpoint = 'test-endpoint';

    setUp(() {
      mockClient = MockClient();
      mockAuthService = MockAuthService();
      mockEnvironmentConfig = MockEnvironmentConfig();

      // Configure mock env config
      when(mockEnvironmentConfig.baseUrl).thenReturn(baseUrl);

      // Configure mock auth service
      when(mockAuthService.getToken()).thenReturn('test_token');

      // Setup GetIt for the ApiService constructor
      getIt.reset();
      getIt.registerSingleton<EnvironmentConfig>(mockEnvironmentConfig);
      getIt.registerSingleton<AuthService>(mockAuthService);

      apiService = ApiService(client: mockClient);
    });

    test('get request returns data on success (200 OK)', () async {
      when(mockClient.send(any)).thenAnswer((_) async {
        final response = http.Response('{"key": "value"}', 200);
        return http.StreamedResponse(
            Stream.value(response.bodyBytes), response.statusCode);
      });

      final response = await apiService.get(endpoint);
      expect(response, {'key': 'value'});

      // Verify request interceptor attached auth token
      final captured = verify(mockClient.send(captureAny)).captured;
      final request = captured.first as http.Request;
      expect(request.method, 'GET');
      expect(request.url.toString(), '$baseUrl/$endpoint');
      expect(request.headers['Authorization'], 'Bearer test_token');
    });

    test('post request returns data on success (201 Created)', () async {
      when(mockClient.send(any)).thenAnswer((_) async {
        final response = http.Response('{"id": 1}', 201);
        return http.StreamedResponse(
            Stream.value(response.bodyBytes), response.statusCode);
      });

      final payload = {'name': 'test'};
      final response = await apiService.post(endpoint, payload);
      expect(response, {'id': 1});

      final captured = verify(mockClient.send(captureAny)).captured;
      final request = captured.first as http.Request;
      expect(request.method, 'POST');
      expect(request.url.toString(), '$baseUrl/$endpoint');
      expect(request.headers['Content-Type'], 'application/json');
      expect(request.body, '{"name":"test"}');
    });

    test('put request returns data on success (200 OK)', () async {
      when(mockClient.send(any)).thenAnswer((_) async {
        final response = http.Response('{"success": true}', 200);
        return http.StreamedResponse(
            Stream.value(response.bodyBytes), response.statusCode);
      });

      final payload = {'name': 'updated'};
      final response = await apiService.put(endpoint, payload);
      expect(response, {'success': true});

      final captured = verify(mockClient.send(captureAny)).captured;
      final request = captured.first as http.Request;
      expect(request.method, 'PUT');
      expect(request.url.toString(), '$baseUrl/$endpoint');
      expect(request.headers['Content-Type'], 'application/json');
      expect(request.body, '{"name":"updated"}');
    });

    test('delete request returns data on success (200 OK)', () async {
      when(mockClient.send(any)).thenAnswer((_) async {
        final response = http.Response('{"deleted": true}', 200);
        return http.StreamedResponse(
            Stream.value(response.bodyBytes), response.statusCode);
      });

      final response = await apiService.delete(endpoint);
      expect(response, {'deleted': true});

      final captured = verify(mockClient.send(captureAny)).captured;
      final request = captured.first as http.Request;
      expect(request.method, 'DELETE');
      expect(request.url.toString(), '$baseUrl/$endpoint');
    });

    test('throws exception on 400 Bad Request', () async {
      when(mockClient.send(any)).thenAnswer((_) async {
        final response = http.Response('Invalid data', 400);
        return http.StreamedResponse(
            Stream.value(response.bodyBytes), response.statusCode);
      });

      expect(
        () => apiService.get(endpoint),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Bad Request: Invalid data'),
        )),
      );
    });

    test('throws exception on 401 Unauthorized', () async {
      when(mockClient.send(any)).thenAnswer((_) async {
        final response = http.Response('Token expired', 401);
        return http.StreamedResponse(
            Stream.value(response.bodyBytes), response.statusCode);
      });

      expect(
        () => apiService.get(endpoint),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Unauthorized: Invalid credentials.'),
        )),
      );
    });

    test('throws exception on 403 Forbidden', () async {
      when(mockClient.send(any)).thenAnswer((_) async {
        final response = http.Response('No access', 403);
        return http.StreamedResponse(
            Stream.value(response.bodyBytes), response.statusCode);
      });

      expect(
        () => apiService.get(endpoint),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Forbidden: You don\'t have permission to access this resource.'),
        )),
      );
    });

    test('throws exception on 404 Not Found', () async {
      when(mockClient.send(any)).thenAnswer((_) async {
        final response = http.Response('Not found', 404);
        return http.StreamedResponse(
            Stream.value(response.bodyBytes), response.statusCode);
      });

      expect(
        () => apiService.get(endpoint),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Not Found: The requested resource was not found.'),
        )),
      );
    });

    test('throws exception on 500 Internal Server Error', () async {
      when(mockClient.send(any)).thenAnswer((_) async {
        final response = http.Response('Server down', 500);
        return http.StreamedResponse(
            Stream.value(response.bodyBytes), response.statusCode);
      });

      expect(
        () => apiService.get(endpoint),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Internal Server Error: Server down'),
        )),
      );
    });

    test('throws generic exception on other error status codes', () async {
      when(mockClient.send(any)).thenAnswer((_) async {
        final response = http.Response('Unknown Error', 418); // I am a teapot
        return http.StreamedResponse(
            Stream.value(response.bodyBytes), response.statusCode);
      });

      expect(
        () => apiService.get(endpoint),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to load data: Status code 418 - Unknown Error'),
        )),
      );
    });

    test('retries request on TimeoutException and eventually throws if all fail', () async {
      // Stub the mock client to always throw a TimeoutException
      when(mockClient.send(any)).thenThrow(TimeoutException('Request timed out'));

      final startTime = DateTime.now();

      // Expecting it to throw the exception after all retries fail
      await expectLater(
        () => apiService.get(endpoint),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Request timed out after 3 retries.'),
        )),
      );

      // Verify that send was called exactly 3 times (the max retries)
      verify(mockClient.send(any)).called(3);

      final endTime = DateTime.now();
      // Total delay should be roughly (2 seconds delay) * (3 - 1 retries) = 4 seconds. Let's say at least 3 seconds to be safe.
      expect(endTime.difference(startTime).inSeconds, greaterThanOrEqualTo(3));
    });

    test('retries request on TimeoutException and succeeds on retry', () async {
      int attempt = 0;
      when(mockClient.send(any)).thenAnswer((_) async {
        attempt++;
        if (attempt < 3) {
           throw TimeoutException('Request timed out');
        }
        final response = http.Response('{"success": true}', 200);
        return http.StreamedResponse(
            Stream.value(response.bodyBytes), response.statusCode);
      });

      final response = await apiService.get(endpoint);
      expect(response, {'success': true});
      verify(mockClient.send(any)).called(3);
    });
  });
}
