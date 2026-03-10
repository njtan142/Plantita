
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:user_app/ui/widgets/responsive_grid_layout.dart';
import 'package:user_app/state_management/timelapse_provider.dart';
import 'package:user_app/ui/widgets/error_state_widget.dart';
import 'package:user_app/data/models/timelapse.dart';
import 'package:cached_network_image/cached_network_image.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TimelapseProvider>(context, listen: false).fetchTimelapses(
        plantType: _selectedPlantType,
        duration: _selectedDuration,
      );
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !Provider.of<TimelapseProvider>(context, listen: false).isLoading && Provider.of<TimelapseProvider>(context, listen: false).hasMore) {
        Provider.of<TimelapseProvider>(context, listen: false).fetchTimelapses(
          plantType: _selectedPlantType,
          duration: _selectedDuration,
          isLoadMore: true,
        );
      }
    });
  }

  Future<void> _handleRefresh() async {
    Provider.of<TimelapseProvider>(context, listen: false)._currentPage = 0;
    Provider.of<TimelapseProvider>(context, listen: false)._hasMore = true;
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
        title: const Semantics(
          label: 'Timelapse Gallery screen title',
          child: Text('Timelapse Gallery'),
        ),
        actions: [
          Semantics(
            label: 'Filter by plant type',
            child: DropdownButton<String>(
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
                  child: const Text(value),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 10),
          Semantics(
            label: 'Filter by duration',
            child: DropdownButton<String>(
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
                  child: const Text(value),
                );
              }).toList(),
            ),
          ),
          const SizedBox(width: 10),
          if (_selectedTimelapses.length == 2)
            Semantics(
              button: true,
              label: 'Compare selected timelapses',
              child: IconButton(
                icon: const Icon(Icons.compare),
                onPressed: _compareSelectedTimelapses,
                tooltip: 'Compare Selected',
              ),
            ),
          const SizedBox(width: 10),
        ],
      ),
      body: Consumer<TimelapseProvider>(
        builder: (context, timelapseProvider, child) {
          if (timelapseProvider.isLoading) {
            return const Semantics(
              label: 'Loading timelapses',
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (timelapseProvider.errorMessage != null) {
            return Semantics(
              label: 'Error loading timelapses',
              child: ErrorStateWidget(
                message: timelapseProvider.errorMessage!,
                onRetry: () => timelapseProvider.fetchTimelapses(
                  plantType: _selectedPlantType,
                  duration: _selectedDuration,
                ),
              ),
            );
          } else if (timelapseProvider.timelapses.isEmpty) {
            return const Semantics(
              label: 'No timelapses available',
              child: Center(child: Text('No timelapses available.')),
            );
          } else {
            return Semantics(
              label: 'Pull down to refresh timelapses',
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: ResponsiveGridLayout(
                  controller: _scrollController,
                  children: [
                    ...timelapseProvider.timelapses.map((timelapse) => Semantics(
                    label: 'Timelapse titled ${timelapse.title}',
                    child: GestureDetector(
                      onLongPress: () {
                        _showTimelapseContextMenu(context, timelapse);
                      },
                      child: Card(
                        color: _selectedTimelapses.contains(timelapse) ? Colors.blue.withOpacity(0.5) : null,
                        child: InkWell(
                          onTap: () => _toggleTimelapseSelection(timelapse),
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: timelapse.thumbnailUrl.isNotEmpty
                                    ? InteractiveViewer(
                                        child: CachedNetworkImage(
                                          imageUrl: timelapse.thumbnailUrl,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                                          errorWidget: (context, url, error) => const Icon(Icons.error),
                                        ),
                                      )
                                    : const Center(child: Text('No Thumbnail')), // Added const
                              ),
                              Center(
                                child: Text(timelapse.title, style: const TextStyle(color: Colors.white, backgroundColor: Colors.black54)),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Row(
                                  children: [
                                    Semantics(
                                      button: true,
                                      label: 'Add ${timelapse.title} to playlist',
                                      child: IconButton(
                                        icon: const Icon(Icons.playlist_add),
                                        onPressed: () => _showAddToPlaylistDialog(timelapse),
                                        tooltip: 'Add to Playlist',
                                      ),
                                    ),
                                    Semantics(
                                      button: true,
                                      label: 'Download ${timelapse.title}',
                                      child: IconButton(
                                        icon: const Icon(Icons.download),
                                        onPressed: () => timelapseProvider.downloadTimelapse(timelapse.videoUrl),
                                        tooltip: 'Download Timelapse',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
          child: Semantics(
            label: 'Timelapse context menu for ${timelapse.title}',
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
                    Provider.of<TimelapseProvider>(context, listen: false).downloadTimelapse(timelapse.videoUrl);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showAddToPlaylistDialog(Timelapse timelapse) async {
    final timelapseProvider = Provider.of<TimelapseProvider>(context, listen: false);
    await timelapseProvider.fetchPlaylists(); // Ensure playlists are fetched

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Semantics(
            label: 'Add to Playlist dialog',
            child: Text('Add to Playlist'),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (timelapseProvider.playlists.isEmpty)
                  const Semantics(
                    label: 'No playlists available. Create a new one.',
                    child: Text('No playlists available. Create a new one.'),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: timelapseProvider.playlists.length,
                    itemBuilder: (context, index) {
                      final playlist = timelapseProvider.playlists[index];
                      return Semantics(
                        button: true,
                        label: 'Playlist ${playlist.name} with ${playlist.timelapseIds.length} timelapses',
                        child: ListTile(
                          title: Text(playlist.name),
                          subtitle: Text(playlist.description.isEmpty ? 'No description' : playlist.description),
                          trailing: Text('${playlist.timelapseIds.length} timelapses'),
                          onTap: () async {
                            await timelapseProvider.addTimelapseToPlaylist(playlist.id, timelapse.id);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Added ${timelapse.title} to ${playlist.name}')),
                            );
                          },
                        ),
                      );
                    },
                  ),
                Semantics(
                  button: true,
                  label: 'Create New Playlist button',
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _createPlaylistDialog(); // Call the create playlist dialog
                    },
                    child: const Text('Create New Playlist'),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Semantics(
              button: true,
              label: 'Cancel button',
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
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
          title: const Semantics(
            label: 'Create New Playlist dialog',
            child: Text('Create New Playlist'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                label: 'Playlist Name text field',
                textField: true,
                child: TextField(
                  onChanged: (value) {
                    playlistName = value;
                  },
                  decoration: const InputDecoration(hintText: 'Playlist Name'),
                ),
              ),
              Semantics(
                label: 'Playlist Description text field',
                textField: true,
                child: TextField(
                  onChanged: (value) {
                    playlistDescription = value;
                  },
                  decoration: const InputDecoration(hintText: 'Description (Optional)'),
                ),
              ),
            ],
          ),
          actions: [
            Semantics(
              button: true,
              label: 'Cancel button',
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ),
            Semantics(
              button: true,
              label: 'Create Playlist button',
              child: ElevatedButton(
                onPressed: () async {
                  if (playlistName.isNotEmpty) {
                    await Provider.of<TimelapseProvider>(context, listen: false).createPlaylist(playlistName, playlistDescription);
                    Navigator.pop(context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Playlist name cannot be empty.')),
                    );
                  }
                },
                child: const Text('Create'),
              ),
            ),
          ],
        );
      },
    );
  }
}
