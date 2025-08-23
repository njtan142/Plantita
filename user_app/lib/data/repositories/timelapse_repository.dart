
import 'package:user_app/services/api_service.dart';
import 'package:user_app/utils/logger.dart';
import 'package:user_app/data/models/timelapse.dart'; // Assuming Timelapse model is defined here

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
}
