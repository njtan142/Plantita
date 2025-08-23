
import 'dart:convert';

class Comment {
  final String id;
  final String text;
  final String userId;
  final String reelId;
  final DateTime timestamp;

  Comment({
    required this.id,
    required this.text,
    required this.userId,
    required this.reelId,
    required this.timestamp,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null ||
        json['text'] == null ||
        json['userId'] == null ||
        json['reelId'] == null ||
        json['timestamp'] == null) {
      throw FormatException('Missing required fields in Comment JSON');
    }
    return Comment(
      id: json['id'],
      text: json['text'],
      userId: json['userId'],
      reelId: json['reelId'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'userId': userId,
      'reelId': reelId,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
