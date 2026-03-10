import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';
import 'http_client_service.dart';

class _CachedSearchUser {
  final UserModel user;
  final String usernameLower;
  final String firstNameLower;
  final String lastNameLower;
  final String emailLower;

  _CachedSearchUser(this.user)
      : usernameLower = user.username.toLowerCase(),
        firstNameLower = user.firstName.toLowerCase(),
        lastNameLower = user.lastName.toLowerCase(),
        emailLower = user.email.toLowerCase();
}

/// User Management Service for handling user operations and caching
class UserService {
  static const String _usersCacheKey = 'cached_users';
  static const String _cacheTimestampKey = 'users_cache_timestamp';
  static const Duration _cacheValidityDuration = Duration(minutes: 30);

  final HttpClientService _httpClient;
  final SharedPreferences _prefs;

  // In-memory cache
  List<UserModel> _cachedUsers = [];
  List<_CachedSearchUser> _searchableUsers = [];

  void _updateCachedUsers(List<UserModel> users) {
    _cachedUsers = users;
    _searchableUsers = _cachedUsers.map((u) => _CachedSearchUser(u)).toList();
    _usersController.add(_cachedUsers);
  }

  DateTime? _lastFetchTime;
  bool _isLoading = false;

  // Cache for user search strings to avoid repeated toLowerCase() calls
  final Expando<List<String>> _userSearchIndex = Expando<List<String>>();

  // Stream controllers for reactive updates
  final StreamController<List<UserModel>> _usersController =
      StreamController<List<UserModel>>.broadcast();
  final StreamController<bool> _loadingController =
      StreamController<bool>.broadcast();

  UserService({
    required HttpClientService httpClient,
    required SharedPreferences prefs,
  }) : _httpClient = httpClient,
       _prefs = prefs;

  /// Stream of users for reactive updates
  Stream<List<UserModel>> get usersStream => _usersController.stream;

  /// Stream of loading state
  Stream<bool> get loadingStream => _loadingController.stream;

  /// Current cached users
  List<UserModel> get currentUsers => List.unmodifiable(_cachedUsers);

  /// Check if data is currently loading
  bool get isLoading => _isLoading;

