
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async'; // Import for TimeoutException
import 'package:user_app/utils/logger.dart'; // Import the logger
import 'package:user_app/main.dart'; // Import getIt
import 'package:user_app/config/environment_config.dart';

class ApiService {
  final String _baseUrl;

  ApiService() : _baseUrl = getIt<EnvironmentConfig>().baseUrl;
  final int _maxRetries = 3;
  final Duration _timeout = const Duration(seconds: 10);

  Future<Map<String, dynamic>> _sendRequest(Future<http.Response> Function() request) async {
    for (int i = 0; i < _maxRetries; i++) {
      try {
        final response = await request().timeout(_timeout);
        logger.d('API Response: ${response.statusCode} - ${response.body}');
        return _handleResponse(response);
      } on TimeoutException {
        logger.w('Request timed out. Retrying...');
        if (i == _maxRetries - 1) {
          throw Exception('Request timed out after $_maxRetries retries.');
        }
        await Future.delayed(const Duration(seconds: 2)); // Wait before retrying
      } catch (e) {
        logger.e('API Request Error: $e');
        rethrow; // Re-throw other exceptions immediately
      }
    }
    throw Exception('Failed to send request after $_maxRetries retries.'); // Should not be reached
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    logger.d('GET: $_baseUrl/$endpoint');
    return _sendRequest(() => http.get(Uri.parse('$_baseUrl/$endpoint')));
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    logger.d('POST: $_baseUrl/$endpoint - Body: $data');
    return _sendRequest(
      () => http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      ),
    );
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    logger.d('PUT: $_baseUrl/$endpoint - Body: $data');
    return _sendRequest(
      () => http.put(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      ),
    );
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    logger.d('DELETE: $_baseUrl/$endpoint');
    return _sendRequest(() => http.delete(Uri.parse('$_baseUrl/$endpoint')));
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
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

