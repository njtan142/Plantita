
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/ui/widgets/app_bar_with_search.dart';
import 'package:user_app/state_management/content_provider.dart';
import 'package:user_app/ui/widgets/error_state_widget.dart';
import 'package:user_app/data/models/reel.dart';
import 'package:user_app/data/models/timelapse.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !Provider.of<ContentProvider>(context, listen: false).isLoading) {
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
                        'Recommended Content',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 200, // Adjust height as needed
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: contentProvider.recommendedContent.length,
                        itemBuilder: (context, index) {
                          final item = contentProvider.recommendedContent[index];
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
                      ...contentProvider.content.map((item) {
                          return GestureDetector(
                            onLongPress: () {
                              _showContentContextMenu(context, item);
                            },
                            child: Card(
                              child: InteractiveViewer(
                                child: item.thumbnailUrl.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: item.thumbnailUrl,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                      )
                                    : const Center(child: Text('No Thumbnail')),
                              ),
                            ),
                          );
                        }),
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
                  // TODO: Navigate to content detail screen based on type
                  if (contentItem is Reel) {
                    print('View details for Reel: ${contentItem.title}');
                  } else if (contentItem is Timelapse) {
                    print('View details for Timelapse: ${contentItem.title}');
                  }
                },
              ),
              // Add other relevant actions like share, add to playlist, etc.
              // These would need to be implemented based on content type
            ],
          ),
        );
      },
    );
  }
}
