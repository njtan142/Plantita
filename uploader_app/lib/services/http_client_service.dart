import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:retry/retry.dart';
import '../models/models.dart';

/// HTTP client service for handling all API requests with authentication and error handling
class HttpClientService {
  final String baseUrl;
  final http.Client _client;
  final Connectivity _connectivity;
  final Duration _timeout;
  final Map<String, String> _defaultHeaders;

  // Authentication token storage
  AuthTokenModel? _currentToken;
  Employee? _currentUser;

  HttpClientService({
    required this.baseUrl,
    http.Client? client,
    Connectivity? connectivity,
    Duration timeout = const Duration(seconds: 30),
    Map<String, String>? defaultHeaders,
  })  : _client = client ?? http.Client(),
        _connectivity = connectivity ?? Connectivity(),
        _timeout = timeout,
        _defaultHeaders = defaultHeaders ?? {};

  /// Current authentication token
  AuthTokenModel? get currentToken => _currentToken;

  /// Current authenticated user
  Employee? get currentUser => _currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _currentToken != null && !_currentToken!.isExpired;

  /// Set authentication token
  void setToken(AuthTokenModel token) {
    _currentToken = token;
  }

  /// Set current user
  void setUser(Employee user) {
    _currentUser = user;
  }

  /// Clear authentication
  void clearAuth() {
    _currentToken = null;
    _currentUser = null;
  }

  /// Build headers for request
  Map<String, String> _buildHeaders({bool includeAuth = true, Map<String, String>? additionalHeaders}) {
    final headers = Map<String, String>.from(_defaultHeaders);

    // Add content type if not specified
    headers.putIfAbsent('Content-Type', () => 'application/json');

    // Add authentication if available and requested
    if (includeAuth && _currentToken != null && !_currentToken!.isExpired) {
      headers['Authorization'] = '${_currentToken!.tokenType} ${_currentToken!.accessToken}';
    }

    // Add additional headers
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }

