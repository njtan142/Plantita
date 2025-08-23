
import 'package:flutter/material.dart';
import 'package:user_app/ui/widgets/responsive_grid_layout.dart';

class TimelapseGallery extends StatefulWidget {
  const TimelapseGallery({Key? key}) : super(key: key);

  @override
  State<TimelapseGallery> createState() => _TimelapseGalleryState();
}

class _TimelapseGalleryState extends State<TimelapseGallery> {
  final ScrollController _scrollController = ScrollController();
  List<String> _timelapseItems = [];
  bool _isLoadingMore = false;
  int _currentPage = 0;
  final int _itemsPerPage = 20;

  String _selectedPlantType = 'All';
  String _selectedSortOption = 'Newest';

  final List<String> _plantTypes = ['All', 'Rose', 'Sunflower', 'Tulip'];
  final List<String> _sortOptions = ['Newest', 'Oldest', 'Most Viewed'];

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
      return 'Timelapse ${(_currentPage * _itemsPerPage) + index + 1} (Type: $_selectedPlantType, Sort: $_selectedSortOption)';
    });

    setState(() {
      _timelapseItems.addAll(newItems);
      _currentPage++;
      _isLoadingMore = false;
    });
  }

  Future<void> _handleRefresh() async {
    setState(() {
      _timelapseItems.clear();
      _currentPage = 0;
    });
    await _loadMoreItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timelapse Gallery'),
        actions: [
          DropdownButton<String>(
            value: _selectedPlantType,
            onChanged: (String? newValue) {
              setState(() {
                _selectedPlantType = newValue!;
              });
              _handleRefresh();
            },
            items: _plantTypes.map<DropdownMenuItem<String>>((String value) {
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
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: ResponsiveGridLayout(
          controller: _scrollController,
          children: [
          ..._timelapseItems.map((item) => Card(
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
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
