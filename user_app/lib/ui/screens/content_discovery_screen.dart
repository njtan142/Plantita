import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/ui/widgets/app_bar_with_search.dart';
import 'package:user_app/state_management/content_provider.dart';
import 'package:user_app/ui/widgets/error_state_widget.dart';
import 'package:user_app/data/models/reel.dart';
import 'package:user_app/data/models/timelapse.dart';
import 'components/horizontal_content_list.dart';
import 'components/main_content_grid.dart';

class ContentDiscoveryScreen extends StatefulWidget {
  const ContentDiscoveryScreen({super.key});

  @override
  State<ContentDiscoveryScreen> createState() => _ContentDiscoveryScreenState();
}

class _ContentDiscoveryScreenState extends State<ContentDiscoveryScreen> {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedSortOption = 'Popularity';

  final List<String> _categories = ['All', 'Reels', 'Timelapses', 'Community'];
  final List<String> _sortOptions = ['Popularity', 'Newest', 'Oldest'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchContent();
      Provider.of<ContentProvider>(context, listen: false).fetchTrendingContent();
      Provider.of<ContentProvider>(context, listen: false).fetchPopularContent();
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && 
          !Provider.of<ContentProvider>(context, listen: false).isLoading) {
        _loadMoreContent();
      }
    });
  }

  void _searchContent() {
    Provider.of<ContentProvider>(context, listen: false).searchContent(
      query: _searchQuery,
      category: _selectedCategory,
      sortBy: _selectedSortOption,
    );
  }

  void _loadMoreContent() {
    Provider.of<ContentProvider>(context, listen: false).searchContent(
      query: _searchQuery,
      category: _selectedCategory,
      sortBy: _selectedSortOption,
      isLoadMore: true,
    );
  }

  Future<void> _handleRefresh() async {
    _searchContent();
    Provider.of<ContentProvider>(context, listen: false).fetchTrendingContent();
    Provider.of<ContentProvider>(context, listen: false).fetchPopularContent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithSearch(
        title: 'Discover Content',
        onSearchChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
          _searchContent();
        },
        actions: [
          DropdownButton<String>(
            value: _selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                _selectedCategory = newValue!;
              });
              _searchContent();
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
              _searchContent();
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
      body: Consumer<ContentProvider>(
        builder: (context, contentProvider, child) {
          if (contentProvider.isLoading && contentProvider.content.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (contentProvider.errorMessage != null && contentProvider.content.isEmpty) {
            return ErrorStateWidget(
              message: contentProvider.errorMessage!,
              onRetry: () => _searchContent(),
            );
          } else {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    HorizontalContentList(
                      title: 'Trending Content',
                      items: contentProvider.trendingContent,
                    ),
                    HorizontalContentList(
                      title: 'Popular Content',
                      items: contentProvider.popularContent,
                    ),
                    HorizontalContentList(
                      title: 'Recommended Content',
                      items: contentProvider.recommendedContent,
                    ),
                    MainContentGrid(
                      items: contentProvider.content,
                      onLongPress: (item) => _showContentContextMenu(context, item),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showContentContextMenu(BuildContext context, dynamic contentItem) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('View Details'),
                onTap: () {
                  Navigator.pop(bc);
                  if (contentItem is Reel) {
                    debugPrint('View details for Reel: ${contentItem.title}');
                  } else if (contentItem is Timelapse) {
                    debugPrint('View details for Timelapse: ${contentItem.title}');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
