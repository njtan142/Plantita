
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/ui/widgets/app_bar_with_search.dart';
import 'package:user_app/ui/widgets/responsive_grid_layout.dart';
import 'package:user_app/state_management/content_provider.dart';
import 'package:user_app/ui/widgets/error_state_widget.dart';
import 'package:user_app/data/models/reel.dart';
import 'package:user_app/data/models/timelapse.dart';

class ContentDiscoveryScreen extends StatefulWidget {
  const ContentDiscoveryScreen({Key? key}) : super(key: key);

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

    // TODO: Implement infinite scroll with actual data fetching
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !Provider.of<ContentProvider>(context, listen: false).isLoading) {
        // Implement pagination here
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
          if (contentProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (contentProvider.errorMessage != null) {
            return ErrorStateWidget(
              message: contentProvider.errorMessage!,
              onRetry: () => _searchContent(),
            );
          } else {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Trending Content',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 200, // Adjust height as needed
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: contentProvider.trendingContent.length,
                        itemBuilder: (context, index) {
                          final item = contentProvider.trendingContent[index];
                          String title = '';
                          if (item is Reel) {
                            title = item.title;
                          } else if (item is Timelapse) {
                            title = item.title;
                          }
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 150, // Adjust width as needed
                              child: Center(child: Text(title)),
                            ),
                          );
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Popular Content',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 200, // Adjust height as needed
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: contentProvider.popularContent.length,
                        itemBuilder: (context, index) {
                          final item = contentProvider.popularContent[index];
                          String title = '';
                          if (item is Reel) {
                            title = item.title;
                          } else if (item is Timelapse) {
                            title = item.title;
                          }
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 150, // Adjust width as needed
                              child: Center(child: Text(title)),
                            ),
                          );
                        },
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'All Content',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (contentProvider.content.isEmpty)
                      const Center(child: Text('No content found.'))
                    else
                      ResponsiveGridLayout(
                        controller: _scrollController,
                        children: [
                          ...contentProvider.content.map((item) {
                            String title = '';
                            if (item is Reel) {
                              title = item.title;
                            } else if (item is Timelapse) {
                              title = item.title;
                            }
                            return Card(
                              child: Center(
                                child: Text(title),
                              ),
                            );
                          }).toList(),
                        ],
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
}
