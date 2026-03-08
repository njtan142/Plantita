import 'package:flutter/material.dart';
import 'package:user_app/data/models/user.dart';
import 'package:user_app/data/models/reel.dart';
import 'package:user_app/data/models/timelapse.dart';
import 'package:user_app/data/repositories/user_repository.dart';
import 'package:user_app/utils/logger.dart';

class UserProvider with ChangeNotifier {
  final UserRepository _userRepository;
  User? _userProfile;
  List<dynamic> _uploadedContent = []; // Can be Reel or Timelapse
  bool _isLoading = false;
  String? _errorMessage;

  UserProvider(this._userRepository);

  User? get userProfile => _userProfile;
  List<dynamic> get uploadedContent => _uploadedContent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchUserProfileAndContent(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _userProfile = await _userRepository.fetchUserProfile(userId);
      if (_userProfile != null && _userProfile!.uploadedContent.isNotEmpty) {
        _uploadedContent = await _userRepository.fetchUploadedContent(_userProfile!.uploadedContent);
      }
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Error in UserProvider.fetchUserProfileAndContent: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUserProfile(User user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _userProfile = await _userRepository.updateUserProfile(user);
      logger.i('User profile updated successfully.');
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Error in UserProvider.updateUserProfile: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> followUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _userRepository.followUser(userId);
      if (success && _userProfile != null) {
        _userProfile = _userProfile!.copyWith(
          followersCount: _userProfile!.followersCount + 1,
          isFollowing: true,
        );
        logger.i('Successfully followed user $userId');
      }
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Error in UserProvider.followUser: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> unfollowUser(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final success = await _userRepository.unfollowUser(userId);
      if (success && _userProfile != null) {
        _userProfile = _userProfile!.copyWith(
          followersCount: _userProfile!.followersCount - 1,
          isFollowing: false,
        );
        logger.i('Successfully unfollowed user $userId');
      }
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Error in UserProvider.unfollowUser: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    }
}