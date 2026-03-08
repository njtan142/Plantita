
import 'package:flutter/material.dart';
import 'package:user_app/data/models/reel.dart';
import 'package:user_app/data/repositories/reel_repository.dart';
import 'package:user_app/utils/logger.dart';

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
    _errorMessage = null;
    notifyListeners();
    try {
      _reels = await _reelRepository.fetchReels();
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Error in ReelProvider.fetchReels: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> likeReel(String reelId) async {
    try {
      final success = await _reelRepository.likeReel(reelId);
      if (success) {
        final index = _reels.indexWhere((reel) => reel.id == reelId);
        if (index != -1) {
          _reels[index] = _reels[index].copyWith(likesCount: _reels[index].likesCount + 1);
          notifyListeners();
          logger.i('User liked reel: $reelId'); // Tracking
        }
      }
    } catch (e) {
      logger.e('Error liking reel in provider: $e');
      // Optionally set an error message for UI feedback
    }
  }

  Future<void> addComment(String reelId, String commentText) async {
    try {
      final success = await _reelRepository.addComment(reelId, commentText);
      if (success) {
        final index = _reels.indexWhere((reel) => reel.id == reelId);
        if (index != -1) {
          _reels[index] = _reels[index].copyWith(commentsCount: _reels[index].commentsCount + 1);
          notifyListeners();
          logger.i('User commented on reel: $reelId'); // Tracking
        }
      }
    } catch (e) {
      logger.e('Error adding comment in provider: $e');
    }
  }

  Future<void> shareReel(String reelId) async {
    try {
      final success = await _reelRepository.shareReel(reelId);
      if (success) {
        final index = _reels.indexWhere((reel) => reel.id == reelId);
        if (index != -1) {
          _reels[index] = _reels[index].copyWith(sharesCount: _reels[index].sharesCount + 1);
          notifyListeners();
          logger.i('User shared reel: $reelId'); // Tracking
        }
      }
    } catch (e) {
      logger.e('Error sharing reel in provider: $e');
    }
  }

  void trackReelView(String reelId) {
    logger.i('User viewed reel: $reelId'); // Tracking
  }
}