    return headers;
  }

  /// Check network connectivity
  Future<bool> _hasConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      return true; // Assume connected if we can't check
    }
  }

  /// Execute HTTP request with retry logic and error handling
  Future<http.Response> _executeRequest(
    Future<http.Response> Function() request, {
    bool retryOnFailure = true,
    int maxRetries = 3,
  }) async {
    // Check connectivity first
    if (!await _hasConnectivity()) {
      throw NetworkException('No internet connection');
    }

    try {
      if (retryOnFailure) {
        return await retry(
          () async {
            final response = await request().timeout(_timeout);
            if (response.statusCode == 401 && _currentToken != null) {
              // Token might be expired, try to refresh
              await _handleUnauthorized();
              // Retry with new token
              return await request().timeout(_timeout);
            }
            return response;
          },
          retryIf: (e) => e is http.ClientException || e is TimeoutException,
          maxAttempts: maxRetries,
        );
      } else {
        return await request().timeout(_timeout);
      }
    } catch (e) {
      if (e is TimeoutException) {
        throw NetworkException('Request timeout');
      } else if (e is http.ClientException) {
        throw NetworkException('Network error: ${e.message}');
      } else {
        rethrow;
      }
    }
  }

  /// Handle unauthorized access (token refresh)
  Future<void> _handleUnauthorized() async {
    if (_currentToken?.refreshToken != null) {
      try {
        // This would typically call a refresh endpoint
        // For now, we'll just clear the token
        clearAuth();
      } catch (e) {
        clearAuth();
      }
    } else {
      clearAuth();
    }
  }

  /// GET request
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    bool retryOnFailure = true,
  }) async {
    try {
      // Build URL with query parameters
      final uri = Uri.parse('$baseUrl$path').replace(
        queryParameters: queryParams?.map((key, value) => MapEntry(key, value.toString())),
      );

      final response = await _executeRequest(
        () => _client.get(uri, headers: _buildHeaders(additionalHeaders: headers)),
        retryOnFailure: retryOnFailure,
      );

      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// POST request
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    bool retryOnFailure = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final requestBody = body != null ? jsonEncode(body) : null;

      final response = await _executeRequest(
        () => _client.post(
          uri,
          headers: _buildHeaders(additionalHeaders: headers),
          body: requestBody,
        ),
        retryOnFailure: retryOnFailure,
      );

      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// PUT request
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    bool retryOnFailure = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final requestBody = body != null ? jsonEncode(body) : null;

      final response = await _executeRequest(
        () => _client.put(
          uri,
          headers: _buildHeaders(additionalHeaders: headers),
          body: requestBody,
        ),
        retryOnFailure: retryOnFailure,
      );

      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// DELETE request
  Future<ApiResponse<T>> delete<T>(
    String path, {
    dynamic body,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    bool retryOnFailure = true,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final requestBody = body != null ? jsonEncode(body) : null;

      final response = await _executeRequest(
        () => _client.delete(
          uri,
          headers: _buildHeaders(additionalHeaders: headers),
          body: requestBody,
        ),
        retryOnFailure: retryOnFailure,
      );

      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Multipart file upload
  Future<ApiResponse<T>> uploadFile<T>(
    String path,
    String fieldName,
    List<int> fileBytes,
    String fileName,
    String mimeType, {
    Map<String, String>? fields,
    Map<String, String>? headers,
    T Function(Map<String, dynamic>)? fromJson,
    Function(double)? onProgress,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers.addAll(_buildHeaders(includeAuth: true, additionalHeaders: headers));

      // Add file
      request.files.add(http.MultipartFile.fromBytes(
        fieldName,
        fileBytes,
        filename: fileName,
        contentType: MediaType.parse(mimeType),
      ));

      // Add additional fields
      if (fields != null) {
        fields.forEach((key, value) {
          request.fields[key] = value;
        });
      }

      // Send request with progress tracking
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response, fromJson);
    } catch (e) {
      return ApiResponse.error(message: e.toString());
    }
  }

  /// Handle HTTP response and convert to ApiResponse
  ApiResponse<T> _handleResponse<T>(http.Response response, T Function(Map<String, dynamic>)? fromJson) {
    try {
      final statusCode = response.statusCode;
      final responseBody = response.body.isNotEmpty ? jsonDecode(response.body) : {};

      if (statusCode >= 200 && statusCode < 300) {
        // Success response
        if (fromJson != null && responseBody is Map<String, dynamic>) {
          return ApiResponse.success(
            fromJson(responseBody),
            statusCode: statusCode,
            message: responseBody['message'] as String?,
          );
        } else {
          return ApiResponse.success(
            responseBody as T,
            statusCode: statusCode,
            message: (responseBody is Map<String, dynamic>) ? responseBody['message'] as String? : null,
          );
        }
      } else {
        // Error response
        String? message;
        Map<String, dynamic>? errors;

        if (responseBody is Map<String, dynamic>) {
          message = responseBody['message'] as String?;
          errors = responseBody['errors'] as Map<String, dynamic>?;
        } else if (responseBody != null) {
          message = responseBody.toString();
        }

        message ??= _getDefaultErrorMessage(statusCode);

        return ApiResponse.error(
          message: message,
          statusCode: statusCode,
          errors: errors,
        );
      }
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to parse response: ${e.toString()}',
        statusCode: response.statusCode,
      );
    }
  }

  /// Get default error message for status code
  String _getDefaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Bad request';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not found';
      case 422:
        return 'Validation failed';
      case 429:
        return 'Too many requests';
      case 500:
        return 'Internal server error';
      case 502:
        return 'Bad gateway';
      case 503:
        return 'Service unavailable';
      default:
        return 'Request failed with status $statusCode';
    }
  }

  /// Close the HTTP client
  void dispose() {
    _client.close();
  }
}

/// Custom exception for network-related errors
class NetworkException implements Exception {
  final String message;
  const NetworkException(this.message);

  @override
  String toString() => message;
}