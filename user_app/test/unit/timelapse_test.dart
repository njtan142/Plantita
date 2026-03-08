
import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/data/models/timelapse.dart';

void main() {
  group('Timelapse', () {
    test('fromJson creates a valid Timelapse object', () {
      final Map<String, dynamic> json = {
        'id': '1',
        'videoUrl': 'http://example.com/timelapse.mp4',
        'thumbnailUrl': 'http://example.com/timelapse_thumb.png',
        'title': 'Plant Growth',
        'description': 'Timelapse of a plant growing',
        'plantType': 'Tomato',
        'durationSeconds': 300,
        'uploadDate': '2023-01-01T12:00:00.000Z',
        'userId': 'user2',
      };

      final timelapse = Timelapse.fromJson(json);

      expect(timelapse.id, '1');
      expect(timelapse.videoUrl, 'http://example.com/timelapse.mp4');
      expect(timelapse.thumbnailUrl, 'http://example.com/timelapse_thumb.png');
      expect(timelapse.title, 'Plant Growth');
      expect(timelapse.description, 'Timelapse of a plant growing');
      expect(timelapse.plantType, 'Tomato');
      expect(timelapse.duration.inSeconds, 300);
      expect(timelapse.uploadDate, DateTime.parse('2023-01-01T12:00:00.000Z'));
      expect(timelapse.userId, 'user2');
    });

    test('fromJson throws FormatException for missing fields', () {
      final Map<String, dynamic> json = {
        'id': '1',
        'title': 'Plant Growth',
        // Missing other required fields
      };

      expect(() => Timelapse.fromJson(json), throwsA(isA<FormatException>()));
    });

    test('toJson converts Timelapse object to valid JSON', () {
      final timelapse = Timelapse(
        id: '1',
        videoUrl: 'http://example.com/timelapse.mp4',
        thumbnailUrl: 'http://example.com/timelapse_thumb.png',
        title: 'Plant Growth',
        description: 'Timelapse of a plant growing',
        plantType: 'Tomato',
        duration: const Duration(seconds: 300),
        uploadDate: DateTime.parse('2023-01-01T12:00:00.000Z'),
        userId: 'user2',
      );

      final json = timelapse.toJson();

      expect(json['id'], '1');
      expect(json['videoUrl'], 'http://example.com/timelapse.mp4');
      expect(json['thumbnailUrl'], 'http://example.com/timelapse_thumb.png');
      expect(json['title'], 'Plant Growth');
      expect(json['description'], 'Timelapse of a plant growing');
      expect(json['plantType'], 'Tomato');
      expect(json['durationSeconds'], 300);
      expect(json['uploadDate'], '2023-01-01T12:00:00.000Z');
      expect(json['userId'], 'user2');
    });
  });
}
