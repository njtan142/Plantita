
import 'dart:convert';

class Reel {
  final String id;
  final String videoUrl;
  final String thumbnailUrl;
  final String title;
  final String description;
  final DateTime uploadDate;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final String userId;

  Reel({
    required this.id,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.description,
    required this.uploadDate,
    required this.likesCount,
    required this.commentsCount,
    required this.sharesCount,
    required this.userId,
  });

  factory Reel.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null ||
        json['videoUrl'] == null ||
        json['thumbnailUrl'] == null ||
        json['title'] == null ||
        json['description'] == null ||
        json['uploadDate'] == null ||
        json['likesCount'] == null ||
        json['commentsCount'] == null ||
        json['sharesCount'] == null ||
        json['userId'] == null) {
      throw FormatException('Missing required fields in Reel JSON');
    }
    return Reel(
      id: json['id'],
      videoUrl: json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      title: json['title'],
      description: json['description'],
      uploadDate: DateTime.parse(json['uploadDate']),
      likesCount: json['likesCount'],
      commentsCount: json['commentsCount'],
      sharesCount: json['sharesCount'],
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
      'uploadDate': uploadDate.toIso8601String(),
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'userId': userId,
    };
  }

  Reel copyWith({
    String? id,
    String? videoUrl,
    String? thumbnailUrl,
    String? title,
    String? description,
    DateTime? uploadDate,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    String? userId,
  }) {
    return Reel(
      id: id ?? this.id,
      videoUrl: videoUrl ?? this.videoUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      title: title ?? this.title,
      description: description ?? this.description,
      uploadDate: uploadDate ?? this.uploadDate,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      userId: userId ?? this.userId,
    );
  }
}
