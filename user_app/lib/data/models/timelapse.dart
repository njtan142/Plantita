
import 'dart:convert';

class Timelapse {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String title;
  final String description;
  final String plantType;
  final Duration duration;
  final DateTime uploadDate;
  final String userId;

  Timelapse({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.description,
    required this.plantType,
    required this.duration,
    required this.uploadDate,
    required this.userId,
  });

  factory Timelapse.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null ||
        json['videoUrl'] == null ||
        json['thumbnailUrl'] == null ||
        json['title'] == null ||
        json['description'] == null ||
        json['plantType'] == null ||
        json['durationSeconds'] == null ||
        json['uploadDate'] == null ||
        json['userId'] == null) {
      throw FormatException('Missing required fields in Timelapse JSON');
    }
    return Timelapse(
      id: json['id'],
      videoUrl: json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      title: json['title'],
      description: json['description'],
      plantType: json['plantType'],
      duration: Duration(seconds: json['durationSeconds']),
      uploadDate: DateTime.parse(json['uploadDate']),
      userId: json['userId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'title': title,
      'description': description,
      'plantType': plantType,
      'durationSeconds': duration.inSeconds,
      'uploadDate': uploadDate.toIso8601String(),
      'userId': userId,
    };
  }
}
