import 'package:flutter/material.dart';
import 'package:user_app/data/models/timelapse.dart';
import 'package:user_app/ui/widgets/custom_video_player.dart';
import 'package:video_player/video_player.dart';

class TimelapseDetailScreen extends StatefulWidget {
  final Timelapse timelapse;

  const TimelapseDetailScreen({Key? key, required this.timelapse}) : super(key: key);

  @override
  State<TimelapseDetailScreen> createState() => _TimelapseDetailScreenState();
}

class _TimelapseDetailScreenState extends State<TimelapseDetailScreen> {
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.timelapse.videoUrl));
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
        title: Text(widget.timelapse.title),
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
                        'Auto': widget.timelapse.videoUrl,
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
                    widget.timelapse.title,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Plant Type: ${widget.timelapse.plantType}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Duration: ${widget.timelapse.duration.inMinutes} min ${widget.timelapse.duration.inSeconds % 60} sec',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Text(
                    'Uploaded on: ${widget.timelapse.uploadDate.toLocal().toString().split(' ')[0]}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.timelapse.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
