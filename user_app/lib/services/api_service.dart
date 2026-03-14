import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:user_app/utils/logger.dart';
import 'package:user_app/main.dart';
import 'package:user_app/config/environment_config.dart';
import 'package:user_app/services/auth_service.dart';

class ApiService {
  final String _baseUrl;
  late final AuthService _authService;
  final http.Client _client;

  ApiService({http.Client? client})
      : _baseUrl = getIt<EnvironmentConfig>().baseUrl,
        _client = client ?? http.Client();

  final int _maxRetries = 3;
  final Duration _timeout = const Duration(seconds: 10);

  Future<http.BaseRequest> _requestInterceptor(http.BaseRequest request) async {
    logger.d('Intercepting Request: ${request.method} ${request.url}');
    final authService = getIt<AuthService>();
    String? token = authService.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    return request;
  }

  Future<http.Response> _responseInterceptor(http.Response response) async {
    logger.d('Intercepting Response: ${response.statusCode} ${response.request?.url}');
    return response;
  }

  Future<Map<String, dynamic>> _sendRequestWithInterceptor(http.Request originalRequest) async {
    for (int i = 0; i < _maxRetries; i++) {
      try {
        final client = _client;
        final interceptedRequest = await _requestInterceptor(originalRequest);
        logger.d('Sending Request: ${interceptedRequest.method} ${interceptedRequest.url}');

        final streamedResponse = await client.send(interceptedRequest).timeout(_timeout);
        final response = await http.Response.fromStream(streamedResponse);

        final interceptedResponse = await _responseInterceptor(response);
        logger.d('API Response: ${interceptedResponse.statusCode} - ${interceptedResponse.body}');
        return _handleResponse(interceptedResponse);
      } on TimeoutException {
        logger.w('Request timed out. Retrying...');
        if (i == _maxRetries - 1) {
          throw Exception('Request timed out after $_maxRetries retries.');
        }
        await Future.delayed(const Duration(seconds: 2));
      } catch (e) {
        logger.e('API Request Error: $e');
        rethrow;
      }
    }
    throw Exception('Failed to send request after $_maxRetries retries.');
  }

  Future<Map<String, dynamic>> get(String endpoint, {Map<String, dynamic>? queryParams}) async {
    Uri uri = Uri.parse('$_baseUrl/$endpoint');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams.map((key, value) => MapEntry(key, value.toString())));
    }
    final request = http.Request('GET', uri);
    return _sendRequestWithInterceptor(request);
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    final request = http.Request('POST', uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = json.encode(data);
    return _sendRequestWithInterceptor(request);
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    final request = http.Request('PUT', uri)
      ..headers['Content-Type'] = 'application/json'
      ..body = json.encode(data);
    return _sendRequestWithInterceptor(request);
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    final uri = Uri.parse('$_baseUrl/$endpoint');
    final request = http.Request('DELETE', uri);
    return _sendRequestWithInterceptor(request);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      return json.decode(response.body);
    } else if (response.statusCode == 400) {
      logger.e('Bad Request: ${response.body}');
      throw Exception('Bad Request: ${response.body}');
    } else if (response.statusCode == 401) {
      logger.e('Unauthorized: Invalid credentials.');
      throw Exception('Unauthorized: Invalid credentials.');
    } else if (response.statusCode == 403) {
      logger.e('Forbidden: You don\'t have permission to access this resource.');
      throw Exception('Forbidden: You don\'t have permission to access this resource.');
    } else if (response.statusCode == 404) {
      logger.e('Not Found: The requested resource was not found.');
      throw Exception('Not Found: The requested resource was not found.');
    } else if (response.statusCode == 500) {
      logger.e('Internal Server Error: ${response.body}');
      throw Exception('Internal Server Error: ${response.body}');
    } else {
      logger.e('Failed to load data: Status code ${response.statusCode} - ${response.body}');
      throw Exception('Failed to load data: Status code ${response.statusCode} - ${response.body}');
    }
  }
}
