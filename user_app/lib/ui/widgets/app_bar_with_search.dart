
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:user_app/data/repositories/content_repository.dart';
import 'package:user_app/data/models/reel.dart';
import 'package:user_app/data/models/timelapse.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';

class AppBarWithSearch extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final ValueChanged<String>? onSearchChanged;
  final List<Widget>? actions;

  const AppBarWithSearch({
    Key? key,
    required this.title,
    this.onSearchChanged,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () async {
            final result = await showSearch(
              context: context,
              delegate: _SearchDelegate(),
            );
            if (result != null && onSearchChanged != null) {
              onSearchChanged!(result);
            }
          },
        ),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _SearchDelegate extends SearchDelegate<String> {
  Future<List<dynamic>>? _searchResults;
  String _lastQuery = '';

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
    if (query.isEmpty) {
      return const Center(child: Text('Enter a search term'));
    }

    if (query != _lastQuery) {
      _lastQuery = query;
      final contentRepository = GetIt.instance<ContentRepository>();
      _searchResults = contentRepository.searchContent(query: query);
    }

    return FutureBuilder<List<dynamic>>(
      future: _searchResults,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No results found.'));
        }

        final results = snapshot.data!;
        return ListView.builder(
          itemCount: results.length,
          itemBuilder: (context, index) {
            final item = results[index];
            String title = '';
            String thumbnailUrl = '';

            if (item is Reel) {
              title = item.title;
              thumbnailUrl = item.thumbnailUrl;
            } else if (item is Timelapse) {
              title = item.title;
              thumbnailUrl = item.thumbnailUrl;
            }

            return ListTile(
              leading: thumbnailUrl.isNotEmpty
                  ? SizedBox(
                      width: 50,
                      height: 50,
                      child: CachedNetworkImage(
                        imageUrl: thumbnailUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    )
                  : const Icon(Icons.video_library, size: 50),
              title: Text(title),
              subtitle: Text(item is Reel ? 'Reel' : (item is Timelapse ? 'Timelapse' : '')),
              onTap: () {
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
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return const Center(child: Text('Type to search for reels and timelapses.'));
  }
}
