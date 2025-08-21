import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_token_model.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'base_provider.dart';

class AuthProvider extends BaseProvider {
  final AuthService _authService;

  AuthToken? _authToken;
  User? _currentUser;
  bool _isAuthenticated = false;

  AuthProvider(this._authService);

  AuthToken? get authToken => _authToken;
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  @override
  Future<void> onInitialize() async {
    await _loadPersistedAuth();
  }

  Future<void> _loadPersistedAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenJson = prefs.getString('auth_token');
      final userJson = prefs.getString('current_user');

      if (tokenJson != null && userJson != null) {
        _authToken = AuthToken.fromJson(tokenJson);
        _currentUser = User.fromJson(userJson);

        // Check if token is still valid
        if (_authToken!.isExpired) {
          await logout();
        } else {
          _isAuthenticated = true;
        }
      }
    } catch (e) {
      debugPrint('Error loading persisted auth: $e');
      await logout();
    }
  }

  Future<void> _persistAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_authToken != null && _currentUser != null) {
        await prefs.setString('auth_token', _authToken!.toJson());
        await prefs.setString('current_user', _currentUser!.toJson());
      }
    } catch (e) {
      debugPrint('Error persisting auth: $e');
    }
  }

  Future<void> _clearPersistedAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('current_user');
    } catch (e) {
      debugPrint('Error clearing persisted auth: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    try {
      setLoading(true);
      clearError();

      final response = await _authService.login(email, password);

      if (response.success && response.data != null) {
        _authToken = response.data!.token;
        _currentUser = response.data!.user;
        _isAuthenticated = true;

        await _persistAuth();
        notifyListeners();
        return true;
      } else {
        setError(response.message ?? 'Login failed');
        return false;
      }
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      setLoading(true);
      clearError();

      final response = await _authService.register(email, password, name);

      if (response.success && response.data != null) {
        _authToken = response.data!.token;
        _currentUser = response.data!.user;
        _isAuthenticated = true;

        await _persistAuth();
        notifyListeners();
        return true;
      } else {
        setError(response.message ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      setLoading(true);
      clearError();

      final response = await _authService.forgotPassword(email);

      if (response.success) {
        return true;
      } else {
        setError(response.message ?? 'Failed to send reset email');
        return false;
      }
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  Future<void> logout() async {
    try {
      setLoading(true);
      clearError();

      // Call logout API if token exists
      if (_authToken != null) {
        await _authService.logout(_authToken!.accessToken);
      }
    } catch (e) {
      debugPrint('Error during logout API call: $e');
    } finally {
      // Always clear local state regardless of API call result
      _authToken = null;
      _currentUser = null;
      _isAuthenticated = false;

      await _clearPersistedAuth();
      setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> refreshToken() async {
    try {
      if (_authToken == null) return false;

      final response = await _authService.refreshToken(_authToken!.refreshToken);

      if (response.success && response.data != null) {
        _authToken = response.data;
        await _persistAuth();
        notifyListeners();
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      await logout();
      return false;
    }
  }

  Future<bool> updateProfile(User updatedUser) async {
    try {
      if (_currentUser == null || _authToken == null) return false;

      setLoading(true);
      clearError();

      final response = await _authService.updateProfile(
        _authToken!.accessToken,
        updatedUser,
      );

      if (response.success && response.data != null) {
        _currentUser = response.data;
        await _persistAuth();
        notifyListeners();
        return true;
      } else {
        setError(response.message ?? 'Failed to update profile');
        return false;
      }
    } catch (e) {
      setError(e.toString());
      return false;
    } finally {
      setLoading(false);
    }
  }

  String? getAuthHeader() {
    return _authToken?.accessToken != null
        ? 'Bearer ${_authToken!.accessToken}'
        : null;
  }

  @override
  void onDispose() {
    // Cleanup resources
    super.onDispose();
  }
}