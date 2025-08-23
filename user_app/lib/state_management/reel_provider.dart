
import 'package:flutter/material.dart';
import 'package:user_app/data/models/reel.dart';
import 'package:user_app/data/repositories/reel_repository.dart';

class ReelProvider with ChangeNotifier {
  final ReelRepository _reelRepository;
  List<Reel> _reels = [];
  bool _isLoading = false;

  ReelProvider(this._reelRepository);

  List<Reel> get reels => _reels;
  bool get isLoading => _isLoading;

  Future<void> fetchReels() async {
    _isLoading = true;
    notifyListeners();
    // TODO: Implement actual fetching from repository
    _reels = []; // Placeholder
    _isLoading = false;
    notifyListeners();
  }
}
