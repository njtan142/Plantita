
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/data/models/comment.dart';

void main() {
  group('Comment', () {
    test('fromJson creates a valid Comment object', () {
      final Map<String, dynamic> json = {
        'id': 'c1',
        'text': 'Great reel!',
        'userId': 'user3',
        'reelId': 'r1',
        'timestamp': '2023-01-01T13:00:00.000Z',
      };

      final comment = Comment.fromJson(json);

      expect(comment.id, 'c1');
      expect(comment.text, 'Great reel!');
      expect(comment.userId, 'user3');
      expect(comment.reelId, 'r1');
      expect(comment.timestamp, DateTime.parse('2023-01-01T13:00:00.000Z'));
    });

    test('fromJson throws FormatException for missing fields', () {
      final Map<String, dynamic> json = {
        'id': 'c1',
        'text': 'Great reel!',
        // Missing other required fields
      };

      expect(() => Comment.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('toJson converts Comment object to valid JSON', () {
      final comment = Comment(
        id: 'c1',
        text: 'Great reel!',
        userId: 'user3',
        reelId: 'r1',
        timestamp: DateTime.parse('2023-01-01T13:00:00.000Z'),
      );

      final json = comment.toJson();

      expect(json['id'], 'c1');
      expect(json['text'], 'Great reel!');
      expect(json['userId'], 'user3');
      expect(json['reelId'], 'r1');
      expect(json['timestamp'], '2023-01-01T13:00:00.000Z');
    });
  });
}
