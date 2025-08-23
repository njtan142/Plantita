
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/ui/widgets/responsive_grid_layout.dart';
import 'package:user_app/state_management/timelapse_provider.dart';
import 'package:user_app/ui/widgets/error_state_widget.dart';

class TimelapseGallery extends StatefulWidget {
  const TimelapseGallery({Key? key}) : super(key: key);

  @override
  State<TimelapseGallery> createState() => _TimelapseGalleryState();
}

class _TimelapseGalleryState extends State<TimelapseGallery> {
  final ScrollController _scrollController = ScrollController();

  String _selectedPlantType = 'All';
  String _selectedDuration = 'All'; // Assuming duration filter

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
                  ...timelapseProvider.timelapses.map((timelapse) => Card(
                    child: Center(
                      child: Text(timelapse.title),
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
