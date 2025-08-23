
import 'package:user_app/services/api_service.dart';
import 'package:user_app/utils/logger.dart';
import 'package:user_app/data/models/reel.dart'; // Assuming Reel model is defined here

class ReelRepository {
  final ApiService _apiService;

  ReelRepository(this._apiService);

  Future<List<Reel>> fetchReels() async {
    try {
      final response = await _apiService.get('reels');
      return (response['reels'] as List)
          .map((json) => Reel.fromJson(json))
          .toList();
    } catch (e) {
      logger.e('Error fetching reels: $e');
      rethrow;
    }
  }

  Future<bool> likeReel(String reelId) async {
    try {
      await _apiService.post('reels/$reelId/like', {});
      logger.i('Reel $reelId liked successfully.');
      return true;
    } catch (e) {
      logger.e('Error liking reel $reelId: $e');
      return false;
    }
  }

  Future<bool> addComment(String reelId, String commentText) async {
    try {
      await _apiService.post('reels/$reelId/comment', {'comment': commentText});
      logger.i('Comment added to reel $reelId successfully.');
      return true;
    } catch (e) {
      logger.e('Error adding comment to reel $reelId: $e');
      return false;
    }
  }

  Future<bool> shareReel(String reelId) async {
    try {
      await _apiService.post('reels/$reelId/share', {});
      logger.i('Reel $reelId shared successfully.');
      return true;
    } catch (e) {
      logger.e('Error sharing reel $reelId: $e');
      return false;
    }
  }
}
