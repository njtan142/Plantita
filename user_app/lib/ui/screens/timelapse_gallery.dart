import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:user_app/ui/widgets/responsive_grid_layout.dart';
import 'package:user_app/state_management/timelapse_provider.dart';
import 'package:user_app/ui/widgets/error_state_widget.dart';
import 'package:user_app/data/models/timelapse.dart';
import 'components/timelapse_card.dart';
import 'components/gallery_filters.dart';

class TimelapseGallery extends StatefulWidget {
  const TimelapseGallery({super.key});

  @override
  State<TimelapseGallery> createState() => _TimelapseGalleryState();
}

class _TimelapseGalleryState extends State<TimelapseGallery> {
  final ScrollController _scrollController = ScrollController();

  String _selectedPlantType = 'All';
  String _selectedDuration = 'All';
  final Set<Timelapse> _selectedTimelapses = {};

  final List<String> _plantTypes = ['All', 'Rose', 'Sunflower', 'Tulip'];
  final List<String> _durations = ['All', 'Short', 'Medium', 'Long'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TimelapseProvider>(context, listen: false).fetchTimelapses(
        plantType: _selectedPlantType,
        duration: _selectedDuration,
      );
    });

    _scrollController.addListener(() {
      final provider = Provider.of<TimelapseProvider>(context, listen: false);
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
          !provider.isLoading &&
          provider.hasMore) {
        provider.fetchTimelapses(
          plantType: _selectedPlantType,
          duration: _selectedDuration,
          isLoadMore: true,
        );
      }
    });
  }

  Future<void> _handleRefresh() async {
    final provider = Provider.of<TimelapseProvider>(context, listen: false);
    provider.reset();
    await provider.fetchTimelapses(
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You can only select up to 2 timelapses for comparison.')),
        );
      }
    });
  }

  void _compareSelectedTimelapses() {
    if (_selectedTimelapses.length == 2) {
      context.go('/compare-timelapses', extra: {
        'timelapse1': _selectedTimelapses.elementAt(0),
        'timelapse2': _selectedTimelapses.elementAt(1),
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
          GalleryFilters(
            selectedPlantType: _selectedPlantType,
            selectedDuration: _selectedDuration,
            plantTypes: _plantTypes,
            durations: _durations,
            onPlantTypeChanged: (newValue) {
              setState(() {
                _selectedPlantType = newValue!;
              });
              _handleRefresh();
            },
            onDurationChanged: (newValue) {
              setState(() {
                _selectedDuration = newValue!;
              });
              _handleRefresh();
            },
            selectedCount: _selectedTimelapses.length,
            onCompare: _compareSelectedTimelapses,
          ),
        ],
      ),
      body: Consumer<TimelapseProvider>(
        builder: (context, timelapseProvider, child) {
          if (timelapseProvider.isLoading && timelapseProvider.timelapses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          } else if (timelapseProvider.errorMessage != null &&
              timelapseProvider.timelapses.isEmpty) {
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
                children: timelapseProvider.timelapses.map((timelapse) {
                  return TimelapseCard(
                    timelapse: timelapse,
                    isSelected: _selectedTimelapses.contains(timelapse),
                    onTap: () => _toggleTimelapseSelection(timelapse),
                    onLongPress: () => _showTimelapseContextMenu(context, timelapse),
                    onAddToPlaylist: () => _showAddToPlaylistDialog(timelapse),
                    onDownload: () => timelapseProvider.downloadTimelapse(timelapse.videoUrl),
                  );
                }).toList(),
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
                  context.push('/timelapses/${timelapse.id}', extra: timelapse);
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
                  Provider.of<TimelapseProvider>(context, listen: false)
                      .downloadTimelapse(timelapse.videoUrl);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddToPlaylistDialog(Timelapse timelapse) async {
    final timelapseProvider = Provider.of<TimelapseProvider>(context, listen: false);
    await timelapseProvider.fetchPlaylists();

    if (!mounted) return;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add to Playlist'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (timelapseProvider.playlists.isEmpty)
                  const Text('No playlists available. Create a new one.')
                else
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: timelapseProvider.playlists.length,
                      itemBuilder: (context, index) {
                        final playlist = timelapseProvider.playlists[index];
                        return ListTile(
                          title: Text(playlist.name),
                          subtitle: Text(playlist.description.isEmpty
                              ? 'No description'
                              : playlist.description),
                          trailing: Text('${playlist.timelapseIds.length} timelapses'),
                          onTap: () async {
                            await timelapseProvider.addTimelapseToPlaylist(
                                playlist.id, timelapse.id);
                            if (context.mounted) Navigator.pop(context);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('Added ${timelapse.title} to ${playlist.name}')),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _createPlaylistDialog();
                  },
                  child: const Text('Create New Playlist'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _createPlaylistDialog() async {
    String playlistName = '';
    String playlistDescription = '';

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Create New Playlist'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (value) {
                  playlistName = value;
                },
                decoration: const InputDecoration(hintText: 'Playlist Name'),
              ),
              TextField(
                onChanged: (value) {
                  playlistDescription = value;
                },
                decoration: const InputDecoration(hintText: 'Description (Optional)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (playlistName.isNotEmpty) {
                  await Provider.of<TimelapseProvider>(context, listen: false)
                      .createPlaylist(playlistName, playlistDescription);
                  if (context.mounted) Navigator.pop(context);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Playlist name cannot be empty.')),
                  );
                }
              },
              child: const Text('Create'),
            ),
          ],
        );
      },
    );
  }
}
