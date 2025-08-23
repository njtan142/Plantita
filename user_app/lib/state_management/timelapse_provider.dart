import 'package:flutter/material.dart';
import 'package:user_app/data/models/timelapse.dart';
import 'package:user_app/data/models/playlist.dart';
import 'package:user_app/data/repositories/timelapse_repository.dart';
import 'package:user_app/utils/logger.dart';

class TimelapseProvider with ChangeNotifier {
  final TimelapseRepository _timelapseRepository;
  List<Timelapse> _timelapses = [];
  List<Playlist> _playlists = [];
  bool _isLoading = false;
  String? _errorMessage;

  TimelapseProvider(this._timelapseRepository);

  List<Timelapse> get timelapses => _timelapses;
  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchTimelapses({String? plantType, String? duration}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _timelapses = await _timelapseRepository.fetchTimelapses(plantType: plantType, duration: duration);
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Error in TimelapseProvider.fetchTimelapses: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createPlaylist(String name, String description) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newPlaylist = await _timelapseRepository.createPlaylist(name, description);
      _playlists.add(newPlaylist);
      logger.i('Playlist created: ${newPlaylist.name}');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Error creating playlist: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTimelapseToPlaylist(String playlistId, String timelapseId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _timelapseRepository.addTimelapseToPlaylist(playlistId, timelapseId);
      if (success) {
        // Update the playlist in the local state
        final index = _playlists.indexWhere((p) => p.id == playlistId);
        if (index != -1) {
          final updatedPlaylist = _playlists[index].copyWith(
            timelapseIds: List.from(_playlists[index].timelapseIds)..add(timelapseId),
          );
          _playlists[index] = updatedPlaylist;
        }
        logger.i('Timelapse $timelapseId added to playlist $playlistId');
      }
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Error adding timelapse to playlist: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPlaylists() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _playlists = await _timelapseRepository.fetchPlaylists();
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Error fetching playlists: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPlaylistDetails(String playlistId) async {
    try {
      return await _timelapseRepository.fetchPlaylistDetails(playlistId);
    } catch (e) {
      logger.e('Error fetching playlist details: $e');
      _errorMessage = e.toString();
      return null;
    }
  }

  Future<void> downloadTimelapse(String videoUrl) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _timelapseRepository.downloadTimelapse(videoUrl);
      if (!success) {
        _errorMessage = 'Failed to initiate download.';
      }
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Error downloading timelapse: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}