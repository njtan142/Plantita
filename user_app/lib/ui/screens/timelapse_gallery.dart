
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/ui/widgets/responsive_grid_layout.dart';
import 'package:user_app/state_management/timelapse_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:user_app/ui/widgets/responsive_grid_layout.dart';
import 'package:user_app/state_management/timelapse_provider.dart';
import 'package:user_app/ui/widgets/error_state_widget';
import 'package:user_app/data/models/timelapse.dart';

class TimelapseGallery extends StatefulWidget {
  const TimelapseGallery({Key? key}) : super(key: key);

  @override
  State<TimelapseGallery> createState() => _TimelapseGalleryState();
}

class _TimelapseGalleryState extends State<TimelapseGallery> {
  final ScrollController _scrollController = ScrollController();

  String _selectedPlantType = 'All';
  String _selectedDuration = 'All'; // Assuming duration filter
  List<Timelapse> _selectedTimelapses = [];

  final List<String> _plantTypes = ['All', 'Rose', 'Sunflower', 'Tulip'];
  final List<String> _durations = ['All', 'Short', 'Medium', 'Long']; // Example durations

  @override
  void initState() {
    super.initState();
    // Fetch timelapses when the view is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TimelapseProvider>(context, listen: false).fetchTimelapses(
        plantType: _selectedPlantType,
        duration: _selectedDuration,
      );
    });

    // TODO: Implement infinite scroll with actual data fetching
    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !Provider.of<TimelapseProvider>(context, listen: false).isLoading) {
        // _loadMoreItems(); // This will be replaced with actual pagination logic
      }
    });
  }

  Future<void> _handleRefresh() async {
    await Provider.of<TimelapseProvider>(context, listen: false).fetchTimelapses(
      plantType: _selectedPlantType,
      duration: _selectedDuration,
    );
  }

  void _toggleTimelapseSelection(Timelapse timelapse) {
    setState(() {
      if (_selectedTimelapses.contains(timelapse)) {
        _selectedTimelapses.remove(timelapse);
      } else if (_selectedTimelapses.length < 2) {
        _selectedTimelapses.add(timelapse);
      } else {
        // Optionally, show a message that only 2 can be selected
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can only select up to 2 timelapses for comparison.')),
        );
      }
    });
  }

  void _compareSelectedTimelapses() {
    if (_selectedTimelapses.length == 2) {
      context.go('/compare-timelapses', extra: {
        'timelapse1': _selectedTimelapses[0],
        'timelapse2': _selectedTimelapses[1],
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select exactly 2 timelapses to compare.')),
      );
    }
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
            value: _selectedDuration,
            onChanged: (String? newValue) {
              setState(() {
                _selectedDuration = newValue!;
              });
              _handleRefresh();
            },
            items: _durations.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(width: 10),
          if (_selectedTimelapses.length == 2)
            IconButton(
              icon: const Icon(Icons.compare),
              onPressed: _compareSelectedTimelapses,
              tooltip: 'Compare Selected',
            ),
          const SizedBox(width: 10),
        ],
      ),
      body: Consumer<TimelapseProvider>(
        builder: (context, timelapseProvider, child) {
          if (timelapseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (timelapseProvider.errorMessage != null) {
            return ErrorStateWidget(
              message: timelapseProvider.errorMessage!,
              onRetry: () => timelapseProvider.fetchTimelapses(
                plantType: _selectedPlantType,
                duration: _selectedDuration,
              ),
            );
          } else if (timelapseProvider.timelapses.isEmpty) {
            return const Center(child: Text('No timelapses available.'));
          } else {
            return RefreshIndicator(
              onRefresh: _handleRefresh,
              child: ResponsiveGridLayout(
                controller: _scrollController,
                children: [
                  ...timelapseProvider.timelapses.map((timelapse) => GestureDetector(
                    onLongPress: () {
                      _showTimelapseContextMenu(context, timelapse);
                    },
                    child: Card(
                      color: _selectedTimelapses.contains(timelapse) ? Colors.blue.withOpacity(0.5) : null,
                      child: InkWell(
                        onTap: () => _toggleTimelapseSelection(timelapse),
                        child: Stack(
                          children: [
                            Center(
                              child: Text(timelapse.title),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.playlist_add),
                                    onPressed: () => _showAddToPlaylistDialog(timelapse),
                                    tooltip: 'Add to Playlist',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.download),
                                    onPressed: () => timelapseProvider.downloadTimelapse(timelapse.videoUrl),
                                    tooltip: 'Download Timelapse',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )).toList(),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  void _showTimelapseContextMenu(BuildContext context, Timelapse timelapse) {
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
                  // TODO: Navigate to Timelapse Detail Screen
                  print('View details for ${timelapse.title}');
                },
              ),
              ListTile(
                leading: const Icon(Icons.playlist_add),
                title: const Text('Add to Playlist'),
                onTap: () {
                  Navigator.pop(bc);
                  _showAddToPlaylistDialog(timelapse);
                },
              ),
              ListTile(
                leading: const Icon(Icons.download),
                title: const Text('Download'),
                onTap: () {
                  Navigator.pop(bc);
                  Provider.of<TimelapseProvider>(context, listen: false).downloadTimelapse(timelapse.videoUrl);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}



