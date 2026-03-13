class Playlist {
  final String id;
  final String name;
  final String description;
  final List<String> timelapseIds;
  final String userId;

  Playlist({
    required this.id,
    required this.name,
    required this.description,
    required this.timelapseIds,
    required this.userId,
  });

  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      timelapseIds: (json['timelapseIds'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      userId: json['userId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'timelapseIds': timelapseIds,
      'userId': userId,
    };
  }

  Playlist copyWith({
    String? id,
    String? name,
    String? description,
    List<String>? timelapseIds,
    String? userId,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      timelapseIds: timelapseIds ?? this.timelapseIds,
      userId: userId ?? this.userId,
    );
  }
}
