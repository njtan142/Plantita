import 'package:flutter_test/flutter_test.dart';
import 'package:uploader_app/models/employee_model.dart';

void main() {
  group('Employee Model Tests', () {
    const testEmployeeJson = {
      'id': 1,
      'username': 'testemployee',
      'email': 'test@example.com',
      'first_name': 'John',
      'last_name': 'Doe',
      'role': 'admin',
      'permissions': ['read', 'write', 'delete', 'admin'],
      'is_active': true,
      'created_at': '2024-01-01T10:00:00Z',
      'last_login_at': '2024-01-15T10:00:00Z',
    };

    test('Employee.fromJson creates Employee correctly', () {
      final employee = Employee.fromJson(testEmployeeJson);

      expect(employee.id, 1);
      expect(employee.username, 'testemployee');
      expect(employee.email, 'test@example.com');
      expect(employee.firstName, 'John');
      expect(employee.lastName, 'Doe');
      expect(employee.role, 'admin');
      expect(employee.permissions, ['read', 'write', 'delete', 'admin']);
      expect(employee.isActive, true);
      expect(employee.createdAt, DateTime.parse('2024-01-01T10:00:00Z'));
      expect(employee.lastLoginAt, DateTime.parse('2024-01-15T10:00:00Z'));
    });

    test('Employee.fromJson handles null optional fields', () {
      final minimalEmployeeJson = {
        'id': 2,
        'username': 'minimalemployee',
        'email': 'minimal@example.com',
        'first_name': 'Jane',
        'last_name': 'Smith',
        'role': 'user',
        'permissions': [],
        'is_active': false,
        'created_at': '2024-01-01T10:00:00Z',
      };

      final employee = Employee.fromJson(minimalEmployeeJson);

      expect(employee.id, 2);
      expect(employee.username, 'minimalemployee');
      expect(employee.email, 'minimal@example.com');
      expect(employee.firstName, 'Jane');
      expect(employee.lastName, 'Smith');
      expect(employee.role, 'user');
      expect(employee.permissions, []);
      expect(employee.isActive, false);
      expect(employee.lastLoginAt, null);
    });

    test('Employee.fromJson handles null permissions', () {
      final employeeJsonWithNullPermissions = {
        'id': 3,
        'username': 'nullperm',
        'email': 'nullperm@example.com',
        'first_name': 'Bob',
        'last_name': 'Wilson',
        'role': 'user',
        'permissions': null,
        'is_active': true,
        'created_at': '2024-01-01T10:00:00Z',
      };

      final employee = Employee.fromJson(employeeJsonWithNullPermissions);

      expect(employee.permissions, []);
    });

    test('Employee.toJson converts Employee to JSON correctly', () {
      final employee = Employee(
        id: 1,
        username: 'testemployee',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: 'admin',
        permissions: ['read', 'write', 'delete', 'admin'],
        isActive: true,
        createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
        lastLoginAt: DateTime.parse('2024-01-15T10:00:00Z'),
      );

      final json = employee.toJson();

      expect(json['id'], 1);
      expect(json['username'], 'testemployee');
      expect(json['email'], 'test@example.com');
      expect(json['first_name'], 'John');
      expect(json['last_name'], 'Doe');
      expect(json['role'], 'admin');
      expect(json['permissions'], ['read', 'write', 'delete', 'admin']);
      expect(json['is_active'], true);
      expect(json['created_at'], '2024-01-01T10:00:00.000Z');
      expect(json['last_login_at'], '2024-01-15T10:00:00.000Z');
    });

    test('Employee.fullName returns correct full name', () {
      final employee = Employee(
        id: 1,
        username: 'testemployee',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: 'user',
        permissions: [],
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(employee.fullName, 'John Doe');
    });

    test('Employee.displayName returns fullName when not empty', () {
      final employee = Employee(
        id: 1,
        username: 'testemployee',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: 'user',
        permissions: [],
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(employee.displayName, 'John Doe');
    });

    test('Employee.displayName returns username when fullName is empty', () {
      final employee = Employee(
        id: 1,
        username: 'testemployee',
        email: 'test@example.com',
        firstName: '',
        lastName: '',
        role: 'user',
        permissions: [],
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(employee.displayName, 'testemployee');
    });

    test('Employee.hasPermission returns true for existing permission', () {
      final employee = Employee(
        id: 1,
        username: 'testemployee',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: 'user',
        permissions: ['read', 'write', 'delete'],
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(employee.hasPermission('read'), true);
      expect(employee.hasPermission('write'), true);
      expect(employee.hasPermission('delete'), true);
      expect(employee.hasPermission('admin'), false);
    });

    test('Employee.hasPermission returns false for non-existing permission', () {
      final employee = Employee(
        id: 1,
        username: 'testemployee',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: 'user',
        permissions: ['read', 'write'],
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(employee.hasPermission('admin'), false);
      expect(employee.hasPermission('superuser'), false);
    });

    test('Employee.isAdmin returns true for admin role', () {
      final adminEmployee = Employee(
        id: 1,
        username: 'admin',
        email: 'admin@example.com',
        firstName: 'Admin',
        lastName: 'User',
        role: 'admin',
        permissions: ['read', 'write', 'delete', 'admin'],
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(adminEmployee.isAdmin, true);
    });

    test('Employee.isAdmin returns false for non-admin role', () {
      final userEmployee = Employee(
        id: 1,
        username: 'user',
        email: 'user@example.com',
        firstName: 'Regular',
        lastName: 'User',
        role: 'user',
        permissions: ['read'],
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(userEmployee.isAdmin, false);
    });

    test('Employee.isUploader returns true for uploader role', () {
      final uploaderEmployee = Employee(
        id: 1,
        username: 'uploader',
        email: 'uploader@example.com',
        firstName: 'Upload',
        lastName: 'User',
        role: 'uploader',
        permissions: ['read', 'write', 'upload'],
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(uploaderEmployee.isUploader, true);
    });

    test('Employee.isUploader returns true for admin role', () {
      final adminEmployee = Employee(
        id: 1,
        username: 'admin',
        email: 'admin@example.com',
        firstName: 'Admin',
        lastName: 'User',
        role: 'admin',
        permissions: ['read', 'write', 'delete', 'admin'],
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(adminEmployee.isUploader, true);
    });

    test('Employee.isUploader returns false for non-uploader role', () {
      final userEmployee = Employee(
        id: 1,
        username: 'user',
        email: 'user@example.com',
        firstName: 'Regular',
        lastName: 'User',
        role: 'viewer',
        permissions: ['read'],
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(userEmployee.isUploader, false);
    });

    test('Employee.copyWith creates new Employee with updated fields', () {
      final employee = Employee(
        id: 1,
        username: 'testemployee',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: 'user',
        permissions: ['read', 'write'],
        isActive: true,
        createdAt: DateTime.now(),
      );

      final updatedEmployee = employee.copyWith(
        email: 'newemail@example.com',
        firstName: 'Jane',
        role: 'admin',
        permissions: ['read', 'write', 'delete', 'admin'],
      );

      expect(updatedEmployee.id, 1);
      expect(updatedEmployee.username, 'testemployee');
      expect(updatedEmployee.email, 'newemail@example.com');
      expect(updatedEmployee.firstName, 'Jane');
      expect(updatedEmployee.lastName, 'Doe');
      expect(updatedEmployee.role, 'admin');
      expect(updatedEmployee.permissions, ['read', 'write', 'delete', 'admin']);
      expect(updatedEmployee.isActive, true);
    });

    test('Employee.copyWith returns same object when no changes', () {
      final employee = Employee(
        id: 1,
        username: 'testemployee',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: 'user',
        permissions: ['read', 'write'],
        isActive: true,
        createdAt: DateTime.now(),
      );

      final sameEmployee = employee.copyWith();

      expect(sameEmployee.id, employee.id);
      expect(sameEmployee.username, employee.username);
      expect(sameEmployee.email, employee.email);
    });

    test('Employee equality and hashCode work correctly', () {
      final employee1 = Employee(
        id: 1,
        username: 'testemployee',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: 'user',
        permissions: ['read', 'write'],
        isActive: true,
        createdAt: DateTime.now(),
      );

      final employee2 = Employee(
        id: 1,
        username: 'testemployee',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: 'user',
        permissions: ['read', 'write'],
        isActive: true,
        createdAt: DateTime.now(),
      );

      final employee3 = Employee(
        id: 2,
        username: 'differentemployee',
        email: 'different@example.com',
        firstName: 'Jane',
        lastName: 'Smith',
        role: 'admin',
        permissions: ['read', 'write', 'delete'],
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(employee1 == employee2, true);
      expect(employee1.hashCode, employee2.hashCode);
      expect(employee1 == employee3, false);
      expect(employee1.hashCode == employee3.hashCode, false);
    });

    test('Employee.toString returns correct string representation', () {
      final employee = Employee(
        id: 1,
        username: 'testemployee',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: 'admin',
        permissions: ['read', 'write', 'delete'],
        isActive: true,
        createdAt: DateTime.now(),
      );

      final toString = employee.toString();

      expect(toString, 'Employee(id: 1, username: testemployee, name: John Doe, role: admin)');
    });

    test('Employee serialization is reversible', () {
      final originalEmployee = Employee(
        id: 1,
        username: 'testemployee',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        role: 'admin',
        permissions: ['read', 'write', 'delete', 'admin'],
        isActive: true,
        createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
        lastLoginAt: DateTime.parse('2024-01-15T10:00:00Z'),
      );

      final json = originalEmployee.toJson();
      final deserializedEmployee = Employee.fromJson(json);

      expect(deserializedEmployee.id, originalEmployee.id);
      expect(deserializedEmployee.username, originalEmployee.username);
      expect(deserializedEmployee.email, originalEmployee.email);
      expect(deserializedEmployee.firstName, originalEmployee.firstName);
      expect(deserializedEmployee.lastName, originalEmployee.lastName);
      expect(deserializedEmployee.role, originalEmployee.role);
      expect(deserializedEmployee.permissions, originalEmployee.permissions);
      expect(deserializedEmployee.isActive, originalEmployee.isActive);
      expect(deserializedEmployee.createdAt, originalEmployee.createdAt);
      expect(deserializedEmployee.lastLoginAt, originalEmployee.lastLoginAt);
    });
  });
}