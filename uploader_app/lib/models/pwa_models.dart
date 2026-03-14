/// Background sync task model
class BackgroundSyncTask {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final int retryCount;

  BackgroundSyncTask({
    required this.id,
    required this.type,
    required this.data,
    DateTime? createdAt,
    this.retryCount = 0,
  }) : createdAt = createdAt ?? DateTime.now();

  factory BackgroundSyncTask.fromJson(Map<String, dynamic> json) {
    return BackgroundSyncTask(
      id: json['id'],
      type: json['type'],
      data: Map<String, dynamic>.from(json['data']),
      createdAt: DateTime.parse(json['createdAt']),
      retryCount: json['retryCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'data': data,
      'createdAt': createdAt.toIso8601String(),
      'retryCount': retryCount,
    };
  }
}

/// Push notification model
class PushNotification {
  final String title;
  final String body;
  final String? icon;
  final String? image;
  final Map<String, dynamic>? data;

  PushNotification({
    required this.title,
    required this.body,
    this.icon,
    this.image,
    this.data,
  });

  factory PushNotification.fromJson(Map<String, dynamic> json) {
    return PushNotification(
      title: json['title'],
      body: json['body'],
      icon: json['icon'],
      image: json['image'],
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
      'icon': icon,
      'image': image,
      'data': data,
    };
  }
}
