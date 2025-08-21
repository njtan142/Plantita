import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/user_service.dart';
import 'base_provider.dart';

class UserSelectionProvider extends BaseProvider {
  final UserService _userService;

  List<User> _searchResults = [];
  User? _selectedUser;
  String _searchQuery = '';

  UserSelectionProvider(this._userService);

  List<User> get searchResults => _searchResults;
  User? get selectedUser => _selectedUser;
  String get searchQuery => _searchQuery;
  bool get hasSelectedUser => _selectedUser != null;

  void selectUser(User user) {
    _selectedUser = user;
    notifyListeners();
  }

  void clearSelection() {
    _selectedUser = null;
    notifyListeners();
  }

  Future<void> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _searchQuery = '';
      notifyListeners();
      return;
    }

    try {
      setLoading(true);
      clearError();
      _searchQuery = query;

      final response = await _userService.searchUsers(query);

      if (response.success && response.data != null) {
        _searchResults = response.data!;
      } else {
        _searchResults = [];
        setError(response.message ?? 'Failed to search users');
      }
    } catch (e) {
      _searchResults = [];
      setError(e.toString());
    } finally {
      setLoading(false);
    }
  }

  void clearSearchResults() {
    _searchResults = [];
    _searchQuery = '';
    notifyListeners();
  }

  @override
  void onDispose() {
    clearSearchResults();
    clearSelection();
    super.onDispose();
  }
}