import 'package:user_app/services/api_service.dart';
import 'package:user_app/utils/logger.dart';
import 'package:user_app/data/models/reel.dart';
import 'package:user_app/data/models/timelapse.dart';

class ContentRepository {
  final ApiService _apiService;

  ContentRepository(this._apiService);

  Future<List<dynamic>> searchContent({
    String? query,
    String? contentType,
    String? category,
    String? sortBy,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }
      if (contentType != null && contentType != 'All') {
        queryParams['contentType'] = contentType;
      }
      if (category != null && category != 'All') {
        queryParams['category'] = category;
      }
      if (sortBy != null && sortBy.isNotEmpty) {
        queryParams['sortBy'] = sortBy;
      }

      final response = await _apiService.get('content/search', queryParams: queryParams);
      
      List<dynamic> content = [];
      if (response['reels'] != null) {
        content.addAll((response['reels'] as List).map((json) => Reel.fromJson(json)).toList());
      }
      if (response['timelapses'] != null) {
        content.addAll((response['timelapses'] as List).map((json) => Timelapse.fromJson(json)).toList());
      }
      // Assuming other content types might be returned

      return content;
    } catch (e) {
      logger.e('Error searching content: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchTrendingContent() async {
    try {
      final response = await _apiService.get('content/trending');
      List<dynamic> content = [];
      if (response['reels'] != null) {
        content.addAll((response['reels'] as List).map((json) => Reel.fromJson(json)).toList());
      }
      if (response['timelapses'] != null) {
        content.addAll((response['timelapses'] as List).map((json) => Timelapse.fromJson(json)).toList());
      }
      return content;
    } catch (e) {
      logger.e('Error fetching trending content: $e');
      rethrow;
    }
  }

  Future<List<dynamic>> fetchPopularContent() async {
    try {
      final response = await _apiService.get('content/popular');
      List<dynamic> content = [];
      if (response['reels'] != null) {
        content.addAll((response['reels'] as List).map((json) => Reel.fromJson(json)).toList());
      }
      if (response['timelapses'] != null) {
        content.addAll((response['timelapses'] as List).map((json) => Timelapse.fromJson(json)).toList());
      }
      return content;
    } catch (e) {
      logger.e('Error fetching popular content: $e');
      rethrow;
    }
  }
}