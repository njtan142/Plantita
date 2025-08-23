
import 'package:flutter/material.dart';
import 'package:user_app/data/models/reel.dart';
import 'package:user_app/data/repositories/reel_repository.dart';

class ReelProvider with ChangeNotifier {
  final ReelRepository _reelRepository;
  List<Reel> _reels = [];
  bool _isLoading = false;
  String? _errorMessage;

  ReelProvider(this._reelRepository);

  List<Reel> get reels => _reels;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchReels() async {
    _isLoading = true;
    _errorMessage = null; // Clear previous errors
    notifyListeners();
    try {
      // TODO: Implement actual fetching from repository
      _reels = []; // Placeholder
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
