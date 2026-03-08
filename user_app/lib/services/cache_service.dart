import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_app/utils/logger.dart';

class CacheService {
  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    logger.d('CacheService initialized.');
  }

  Future<bool> saveData(String key, String value) async {
    logger.d('Saving data to cache: $key');
    return await _prefs.setString(key, value);
  }

  String? getData(String key) {
    final data = _prefs.getString(key);
    logger.d('Retrieving data from cache: $key - Data: $data');
    return data;
  }

  Future<bool> removeData(String key) async {
    logger.d('Removing data from cache: $key');
    return await _prefs.remove(key);
  }

  Future<bool> clearAllData() async {
    logger.d('Clearing all data from cache.');
    return await _prefs.clear();
  }
}
