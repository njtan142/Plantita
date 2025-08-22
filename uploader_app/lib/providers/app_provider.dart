import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;

  // Loading state management
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Error handling
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Theme management
  Future<void> setThemeMode(ThemeMode themeMode) async {
    _themeMode = themeMode;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', themeMode.name);
    } catch (e) {
      setError('Failed to save theme preference');
    }
  }

  Future<void> loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString('theme_mode');
      if (themeString != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (mode) => mode.name == themeString,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      setError('Failed to load theme preference');
    }
  }

  // Initialization
  Future<void> initialize() async {
    if (_isInitialized) return;

    setLoading(true);
    clearError();

    try {
      await loadThemeMode();
      _isInitialized = true;
    } catch (e) {
      setError('Failed to initialize app: $e');
    } finally {
      setLoading(false);
    }
  }

  // Reset app state
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _isInitialized = false;
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}