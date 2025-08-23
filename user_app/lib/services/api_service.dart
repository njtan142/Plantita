
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async'; // Import for TimeoutException

class ApiService {
  final String _baseUrl = "https://api.example.com"; // Replace with your actual API base URL
  final int _maxRetries = 3;
  final Duration _timeout = const Duration(seconds: 10);

  Future<Map<String, dynamic>> _sendRequest(Future<http.Response> Function() request) async {
    for (int i = 0; i < _maxRetries; i++) {
      try {
        final response = await request().timeout(_timeout);
        return _handleResponse(response);
      } on TimeoutException {
        if (i == _maxRetries - 1) {
          throw Exception('Request timed out after $_maxRetries retries.');
        }
        await Future.delayed(const Duration(seconds: 2)); // Wait before retrying
      } catch (e) {
        rethrow; // Re-throw other exceptions immediately
      }
    }
    throw Exception('Failed to send request after $_maxRetries retries.'); // Should not be reached
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    return _sendRequest(() => http.get(Uri.parse('$_baseUrl/$endpoint')));
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> data) async {
    return _sendRequest(
      () => http.post(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      ),
    );
  }

  Future<Map<String, dynamic>> put(String endpoint, Map<String, dynamic> data) async {
    return _sendRequest(
      () => http.put(
        Uri.parse('$_baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      ),
    );
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    return _sendRequest(() => http.delete(Uri.parse('$_baseUrl/$endpoint')));
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else if (response.statusCode == 400) {
      throw Exception('Bad Request: ${response.body}');
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid credentials.');
    } else if (response.statusCode == 403) {
      throw Exception('Forbidden: You don\'t have permission to access this resource.');
    } else if (response.statusCode == 404) {
      throw Exception('Not Found: The requested resource was not found.');
    } else if (response.statusCode == 500) {
      throw Exception('Internal Server Error: ${response.body}');
    } else {
      throw Exception('Failed to load data: Status code ${response.statusCode} - ${response.body}');
    }
  }
}

