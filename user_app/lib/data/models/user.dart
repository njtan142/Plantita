
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

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.bio,
    required this.avatarUrl,
    required this.followersCount,
    required this.followingCount,
    required this.uploadedContent,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      bio: json['bio'],
      avatarUrl: json['avatarUrl'],
      followersCount: json['followersCount'],
            followingCount: json['followingCount'],
      uploadedContent: List<String>.from(json['uploadedContent']),
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
    };
  }
}
