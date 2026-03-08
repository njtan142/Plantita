import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/state_management/timelapse_provider.dart';
import 'package:user_app/ui/widgets/error_state_widget.dart';
import 'package:user_app/ui/widgets/responsive_grid_layout.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final String playlistId;

  const PlaylistDetailScreen({Key? key, required this.playlistId}) : super(key: key);

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TimelapseProvider>(context, listen: false).fetchPlaylistDetails(widget.playlistId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<TimelapseProvider>(
          builder: (context, timelapseProvider, child) {
            final playlist = timelapseProvider.playlists.firstWhere(
              (p) => p.id == widget.playlistId,
              orElse: () => throw Exception('Playlist not found'),
            );
            return Text(playlist.name);
          },
        ),
      ),
      body: Consumer<TimelapseProvider>(
        builder: (context, timelapseProvider, child) {
          if (timelapseProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (timelapseProvider.errorMessage != null) {
            return ErrorStateWidget(
              message: timelapseProvider.errorMessage!,
              onRetry: () => timelapseProvider.fetchPlaylistDetails(widget.playlistId),
            );
          } else {
            final playlist = timelapseProvider.playlists.firstWhere(
              (p) => p.id == widget.playlistId,
              orElse: () => throw Exception('Playlist not found'),
            );
            // For now, we'll just display the titles of the timelapses in the playlist.
            // In a real app, you'd fetch the full Timelapse objects based on their IDs.
            if (playlist.timelapseIds.isEmpty) {
              return const Center(child: Text('This playlist is empty.'));
            } else {
              return ResponsiveGridLayout(
                children: playlist.timelapseIds.map((timelapseId) => Card(
                  child: Center(
                    child: Text('Timelapse ID: $timelapseId'), // Replace with actual timelapse title
                  ),
                )).toList(),
              );
            }
          }
        },
      ),
    );
  }
}
