import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../data/models/timelapse.dart';

class TimelapseCard extends StatelessWidget {
  final Timelapse timelapse;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onAddToPlaylist;
  final VoidCallback onDownload;

  const TimelapseCard({
    super.key,
    required this.timelapse,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onAddToPlaylist,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Card(
        color: isSelected ? Colors.blue.withOpacity(0.5) : null,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Positioned.fill(
                child: timelapse.thumbnailUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: timelapse.thumbnailUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            const Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      )
                    : const Center(child: Text('No Thumbnail')),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    timelapse.title,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.playlist_add, color: Colors.white),
                      onPressed: onAddToPlaylist,
                      tooltip: 'Add to Playlist',
                    ),
                    IconButton(
                      icon: const Icon(Icons.download, color: Colors.white),
                      onPressed: onDownload,
                      tooltip: 'Download Timelapse',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
