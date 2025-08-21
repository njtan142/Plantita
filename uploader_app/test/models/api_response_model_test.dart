import 'package:flutter_test/flutter_test.dart';
import '../../lib/models/models.dart';

void main() {
  group('ApiResponse Tests', () {
    test('ApiResponse.success creates successful response', () {
      final data = {'test': 'data'};
      final response = ApiResponse.success(data, message: 'Success', statusCode: 200);

      expect(response.success, true);
      expect(response.data, data);
      expect(response.message, 'Success');
      expect(response.statusCode, 200);
      expect(response.errors, null);
      expect(response.hasErrors, false);
    });

    test('ApiResponse.error creates error response', () {
      final errors = {'email': ['Email is required']};
      final response = ApiResponse.error(
        message: 'Validation failed',
        statusCode: 422,
        errors: errors,
      );

      expect(response.success, false);
      expect(response.data, null);
      expect(response.message, 'Validation failed');
      expect(response.statusCode, 422);
      expect(response.errors, errors);
      expect(response.hasErrors, true);
    });

    test('ApiResponse.hasErrors returns true when errors exist', () {
      final response = ApiResponse.error(
        errors: {'field': ['error']},
      );

      expect(response.hasErrors, true);
    });

    test('ApiResponse.hasErrors returns false when no errors', () {
      final response = ApiResponse.success('data');

      expect(response.hasErrors, false);
    });

    test('ApiResponse.firstError returns first error message', () {
      final response = ApiResponse.error(
        errors: {
          'email': ['Email is required', 'Email format is invalid'],
          'password': ['Password is too short']
        },
      );

      expect(response.firstError, 'Email is required');
    });

    test('ApiResponse.firstError returns null when no errors', () {
      final response = ApiResponse.success('data');

      expect(response.firstError, null);
    });

    test('ApiResponse.firstError handles list errors correctly', () {
      final response = ApiResponse.error(
        errors: {
          'field': ['First error', 'Second error']
        },
      );

      expect(response.firstError, 'First error');
    });

    test('ApiResponse.firstError handles string errors correctly', () {
      final response = ApiResponse.error(
        errors: {
          'field': 'String error message'
        },
      );

      expect(response.firstError, 'String error message');
    });

    test('ApiResponse.fromJson creates success response from JSON', () {
      final json = {
        'success': true,
        'data': {'id': 1, 'name': 'Test'},
        'message': 'Operation successful',
        'status_code': 200,
      };

      final response = ApiResponse.fromJson(json, (data) => User.fromJson(data as Map<String, dynamic>));

      expect(response.success, true);
      expect(response.data, isA<User>());
      expect(response.message, 'Operation successful');
      expect(response.statusCode, 200);
    });

    test('ApiResponse.fromJson creates error response from JSON', () {
      final json = {
        'success': false,
        'message': 'Validation failed',
        'status_code': 422,
        'errors': {
          'email': ['Email is required']
        },
      };

      final response = ApiResponse.fromJson(json, (data) => User.fromJson(data as Map<String, dynamic>));

      expect(response.success, false);
      expect(response.data, null);
      expect(response.message, 'Validation failed');
      expect(response.statusCode, 422);
      expect(response.errors, {'email': ['Email is required']});
    });

    test('ApiResponse.fromJson handles alternative success field', () {
      final json = {
        'status': 'success',
        'data': {'id': 1, 'name': 'Test'},
      };

      final response = ApiResponse.fromJson(json, (data) => User.fromJson(data as Map<String, dynamic>));

      expect(response.success, true);
    });

    test('ApiResponse.fromJson handles alternative data field', () {
      final json = {
        'success': true,
        'items': [{'id': 1, 'name': 'Test'}],
      };

      final response = ApiResponse.fromJson(json, (data) => User.fromJson(data as Map<String, dynamic>));

      expect(response.success, true);
    });

    test('ApiResponse.toString returns correct string representation', () {
      final response = ApiResponse.success('test', message: 'Success', statusCode: 200);

      final toString = response.toString();

      expect(toString, 'ApiResponse(success: true, statusCode: 200, message: Success, hasErrors: false)');
    });
  });

  group('PaginationMeta Tests', () {
    test('PaginationMeta.fromJson creates PaginationMeta correctly', () {
      final json = {
        'current_page': 2,
        'total_pages': 10,
        'total_items': 100,
        'per_page': 10,
        'has_next_page': true,
        'has_prev_page': true,
      };

      final meta = PaginationMeta.fromJson(json);

      expect(meta.currentPage, 2);
      expect(meta.totalPages, 10);
      expect(meta.totalItems, 100);
      expect(meta.perPage, 10);
      expect(meta.hasNextPage, true);
      expect(meta.hasPrevPage, true);
    });

    test('PaginationMeta.fromJson handles null values', () {
      final json = {};

      final meta = PaginationMeta.fromJson(json);

      expect(meta.currentPage, 1);
      expect(meta.totalPages, 1);
      expect(meta.totalItems, 0);
      expect(meta.perPage, 20);
      expect(meta.hasNextPage, false);
      expect(meta.hasPrevPage, false);
    });

    test('PaginationMeta.toJson converts PaginationMeta to JSON', () {
      final meta = PaginationMeta(
        currentPage: 2,
        totalPages: 10,
        totalItems: 100,
        perPage: 10,
        hasNextPage: true,
        hasPrevPage: true,
      );

      final json = meta.toJson();

      expect(json['current_page'], 2);
      expect(json['total_pages'], 10);
      expect(json['total_items'], 100);
      expect(json['per_page'], 10);
      expect(json['has_next_page'], true);
      expect(json['has_prev_page'], true);
    });
  });

  group('PaginatedResponse Tests', () {
    test('PaginatedResponse.fromJson creates PaginatedResponse correctly', () {
      final json = {
        'success': true,
        'data': [
          {'id': 1, 'username': 'user1', 'email': 'user1@example.com', 'first_name': 'User', 'last_name': 'One', 'is_active': true, 'created_at': '2024-01-01T00:00:00Z'},
          {'id': 2, 'username': 'user2', 'email': 'user2@example.com', 'first_name': 'User', 'last_name': 'Two', 'is_active': true, 'created_at': '2024-01-01T00:00:00Z'},
        ],
        'meta': {
          'current_page': 1,
          'total_pages': 5,
          'total_items': 50,
          'per_page': 10,
          'has_next_page': true,
          'has_prev_page': false,
        },
        'message': 'Users retrieved successfully',
        'status_code': 200,
      };

      final response = PaginatedResponse.fromJson(json, (userJson) => User.fromJson(userJson as Map<String, dynamic>));

      expect(response.success, true);
      expect(response.items, hasLength(2));
      expect(response.items[0], isA<User>());
      expect(response.items[0].id, 1);
      expect(response.items[1].id, 2);
      expect(response.meta.currentPage, 1);
      expect(response.meta.totalPages, 5);
      expect(response.meta.totalItems, 50);
      expect(response.meta.hasNextPage, true);
      expect(response.meta.hasPrevPage, false);
      expect(response.message, 'Users retrieved successfully');
      expect(response.statusCode, 200);
    });

    test('PaginatedResponse.fromJson handles alternative data field', () {
      final json = {
        'success': true,
        'items': [
          {'id': 1, 'username': 'user1', 'email': 'user1@example.com', 'first_name': 'User', 'last_name': 'One', 'is_active': true, 'created_at': '2024-01-01T00:00:00Z'},
        ],
      };

      final response = PaginatedResponse.fromJson(json, (userJson) => User.fromJson(userJson as Map<String, dynamic>));

      expect(response.success, true);
      expect(response.items, hasLength(1));
    });

    test('PaginatedResponse.fromJson handles alternative pagination field', () {
      final json = {
        'success': true,
        'data': [
          {'id': 1, 'username': 'user1', 'email': 'user1@example.com', 'first_name': 'User', 'last_name': 'One', 'is_active': true, 'created_at': '2024-01-01T00:00:00Z'},
        ],
        'pagination': {
          'current_page': 1,
          'total_pages': 1,
          'total_items': 1,
          'per_page': 10,
          'has_next_page': false,
          'has_prev_page': false,
        },
      };

      final response = PaginatedResponse.fromJson(json, (userJson) => User.fromJson(userJson as Map<String, dynamic>));

      expect(response.success, true);
      expect(response.meta.currentPage, 1);
    });

    test('PaginatedResponse.fromJson handles empty data', () {
      final json = {
        'success': true,
        'data': null,
      };

      final response = PaginatedResponse.fromJson(json, (userJson) => User.fromJson(userJson as Map<String, dynamic>));

      expect(response.success, true);
      expect(response.items, hasLength(0));
    });

    test('PaginatedResponse.fromJson handles missing data', () {
      final json = {
        'success': true,
      };

      final response = PaginatedResponse.fromJson(json, (userJson) => User.fromJson(userJson as Map<String, dynamic>));

      expect(response.success, true);
      expect(response.items, hasLength(0));
    });
  });
}