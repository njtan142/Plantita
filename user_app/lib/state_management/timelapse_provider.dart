import 'package:flutter/material.dart';
import 'package:user_app/data/models/timelapse.dart';
import 'package:user_app/data/repositories/timelapse_repository.dart';
import 'package:user_app/utils/logger.dart';

class TimelapseProvider with ChangeNotifier {
  final TimelapseRepository _timelapseRepository;
  List<Timelapse> _timelapses = [];
  bool _isLoading = false;
  String? _errorMessage;

  TimelapseProvider(this._timelapseRepository);

  List<Timelapse> get timelapses => _timelapses;
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
}