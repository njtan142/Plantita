
import 'package:user_app/services/api_service.dart';
import 'package:user_app/utils/logger.dart';
import 'package:user_app/data/models/timelapse.dart';
import 'package:user_app/data/models/playlist.dart';
import 'package:url_launcher/url_launcher.dart';

class TimelapseRepository {
  final ApiService _apiService;

  TimelapseRepository(this._apiService);

  Future<List<Timelapse>> fetchTimelapses({String? plantType, String? duration}) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (plantType != null && plantType != 'All') {
        queryParams['plantType'] = plantType;
      }
      if (duration != null && duration != 'All') {
        queryParams['duration'] = duration;
      }

      final response = await _apiService.get('timelapses', queryParams: queryParams);
      return (response['timelapses'] as List)
          .map((json) => Timelapse.fromJson(json))
          .toList();
    } catch (e) {
      logger.e('Error fetching timelapses: $e');
      rethrow;
    }
  }

  Future<Playlist> createPlaylist(String name, String description) async {
    try {
      final response = await _apiService.post('playlists', {
        'name': name,
        'description': description,
      });
      return Playlist.fromJson(response);
    } catch (e) {
      logger.e('Error creating playlist: $e');
      rethrow;
    }
  }

  Future<bool> addTimelapseToPlaylist(String playlistId, String timelapseId) async {
    try {
      await _apiService.post('playlists/$playlistId/add-timelapse', {'timelapseId': timelapseId});
      logger.i('Timelapse $timelapseId added to playlist $playlistId successfully.');
      return true;
    } catch (e) {
      logger.e('Error adding timelapse $timelapseId to playlist $playlistId: $e');
      return false;
    }
  }

  Future<List<Playlist>> fetchPlaylists() async {
    try {
      final response = await _apiService.get('playlists');
      return (response['playlists'] as List)
          .map((json) => Playlist.fromJson(json))
          .toList();
    } catch (e) {
      logger.e('Error fetching playlists: $e');
      rethrow;
    }
  }

  Future<Playlist> fetchPlaylistDetails(String playlistId) async {
    try {
      final response = await _apiService.get('playlists/$playlistId');
      return Playlist.fromJson(response);
    } catch (e) {
      logger.e('Error fetching playlist details for $playlistId: $e');
      rethrow;
    }
  }

  Future<Timelapse> fetchTimelapseDetails(String timelapseId) async {
    try {
      final response = await _apiService.get('timelapses/$timelapseId');
      return Timelapse.fromJson(response);
    } catch (e) {
      logger.e('Error fetching timelapse details for $timelapseId: $e');
      rethrow;
    }
  }

  Future<bool> downloadTimelapse(String videoUrl) async {
    try {
      final uri = Uri.parse(videoUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
        logger.i('Attempted to download timelapse from: $videoUrl');
        return true;
      } else {
        logger.e('Could not launch $videoUrl to download timelapse.');
        return false;
      }
    } catch (e) {
      logger.e('Error downloading timelapse: $e');
      return false;
    }
  }
}
