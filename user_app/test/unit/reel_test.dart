
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/data/models/reel.dart';

void main() {
  group('Reel', () {
    test('fromJson creates a valid Reel object', () {
      final Map<String, dynamic> json = {
        'id': '1',
        'videoUrl': 'http://example.com/video.mp4',
        'thumbnailUrl': 'http://example.com/thumbnail.png',
        'title': 'Test Reel',
        'description': 'A short test reel',
        'uploadDate': '2023-01-01T10:00:00.000Z',
        'likesCount': 100,
        'commentsCount': 10,
        'sharesCount': 5,
        'userId': 'user1',
      };

      final reel = Reel.fromJson(json);

      expect(reel.id, '1');
      expect(reel.videoUrl, 'http://example.com/video.mp4');
      expect(reel.thumbnailUrl, 'http://example.com/thumbnail.png');
      expect(reel.title, 'Test Reel');
      expect(reel.description, 'A short test reel');
      expect(reel.uploadDate, DateTime.parse('2023-01-01T10:00:00.000Z'));
      expect(reel.likesCount, 100);
      expect(reel.commentsCount, 10);
      expect(reel.sharesCount, 5);
      expect(reel.userId, 'user1');
    });

    test('fromJson throws FormatException for missing fields', () {
      final Map<String, dynamic> json = {
        'id': '1',
        'title': 'Test Reel',
        // Missing other required fields
      };

      expect(() => Reel.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('toJson converts Reel object to valid JSON', () {
      final reel = Reel(
        id: '1',
        videoUrl: 'http://example.com/video.mp4',
        thumbnailUrl: 'http://example.com/thumbnail.png',
        title: 'Test Reel',
        description: 'A short test reel',
        uploadDate: DateTime.parse('2023-01-01T10:00:00.000Z'),
        likesCount: 100,
        commentsCount: 10,
        sharesCount: 5,
        userId: 'user1',
      );

      final json = reel.toJson();

      expect(json['id'], '1');
      expect(json['videoUrl'], 'http://example.com/video.mp4');
      expect(json['thumbnailUrl'], 'http://example.com/thumbnail.png');
      expect(json['title'], 'Test Reel');
      expect(json['description'], 'A short test reel');
      expect(json['uploadDate'], '2023-01-01T10:00:00.000Z');
      expect(json['likesCount'], 100);
      expect(json['commentsCount'], 10);
      expect(json['sharesCount'], 5);
      expect(json['userId'], 'user1');
    });
  });
}
