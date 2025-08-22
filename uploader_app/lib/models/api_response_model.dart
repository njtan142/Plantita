/// Generic API response wrapper for handling all API responses
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  const ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.errors,
  });

  /// Check if the response has validation errors
  bool get hasErrors => errors != null && errors!.isNotEmpty;

  /// Get the first error message if available
  String? get firstError {
    if (errors == null || errors!.isEmpty) return null;
    final firstKey = errors!.keys.first;
    final errorValue = errors![firstKey];
    if (errorValue is List && errorValue.isNotEmpty) {
      return errorValue.first.toString();
    }
    return errorValue.toString();
  }

  /// Create ApiResponse from successful JSON response
  factory ApiResponse.success(T data, {String? message, int? statusCode}) {
    return ApiResponse<T>(
      success: true,
      data: data,
      message: message,
      statusCode: statusCode,
    );
  }

  /// Create ApiResponse from error JSON response
  factory ApiResponse.error({
    String? message,
    int? statusCode,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse<T>(
      success: false,
      message: message,
      statusCode: statusCode,
      errors: errors,
    );
  }

  /// Create ApiResponse from JSON response
  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final success = json['success'] as bool? ?? (json['status'] == 'success');
    final statusCode = json['status_code'] as int?;

    if (success) {
      final dataJson = json['data'] ?? json['items'];
      final actualDataJson = dataJson is List ? dataJson.first : dataJson;
      final data = actualDataJson != null ? fromJson(actualDataJson as Map<String, dynamic>) : null;
      return ApiResponse<T>.success(
        data as T,
        message: json['message'] as String?,
        statusCode: statusCode,
      );
    } else {
      return ApiResponse<T>.error(
        message: json['message'] as String?,
        statusCode: statusCode,
        errors: json['errors'] as Map<String, dynamic>?,
      );
    }
  }

  @override
  String toString() {
    return 'ApiResponse(success: $success, statusCode: $statusCode, message: $message, hasErrors: $hasErrors)';
  }
}

/// Pagination metadata for list responses
class PaginationMeta {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int perPage;
  final bool hasNextPage;
  final bool hasPrevPage;

  const PaginationMeta({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.perPage,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      currentPage: json['current_page'] as int? ?? 1,
      totalPages: json['total_pages'] as int? ?? 1,
      totalItems: json['total_items'] as int? ?? 0,
      perPage: json['per_page'] as int? ?? 20,
      hasNextPage: json['has_next_page'] as bool? ?? false,
      hasPrevPage: json['has_prev_page'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_page': currentPage,
      'total_pages': totalPages,
      'total_items': totalItems,
      'per_page': perPage,
      'has_next_page': hasNextPage,
      'has_prev_page': hasPrevPage,
    };
  }
}

/// Paginated API response wrapper
class PaginatedResponse<T> {
  final bool success;
  final List<T> items;
  final PaginationMeta meta;
  final String? message;
  final int? statusCode;

  const PaginatedResponse({
    required this.success,
    required this.items,
    required this.meta,
    this.message,
    this.statusCode,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final success = json['success'] as bool? ?? true;
    final statusCode = json['status_code'] as int?;
    final message = json['message'] as String?;

    final itemsJson = json['items'] as List<dynamic>? ?? json['data'] as List<dynamic>? ?? [];
    final items = itemsJson.map((item) => fromJson(item as Map<String, dynamic>)).toList();

    final metaJson = json['meta'] as Map<String, dynamic>? ?? json['pagination'] as Map<String, dynamic>? ?? {};
    final meta = PaginationMeta.fromJson(metaJson);

    return PaginatedResponse<T>(
      success: success,
      items: items,
      meta: meta,
      message: message,
      statusCode: statusCode,
    );
  }
}