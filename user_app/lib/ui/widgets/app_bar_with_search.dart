import 'package:flutter/material.dart';

class AppBarWithSearch extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final ValueChanged<String>? onSearchChanged;

  const AppBarWithSearch({super.key, required this.title, this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            // TODO: Implement search functionality
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
    // TODO: Implement search results display
    return Center(child: Text('Search results for: $query'));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Type to start searching'));
    }

    return ListView(
      children: [
        ListTile(
          leading: const Icon(Icons.search),
          title: Text('Search for "$query"'),
          onTap: () {
            showResults(context);
          },
        ),
      ],
    );
  }
}
