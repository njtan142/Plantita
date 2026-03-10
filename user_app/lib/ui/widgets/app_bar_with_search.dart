import 'package:flutter/material.dart';
import 'package:user_app/main.dart';
import 'package:user_app/data/repositories/content_repository.dart';
import 'package:user_app/data/models/reel.dart';
import 'package:user_app/data/models/timelapse.dart';
import 'package:go_router/go_router.dart';

class AppBarWithSearch extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final ValueChanged<String>? onSearchChanged;

  const AppBarWithSearch({
    Key? key,
    required this.title,
    this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            showSearch(context: context, delegate: _SearchDelegate());
          },
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchDelegate extends SearchDelegate<String> {
  String _lastQuery = '';
  Future<List<dynamic>>? _searchFuture;

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Type to search for content...'));
    }

    if (query != _lastQuery || _searchFuture == null) {
      _lastQuery = query;
      // Fetch results independently from ContentRepository to not affect the
      // global state of ContentProvider used by the background screen.
      final contentRepository = getIt<ContentRepository>();
      _searchFuture = contentRepository.searchContent(
        query: query,
        limit: 10,
      );
    }

    return FutureBuilder<List<dynamic>>(
      future: _searchFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No results found.'));
        } else {
          final results = snapshot.data!;
          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final item = results[index];
              String title = '';
              String subtitle = '';

              if (item is Reel) {
                title = item.title;
                subtitle = 'Reel';
              } else if (item is Timelapse) {
                title = item.title;
                subtitle = 'Timelapse';
              }

              return ListTile(
                leading: const Icon(Icons.video_library),
                title: Text(title),
                subtitle: Text(subtitle),
                onTap: () {
                  // Close the search delegate and navigate to the item
                  close(context, query);
                  if (item is Reel) {
                    context.push('/reels/${item.id}', extra: item);
                  } else if (item is Timelapse) {
                    context.push('/timelapses/${item.id}', extra: item);
                  }
                },
              );
            },
          );
        }
      },
    );
  }
}
