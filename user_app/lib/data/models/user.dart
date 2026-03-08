
import 'dart:convert';

class User {
  final String id;
  final String username;
  final String email;
  final String bio;
  final String avatarUrl;
  final int followersCount;
  final int followingCount;
  final List<String> uploadedContent;
  final bool isFollowing;
  final int totalLikesReceived; // New field
  final int totalCommentsReceived; // New field
  final int totalSharesReceived; // New field
  final int totalReelsUploaded; // New field
  final int totalTimelapsesUploaded; // New field

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.bio,
    required this.avatarUrl,
    required this.followersCount,
    required this.followingCount,
    required this.uploadedContent,
    this.isFollowing = false,
    this.totalLikesReceived = 0,
    this.totalCommentsReceived = 0,
    this.totalSharesReceived = 0,
    this.totalReelsUploaded = 0,
    this.totalTimelapsesUploaded = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null ||
        json['username'] == null ||
        json['email'] == null ||
        json['bio'] == null ||
        json['avatarUrl'] == null ||
        json['followersCount'] == null ||
        json['followingCount'] == null ||
        json['uploadedContent'] == null) {
      throw FormatException('Missing required fields in User JSON');
    }
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      bio: json['bio'],
      avatarUrl: json['avatarUrl'],
      followersCount: json['followersCount'],
      followingCount: json['followingCount'],
      uploadedContent: List<String>.from(json['uploadedContent']),
      isFollowing: json['isFollowing'] ?? false,
      totalLikesReceived: json['totalLikesReceived'] ?? 0,
      totalCommentsReceived: json['totalCommentsReceived'] ?? 0,
      totalSharesReceived: json['totalSharesReceived'] ?? 0,
      totalReelsUploaded: json['totalReelsUploaded'] ?? 0,
      totalTimelapsesUploaded: json['totalTimelapsesUploaded'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'bio': bio,
      'avatarUrl': avatarUrl,
      'followersCount': followersCount,
      'followingCount': followingCount,
      'uploadedContent': uploadedContent,
      'totalLikesReceived': totalLikesReceived,
      'totalCommentsReceived': totalCommentsReceived,
      'totalSharesReceived': totalSharesReceived,
      'totalReelsUploaded': totalReelsUploaded,
      'totalTimelapsesUploaded': totalTimelapsesUploaded,
    };
  }

  User copyWith({
    String? id,
    String? username,
    String? email,
    String? bio,
    String? avatarUrl,
    int? followersCount,
    int? followingCount,
    List<String>? uploadedContent,
    bool? isFollowing,
    int? totalLikesReceived,
    int? totalCommentsReceived,
    int? totalSharesReceived,
    int? totalReelsUploaded,
    int? totalTimelapsesUploaded,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      uploadedContent: uploadedContent ?? this.uploadedContent,
      isFollowing: isFollowing ?? this.isFollowing,
      totalLikesReceived: totalLikesReceived ?? this.totalLikesReceived,
      totalCommentsReceived: totalCommentsReceived ?? this.totalCommentsReceived,
      totalSharesReceived: totalSharesReceived ?? this.totalSharesReceived,
      totalReelsUploaded: totalReelsUploaded ?? this.totalReelsUploaded,
      totalTimelapsesUploaded: totalTimelapsesUploaded ?? this.totalTimelapsesUploaded,
    );
  }
}
