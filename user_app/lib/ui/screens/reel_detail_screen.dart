import 'package:flutter/material.dart';
import 'package:user_app/data/models/reel.dart';
import 'package:user_app/ui/widgets/custom_video_player.dart';
import 'package:video_player/video_player.dart';

class ReelDetailScreen extends StatefulWidget {
  final Reel reel;

  const ReelDetailScreen({Key? key, required this.reel}) : super(key: key);

  @override
  State<ReelDetailScreen> createState() => _ReelDetailScreenState();
}

class _ReelDetailScreenState extends State<ReelDetailScreen> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.reel.videoUrl));
    _videoPlayerController.initialize().then((_) {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reel.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: _videoPlayerController.value.isInitialized
                  ? CustomVideoPlayer(
                      videoPlayerController: _videoPlayerController,
                      videoQualities: {
                        'Auto': widget.reel.videoUrl,
                      },
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.reel.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Uploaded on: ${widget.reel.uploadDate.toLocal().toString().split(' ')[0]}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.reel.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(Icons.favorite, '${widget.reel.likesCount} Likes'),
                      _buildStatItem(Icons.comment, '${widget.reel.commentsCount} Comments'),
                      _buildStatItem(Icons.share, '${widget.reel.sharesCount} Shares'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}
