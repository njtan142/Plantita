
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/data/models/user.dart';

void main() {
  group('User', () {
    test('fromJson creates a valid User object', () {
      final Map<String, dynamic> json = {
        'id': '1',
        'username': 'testuser',
        'email': 'test@example.com',
        'bio': 'A test user',
        'avatarUrl': 'http://example.com/avatar.png',
        'followersCount': 10,
        'followingCount': 5,
        'uploadedContent': ['content1', 'content2'],
      };

      final user = User.fromJson(json);

      expect(user.id, '1');
      expect(user.username, 'testuser');
      expect(user.email, 'test@example.com');
      expect(user.bio, 'A test user');
      expect(user.avatarUrl, 'http://example.com/avatar.png');
      expect(user.followersCount, 10);
      expect(user.followingCount, 5);
      expect(user.uploadedContent, ['content1', 'content2']);
    });

    test('fromJson throws FormatException for missing fields', () {
      final Map<String, dynamic> json = {
        'id': '1',
        'username': 'testuser',
        // Missing other required fields
      };

      expect(() => User.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('toJson converts User object to valid JSON', () {
      final user = User(
        id: '1',
        username: 'testuser',
        email: 'test@example.com',
        bio: 'A test user',
        avatarUrl: 'http://example.com/avatar.png',
        followersCount: 10,
        followingCount: 5,
        uploadedContent: ['content1', 'content2'],
      );

      final json = user.toJson();

      expect(json['id'], '1');
      expect(json['username'], 'testuser');
      expect(json['email'], 'test@example.com');
      expect(json['bio'], 'A test user');
      expect(json['avatarUrl'], 'http://example.com/avatar.png');
      expect(json['followersCount'], 10);
      expect(json['followingCount'], 5);
      expect(json['uploadedContent'], ['content1', 'content2']);
    });
  });
}
