
import 'package:flutter/material.dart';
import 'package:user_app/ui/widgets/app_bar_with_search.dart';
import 'package:user_app/ui/widgets/responsive_grid_layout.dart';

class ContentDiscoveryScreen extends StatefulWidget {
  const ContentDiscoveryScreen({Key? key}) : super(key: key);

  @override
  State<ContentDiscoveryScreen> createState() => _ContentDiscoveryScreenState();
}

class _ContentDiscoveryScreenState extends State<ContentDiscoveryScreen> {
  final ScrollController _scrollController = ScrollController();
  List<String> _contentItems = [];
  bool _isLoadingMore = false;
  int _currentPage = 0;
  final int _itemsPerPage = 30;

  String _selectedCategory = 'All';
  String _selectedSortOption = 'Popularity';

  final List<String> _categories = ['All', 'Reels', 'Timelapses', 'Community'];
  final List<String> _sortOptions = ['Popularity', 'Newest', 'Oldest'];

  @override
  void initState() {
    super.initState();
    _loadMoreItems();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isLoadingMore) {
        _loadMoreItems();
      }
    });
  }

  Future<void> _loadMoreItems() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    // Simulate network delay and apply filtering/sorting
    await Future.delayed(const Duration(seconds: 2));

    final newItems = List.generate(_itemsPerPage, (index) {
      return 'Content Item ${(_currentPage * _itemsPerPage) + index + 1} (Category: $_selectedCategory, Sort: $_selectedSortOption)';
    });

    setState(() {
      _contentItems.addAll(newItems);
      _currentPage++;
      _isLoadingMore = false;
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _contentItems.clear();
      _currentPage = 0;
    });
    await _loadMoreItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithSearch(
        title: 'Discover Content',
        actions: [
          DropdownButton<String>(
            value: _selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue!;
              });
              _handleRefresh();
            },
            items: _categories.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(width: 10),
          DropdownButton<String>(
            value: _selectedSortOption,
            onChanged: (String? newValue) {
              setState(() {
                _selectedSortOption = newValue!;
              });
              _handleRefresh();
            },
            items: _sortOptions.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                ElevatedButton(onPressed: () {}, child: const Text('Trending')),
                ElevatedButton(onPressed: () {}, child: const Text('Categories')),
                ElevatedButton(onPressed: () {}, child: const Text('Recommended')),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ResponsiveGridLayout(
                controller: _scrollController,
                children: [
                ..._contentItems.map((item) => Card(
                  child: Center(
                    child: Text(item),
                  ),
                )).toList(),
                if (_isLoadingMore)
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
