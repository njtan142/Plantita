import 'package:flutter/material.dart';

class AppBarWithSearch extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final ValueChanged<String>? onSearchChanged;
  final List<Widget>? actions;

  const AppBarWithSearch({
    super.key,
    required this.title,
    this.onSearchChanged,
    this.actions,
  });

  @override
  State<AppBarWithSearch> createState() => _AppBarWithSearchState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarWithSearchState extends State<AppBarWithSearch> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    _searchController.clear();
    widget.onSearchChanged?.call('');
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search...',
                border: InputBorder.none,
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: widget.onSearchChanged,
            )
          : Text(widget.title),
      actions: [
        if (_isSearching)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _stopSearch,
          )
        else
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _startSearch,
          ),
        if (widget.actions != null) ...widget.actions!,
      ],
    );
  }
}
