import 'package:flutter/material.dart';
import 'package:user_app/data/repositories/content_repository.dart';
import 'package:user_app/utils/logger.dart';

class ContentProvider with ChangeNotifier {
  final ContentRepository _contentRepository;
  List<dynamic> _content = [];
  List<dynamic> _trendingContent = [];
  List<dynamic> _popularContent = [];
  List<dynamic> _recommendedContent = [];
  bool _isLoading = false;
  String? _errorMessage;

  ContentProvider(this._contentRepository);

  List<dynamic> get content => _content;
  List<dynamic> get trendingContent => _trendingContent;
  List<dynamic> get popularContent => _popularContent;
  List<dynamic> get recommendedContent => _recommendedContent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> searchContent({
    String? query,
    String? contentType,
    String? category,
    String? sortBy,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _content = await _contentRepository.searchContent(
        query: query,
        contentType: contentType,
        category: category,
        sortBy: sortBy,
      );
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Error in ContentProvider.searchContent: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTrendingContent() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _trendingContent = await _contentRepository.fetchTrendingContent();
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Error in ContentProvider.fetchTrendingContent: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPopularContent() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _popularContent = await _contentRepository.fetchPopularContent();
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Error in ContentProvider.fetchPopularContent: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecommendedContent() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _recommendedContent = await _contentRepository.fetchRecommendedContent();
    } catch (e) {
      _errorMessage = e.toString();
      logger.e('Error in ContentProvider.fetchRecommendedContent: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}