import 'package:json_annotation/json_annotation.dart';

part 'playlist.g.dart';

@JsonSerializable()
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

  factory Playlist.fromJson(Map<String, dynamic> json) => _\$PlaylistFromJson(json);
  Map<String, dynamic> toJson() => _\$PlaylistToJson(this);

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
