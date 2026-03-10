import 'package:user_app/services/api_service.dart';
import 'package:user_app/utils/logger.dart';
import 'package:user_app/data/models/comment.dart';

class CommentRepository {
  final ApiService _apiService;

  CommentRepository(this._apiService);

  Future<List<Comment>> fetchComments(String reelId) async {
    try {
      final response = await _apiService.get('reels/$reelId/comments');
      return (response['comments'] as List)
          .map((json) => Comment.fromJson(json))
          .toList();
    } catch (e) {
      logger.e('Error fetching comments for reel $reelId: $e');
      rethrow;
    }
  }

  Future<bool> addComment(String reelId, String commentText) async {
    try {
      await _apiService.post('reels/$reelId/comments', {'text': commentText});
      logger.i('Comment added to reel $reelId successfully.');
      return true;
    } catch (e) {
      logger.e('Error adding comment to reel $reelId: $e');
      return false;
    }
  }
}
