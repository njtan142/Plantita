
import 'package:flutter/material.dart';
import 'package:user_app/services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  bool _isAuthenticated = false;

  AuthProvider(this._authService);

  bool get isAuthenticated => _isAuthenticated;

  Future<void> login(String username, String password) async {
    _isAuthenticated = await _authService.login(username, password);
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    notifyListeners();
  }
}
