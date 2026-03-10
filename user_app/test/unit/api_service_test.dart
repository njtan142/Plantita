
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:user_app/services/api_service.dart';
import 'package:user_app/main.dart';
import 'package:user_app/config/environment_config.dart';
import 'package:user_app/services/auth_service.dart';

// Create a MockClient using Mockito
class MockClient extends Mock implements http.Client {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return super.noSuchMethod(
      Invocation.method(#send, [request]),
      returnValue: Future.value(http.StreamedResponse(Stream.empty(), 200)),
    );
  }
}

// Create a MockAuthService
class MockAuthService extends Mock implements AuthService {
  @override
  String? getToken() => 'mock_token';
}

void main() {
  group('ApiService', () {
    late ApiService apiService;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      getIt.registerSingleton<EnvironmentConfig>(EnvironmentConfig(baseUrl: 'https://api.example.com', apiKey: 'test'));
      getIt.registerSingleton<AuthService>(MockAuthService());

      apiService = ApiService(client: mockClient);
    });

    tearDown(() {
      getIt.reset();
    });

    test('get request returns data on success', () async {
      when(mockClient.send(any)).thenAnswer((_) async {
        return http.StreamedResponse(
            Stream.value('{"key": "value"}'.codeUnits), 200);
      });

      final response = await apiService.get('test');
      expect(response, {'key': 'value'});
    });

    test('post request returns data on success', () async {
      when(mockClient.send(any)).thenAnswer((_) async {
        return http.StreamedResponse(
            Stream.value('{"key": "posted"}'.codeUnits), 200);
      });

      final response = await apiService.post('test', {'data': 'value'});
      expect(response, {'key': 'posted'});
    });

    test('put request returns data on success', () async {
      when(mockClient.send(any)).thenAnswer((_) async {
        return http.StreamedResponse(
            Stream.value('{"key": "updated"}'.codeUnits), 200);
      });

      final response = await apiService.put('test', {'data': 'new_value'});
      expect(response, {'key': 'updated'});
    });

    test('delete request returns data on success', () async {
      when(mockClient.send(any)).thenAnswer((_) async {
        return http.StreamedResponse(
            Stream.value('{"key": "deleted"}'.codeUnits), 200);
      });

      final response = await apiService.delete('test');
      expect(response, {'key': 'deleted'});
    });

    test('request throws exception on 400', () {
      expect(
        () => apiService._handleResponse(http.Response('Bad Request data', 400)),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Bad Request: Bad Request data'),
        )),
      );
    });

    test('request throws exception on 401', () {
      expect(
        () => apiService._handleResponse(http.Response('', 401)),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Unauthorized: Invalid credentials.'),
        )),
      );
    });

    test('request throws exception on 403', () {
      expect(
        () => apiService._handleResponse(http.Response('', 403)),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Forbidden: You don\'t have permission to access this resource.'),
        )),
      );
    });

    test('request throws exception on 404', () {
      expect(
        () => apiService._handleResponse(http.Response('Not Found', 404)),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Not Found: The requested resource was not found.'),
        )),
      );
    });

    test('request throws exception on 500', () {
      expect(
        () => apiService._handleResponse(http.Response('Server Error', 500)),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Internal Server Error: Server Error'),
        )),
      );
    });

    test('request throws generic exception on other error codes', () {
      expect(
        () => apiService._handleResponse(http.Response('Gateway Timeout', 504)),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Failed to load data: Status code 504 - Gateway Timeout'),
        )),
      );
    });
  });
}
