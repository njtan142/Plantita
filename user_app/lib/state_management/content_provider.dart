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
  int _currentPage = 0;
  bool _hasMore = true;

  ContentProvider(this._contentRepository);

  List<dynamic> get content => _content;
  List<dynamic> get trendingContent => _trendingContent;
  List<dynamic> get popularContent => _popularContent;
  List<dynamic> get recommendedContent => _recommendedContent;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;

  Future<void> searchContent({
    String? query,
    String? contentType,
    String? category,
    String? sortBy,
    bool isLoadMore = false,
  }) async {
    if (_isLoading || (!_hasMore && isLoadMore)) return; // Prevent multiple loads or loading if no more data

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newContent = await _contentRepository.searchContent(
        query: query,
        contentType: contentType,
        category: category,
        sortBy: sortBy,
        page: _currentPage + 1,
        limit: 10, // Define a limit for pagination
      );

      if (isLoadMore) {
        _content.addAll(newContent);
      } else {
        _content = newContent;
      }

      _currentPage++;
      _hasMore = newContent.length == 10; // Assuming limit is 10

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