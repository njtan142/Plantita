import 'package:flutter_test/flutter_test.dart';
import 'package:uploader_app/models/user_model.dart';

void main() {
  group('User Model Tests', () {
    const testUserJson = {
      'id': 1,
      'username': 'testuser',
      'email': 'test@example.com',
      'first_name': 'John',
      'last_name': 'Doe',
      'profile_image_url': 'https://example.com/avatar.jpg',
      'department': 'Engineering',
      'employee_id': 'EMP001',
      'is_active': true,
      'created_at': '2024-01-01T10:00:00Z',
      'last_login_at': '2024-01-15T10:00:00Z',
    };

    test('User.fromMap creates User correctly', () {
      final user = UserModel.fromMap(testUserJson);

      expect(user.id, 1);
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.firstName, 'John');
      expect(user.lastName, 'Doe');
      expect(user.profileImageUrl, 'https://example.com/avatar.jpg');
      expect(user.department, 'Engineering');
      expect(user.employeeId, 'EMP001');
      expect(user.isActive, true);
      expect(user.createdAt, DateTime.parse('2024-01-01T10:00:00Z'));
      expect(user.lastLoginAt, DateTime.parse('2024-01-15T10:00:00Z'));
    });

    test('User.fromMap handles null optional fields', () {
      final minimalUserJson = {
        'id': 2,
        'username': 'minimaluser',
        'email': 'minimal@example.com',
        'first_name': 'Jane',
        'last_name': 'Smith',
        'is_active': false,
        'created_at': '2024-01-01T10:00:00Z',
      };

      final user = UserModel.fromMap(minimalUserJson);

      expect(user.id, 2);
      expect(user.username, 'minimaluser');
      expect(user.email, 'minimal@example.com');
      expect(user.firstName, 'Jane');
      expect(user.lastName, 'Smith');
      expect(user.profileImageUrl, null);
      expect(user.department, null);
      expect(user.employeeId, null);
      expect(user.isActive, false);
      expect(user.lastLoginAt, null);
    });

    test('User.toMap converts User to Map correctly', () {
      final user = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        profileImageUrl: 'https://example.com/avatar.jpg',
        department: 'Engineering',
        employeeId: 'EMP001',
        isActive: true,
        createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
        lastLoginAt: DateTime.parse('2024-01-15T10:00:00Z'),
      );

      final json = user.toMap();

      expect(json['id'], 1);
      expect(json['username'], 'testuser');
      expect(json['email'], 'test@example.com');
      expect(json['first_name'], 'John');
      expect(json['last_name'], 'Doe');
      expect(json['profile_image_url'], 'https://example.com/avatar.jpg');
      expect(json['department'], 'Engineering');
      expect(json['employee_id'], 'EMP001');
      expect(json['is_active'], true);
      expect(json['created_at'], '2024-01-01T10:00:00.000Z');
      expect(json['last_login_at'], '2024-01-15T10:00:00.000Z');
    });

    test('User.fullName returns correct full name', () {
      final user = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(user.fullName, 'John Doe');
    });

    test('User.displayName returns fullName when not empty', () {
      final user = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(user.displayName, 'John Doe');
    });

    test('User.displayName returns username when fullName is empty', () {
      final user = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: '',
        lastName: '',
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(user.displayName, 'testuser');
    });

    test('User.copyWith creates new User with updated fields', () {
      final user = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        isActive: true,
        createdAt: DateTime.now(),
      );

      final updatedUser = user.copyWith(
        email: 'newemail@example.com',
        firstName: 'Jane',
      );

      expect(updatedUser.id, 1);
      expect(updatedUser.username, 'testuser');
      expect(updatedUser.email, 'newemail@example.com');
      expect(updatedUser.firstName, 'Jane');
      expect(updatedUser.lastName, 'Doe');
      expect(updatedUser.isActive, true);
    });

    test('User.copyWith returns same object when no changes', () {
      final user = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        isActive: true,
        createdAt: DateTime.now(),
      );

      final sameUser = user.copyWith();

      expect(sameUser.id, user.id);
      expect(sameUser.username, user.username);
      expect(sameUser.email, user.email);
    });

    test('User equality and hashCode work correctly', () {
      final user1 = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        isActive: true,
        createdAt: DateTime.now(),
      );

      final user2 = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        isActive: true,
        createdAt: DateTime.now(),
      );

      final user3 = UserModel(
        id: 2,
        username: 'differentuser',
        email: 'different@example.com',
        firstName: 'Jane',
        lastName: 'Smith',
        isActive: true,
        createdAt: DateTime.now(),
      );

      expect(user1 == user2, true);
      expect(user1.hashCode, user2.hashCode);
      expect(user1 == user3, false);
      expect(user1.hashCode == user3.hashCode, false);
    });

    test('User.toString returns correct string representation', () {
      final user = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        isActive: true,
        createdAt: DateTime.now(),
      );

      final toString = user.toString();

      expect(toString, 'User(id: 1, username: testuser, name: John Doe)');
    });

    test('User serialization is reversible', () {
      final originalUser = UserModel(
        id: 1,
        username: 'testuser',
        email: 'test@example.com',
        firstName: 'John',
        lastName: 'Doe',
        profileImageUrl: 'https://example.com/avatar.jpg',
        department: 'Engineering',
        employeeId: 'EMP001',
        isActive: true,
        createdAt: DateTime.parse('2024-01-01T10:00:00Z'),
        lastLoginAt: DateTime.parse('2024-01-15T10:00:00Z'),
      );

      final json = originalUser.toJson();
      final deserializedUser = UserModel.fromJson(json);

      expect(deserializedUser.id, originalUser.id);
      expect(deserializedUser.username, originalUser.username);
      expect(deserializedUser.email, originalUser.email);
      expect(deserializedUser.firstName, originalUser.firstName);
      expect(deserializedUser.lastName, originalUser.lastName);
      expect(deserializedUser.profileImageUrl, originalUser.profileImageUrl);
      expect(deserializedUser.department, originalUser.department);
      expect(deserializedUser.employeeId, originalUser.employeeId);
      expect(deserializedUser.isActive, originalUser.isActive);
      expect(deserializedUser.createdAt, originalUser.createdAt);
      expect(deserializedUser.lastLoginAt, originalUser.lastLoginAt);
    });
  });
}