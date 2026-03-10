
import 'package:user_app/services/api_service.dart';
import 'package:user_app/data/models/user.dart';
import 'package:user_app/data/repositories/reel_repository.dart';
import 'package:user_app/data/repositories/timelapse_repository.dart';
import 'package:user_app/utils/logger.dart';

class UserRepository {
  final ApiService _apiService;
  final ReelRepository _reelRepository;
  final TimelapseRepository _timelapseRepository;

  UserRepository(this._apiService, this._reelRepository, this._timelapseRepository);

  Future<User> fetchUserProfile(String userId) async {
    try {
      final response = await _apiService.get('users/$userId');
      // Assuming the API response for user profile includes these new statistics
      return User.fromJson(response);
    } catch (e) {
      logger.e('Error fetching user profile for $userId: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchUploadedContent(List<String> contentIds) async {
    final futures = contentIds.map((id) async {
      try {
        if (id.startsWith('reel-')) {
          // Assuming reel IDs start with 'reel-'
          // This is a simplification; ideally, the API would return content type
          // Or the contentIds would be structured to indicate type
          return await _reelRepository.fetchReelDetails(id);
        } else if (id.startsWith('timelapse-')) {
          // Assuming timelapse IDs start with 'timelapse-'
          return await _timelapseRepository.fetchTimelapseDetails(id);
        } else {
          logger.w('Unknown content type for ID: $id');
          return null;
        }
      } catch (e) {
        logger.e('Error fetching content for ID $id: $e');
        return null;
      }
    });

    final results = await Future.wait(futures);
    return results.where((item) => item != null).toList();
  }

  Future<User> updateUserProfile(User user) async {
    try {
      final response = await _apiService.put('users/${user.id}', user.toJson());
      return User.fromJson(response);
    } catch (e) {
      logger.e('Error updating user profile for ${user.id}: $e');
      rethrow;
    }
  }

  Future<bool> followUser(String userId) async {
    try {
      await _apiService.post('users/$userId/follow', {});
      logger.i('User followed $userId successfully.');
      return true;
    } catch (e) {
      logger.e('Error following user $userId: $e');
      return false;
    }
  }

  Future<bool> unfollowUser(String userId) async {
    try {
      await _apiService.delete('users/$userId/follow');
      logger.i('User unfollowed $userId successfully.');
      return true;
    } catch (e) {
      logger.e('Error unfollowing user $userId: $e');
      return false;
    }
  }
}