  /// Check if cache is valid
  bool get _isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidityDuration;
  }

  /// Initialize service and load cached data
  Future<void> initialize() async {
    await _loadCachedUsers();

    // Load from cache if valid
    if (_isCacheValid && _cachedUsers.isNotEmpty) {
      _usersController.add(_cachedUsers);
    } else {
      // Fetch fresh data in background
      fetchUsers();
    }
  }

  /// Fetch all users from API with caching
  Future<ApiResponse<List<UserModel>>> fetchUsers({
    bool forceRefresh = false,
    Map<String, dynamic>? filters,
  }) async {
    // Return cached data if valid and not forcing refresh
    if (!forceRefresh && _isCacheValid && _cachedUsers.isNotEmpty) {
      return ApiResponse.success(_cachedUsers);
    }

    if (_isLoading) {
      // Wait for current operation to complete
      await loadingStream.firstWhere((loading) => !loading);
      return ApiResponse.success(_cachedUsers);
    }

    _isLoading = true;
    _loadingController.add(true);

    try {
      final queryParams = <String, dynamic>{};
      if (filters != null) {
        queryParams.addAll(filters);
      }

      final response = await _httpClient.get<PaginatedResponse<UserModel>>(
        '/users',
        queryParams: queryParams,
        fromJson: (json) => PaginatedResponse<UserModel>.fromJson(
          json,
          (userJson) => UserModel.fromJson(userJson as String),
        ),
      );

      if (response.success && response.data != null) {
        _updateCachedUsers(response.data!.items);
        _lastFetchTime = DateTime.now();

        // Update cache
        await _saveUsersToCache(_cachedUsers);
      }

      _isLoading = false;
      _loadingController.add(false);

      return response.success
          ? ApiResponse.success(response.data?.items ?? [])
          : ApiResponse.error(
              message: response.message ?? 'Failed to fetch users',
              statusCode: response.statusCode,
              errors: response.errors,
            );
    } catch (e) {
      _isLoading = false;
      _loadingController.add(false);

      return ApiResponse.error(
        message: 'Failed to fetch users: ${e.toString()}',
      );
    }
  }

  /// Search users by query
  Future<ApiResponse<List<UserModel>>> searchUsers(String query) async {
    if (query.trim().isEmpty) {
      return ApiResponse.success(_cachedUsers);
    }

    try {
      final response = await _httpClient.get<List<UserModel>>(
        '/users/search',
        queryParams: {'q': query},
        fromJson: (dynamic json) {
          if (json is List) {
            return json
                .map<UserModel>(
                  (userJson) =>
                      UserModel.fromJson(userJson as String),
                )
                .toList();
          }
          return <UserModel>[];
        },
      );

      if (response.success && response.data != null) {
        return response;
      }

      if (response.success && response.data != null) {
        return response;
      }

      if (response.success && response.data != null) {
        // Update cache with search results but don't replace main cache
        return response;
      }

      return response;
    } catch (e) {
      return ApiResponse.error(message: 'Search failed: ${e.toString()}');
    }
  }

  /// Get user by ID
  Future<ApiResponse<UserModel>> getUserById(int userId) async {
    // Check cache first
    final cachedUser = _cachedUsers
        .where((user) => user.id == userId)
        .cast<UserModel?>()
        .firstWhere((element) => true, orElse: () => null);

    if (cachedUser != null) {
      return ApiResponse.success(cachedUser);
    }

    try {
      final response = await _httpClient.get<UserModel>(
        '/users/$userId',
        fromJson: (json) => UserModel.fromJson(json as String),
      );

      // Add to cache if successful
      if (response.success && response.data != null) {
        final updatedUsers = List<UserModel>.from(_cachedUsers)..add(response.data!);
        _updateCachedUsers(updatedUsers);
        await _saveUsersToCache(_cachedUsers);
      }

      return response;
    } catch (e) {
      return ApiResponse.error(
        message: 'Failed to fetch user: ${e.toString()}',
      );
    }
  }

  /// Filter users by criteria
  List<UserModel> filterUsers({
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    bool? isActive,
    DateTime? createdAfter,
    DateTime? createdBefore,
  }) {
    final searchUsername = username?.toLowerCase();
    final searchEmail = email?.toLowerCase();
    final searchFirstName = firstName?.toLowerCase();
    final searchLastName = lastName?.toLowerCase();

    return _searchableUsers.where((su) {
      if (searchUsername != null &&
          !su.usernameLower.contains(searchUsername)) {
        return false;
      }
      if (searchEmail != null &&
          !su.emailLower.contains(searchEmail)) {
        return false;
      }
      if (searchFirstName != null &&
          !su.firstNameLower.contains(searchFirstName)) {
        return false;
      }
      if (searchLastName != null &&
          !su.lastNameLower.contains(searchLastName)) {
        return false;
      }
      if (isActive != null && su.user.isActive != isActive) {
        return false;
      }
      if (createdAfter != null && su.user.createdAt.isBefore(createdAfter)) {
        return false;
      }
      if (createdBefore != null && su.user.createdAt.isAfter(createdBefore)) {
        return false;
      }
      return true;
    }).map((su) => su.user).toList();
  }

  /// Helper to get a cached list of lowercase searchable fields for a user
  List<String> _getUserSearchFields(UserModel user) {
    var searchFields = _userSearchIndex[user];
    if (searchFields == null) {
      searchFields = [
        user.username.toLowerCase(),
        user.firstName.toLowerCase(),
        user.lastName.toLowerCase(),
        user.email.toLowerCase(),
      ];
      _userSearchIndex[user] = searchFields;
    }
    return searchFields;
  }

  /// Get users for selection (active users only)
  List<UserModel> getUsersForSelection({String? searchQuery}) {
    var suUsers = _searchableUsers.where((su) => su.user.isActive);

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      suUsers = suUsers.where(
        (su) => _getUserSearchFields(su.user).any((field) => field.contains(query)),
      );
    }

    return suUsers.map((su) => su.user).toList();
  }

  /// Refresh user data
  Future<void> refreshUsers() async {
    await fetchUsers(forceRefresh: true);
  }

  /// Clear cache
  Future<void> clearCache() async {
    _updateCachedUsers([]);
    _lastFetchTime = null;
    await _prefs.remove(_usersCacheKey);
    await _prefs.remove(_cacheTimestampKey);
  }

  /// Load users from local cache
  Future<void> _loadCachedUsers() async {
    try {
      final usersJson = _prefs.getString(_usersCacheKey);
      final timestamp = _prefs.getInt(_cacheTimestampKey);

      if (usersJson != null && timestamp != null) {
        final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        if (DateTime.now().difference(cachedTime) < _cacheValidityDuration) {
          final usersList = jsonDecode(usersJson) as List;
          final loadedUsers = usersList
              .map((userJson) => UserModel.fromJson(userJson))
              .toList();
          _updateCachedUsers(loadedUsers);
          _lastFetchTime = cachedTime;
        }
      }
    } catch (e) {
      // Clear corrupted cache
      await clearCache();
    }
  }

  /// Save users to local cache
  Future<void> _saveUsersToCache(List<UserModel> users) async {
    try {
      final usersJson = jsonEncode(users.map((user) => user.toJson()).toList());
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      await _prefs.setString(_usersCacheKey, usersJson);
      await _prefs.setInt(_cacheTimestampKey, timestamp);
    } catch (e) {
      // Cache save failed, not critical
    }
  }

  /// Get user statistics
  UserStats getUserStats() {
    final total = _cachedUsers.length;
    final active = _cachedUsers.where((user) => user.isActive).length;
    final inactive = total - active;

    final recentUsers = _cachedUsers.where((user) {
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      return user.createdAt.isAfter(weekAgo);
    }).length;

    return UserStats(
      totalUsers: total,
      activeUsers: active,
      inactiveUsers: inactive,
      recentUsers: recentUsers,
    );
  }

  /// Dispose service and clean up resources
  void dispose() {
    _usersController.close();
    _loadingController.close();
  }

  // Testing methods - not for production use
  @visibleForTesting
  void setCachedUsersForTesting(List<UserModel> users) {
    _updateCachedUsers(users);
  }

  @visibleForTesting
  void setLastFetchTimeForTesting(DateTime? time) {
    _lastFetchTime = time;
  }

  @visibleForTesting
  bool get isCacheValidForTesting => _isCacheValid;

  @visibleForTesting
  DateTime? get lastFetchTimeForTesting => _lastFetchTime;

  @visibleForTesting
  List<UserModel> get cachedUsersForTesting => List.unmodifiable(_cachedUsers);

  @visibleForTesting
  void addLoadingStateForTesting(bool isLoading) {
    _loadingController.add(isLoading);
  }

  @visibleForTesting
  void addUsersUpdateForTesting(List<UserModel> users) {
    _usersController.add(users);
  }
}

/// User statistics model
class UserStats {
  final int totalUsers;
  final int activeUsers;
  final int inactiveUsers;
  final int recentUsers;

  const UserStats({
    required this.totalUsers,
    required this.activeUsers,
    required this.inactiveUsers,
    required this.recentUsers,
  });

  @override
  String toString() {
    return 'UserStats(total: $totalUsers, active: $activeUsers, inactive: $inactiveUsers, recent: $recentUsers)';
  }
}
