import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/state_management/timelapse_provider.dart';
import 'package:user_app/ui/widgets/error_state_widget.dart';
import 'package:go_router/go_router.dart';

class PlaylistScreen extends StatefulWidget {
  const PlaylistScreen({Key? key}) : super(key: key);

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TimelapseProvider>(context, listen: false).fetchPlaylists();
    });
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
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Playlists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createPlaylistDialog,
            tooltip: 'Create New Playlist',
          ),
        ],
      ),
      body: Consumer<TimelapseProvider>(
        builder: (context, timelapseProvider, child) {
          if (timelapseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (timelapseProvider.errorMessage != null) {
            return ErrorStateWidget(
              message: timelapseProvider.errorMessage!,
              onRetry: () => timelapseProvider.fetchPlaylists(),
            );
          } else if (timelapseProvider.playlists.isEmpty) {
            return const Center(child: Text('No playlists created yet.'));
          } else {
            return ListView.builder(
              itemCount: timelapseProvider.playlists.length,
              itemBuilder: (context, index) {
                final playlist = timelapseProvider.playlists[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(playlist.name),
                    subtitle: Text(playlist.description.isEmpty ? 'No description' : playlist.description),
                    trailing: Text('${playlist.timelapseIds.length} timelapses'),
                    onTap: () {
                      // Navigate to playlist detail screen
                      context.go('/playlists/${playlist.id}');
                    },
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
