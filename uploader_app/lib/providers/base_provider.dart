import 'package:flutter/foundation.dart';

/// Base provider class with common functionality
abstract class BaseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  bool _isInitialized = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInitialized => _isInitialized;

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void setError(String? error) {
    if (_error != error) {
      _error = error;
      notifyListeners();
    }
  }

  void setInitialized(bool initialized) {
    if (_isInitialized != initialized) {
      _isInitialized = initialized;
      notifyListeners();
    }
  }

  void clearError() {
    setError(null);
  }

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      setLoading(true);
      setError(null);
      await onInitialize();
      setInitialized(true);
    } catch (e) {
      setError(e.toString());
      debugPrint('Error initializing provider: $e');
    } finally {
      setLoading(false);
    }
  }

  Future<void> onInitialize() async {
    // Override in subclasses
  }

  @override
  void dispose() {
    onDispose();
    super.dispose();
  }

  void onDispose() {
    // Override in subclasses for cleanup
  }
}