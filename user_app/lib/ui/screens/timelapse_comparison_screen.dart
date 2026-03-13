import 'package:flutter/material.dart';
import 'package:user_app/data/models/timelapse.dart';
import 'package:user_app/ui/widgets/custom_video_player.dart';
import 'package:video_player/video_player.dart';

class TimelapseComparisonScreen extends StatefulWidget {
  final Timelapse timelapse1;
  final Timelapse timelapse2;

  const TimelapseComparisonScreen({
    super.key,
    required this.timelapse1,
    required this.timelapse2,
  });

  @override
  State<TimelapseComparisonScreen> createState() => _TimelapseComparisonScreenState();
}

class _TimelapseComparisonScreenState extends State<TimelapseComparisonScreen> {
  late VideoPlayerController _controller1;
  late VideoPlayerController _controller2;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  Future<void> _initializeControllers() async {
    _controller1 = VideoPlayerController.networkUrl(Uri.parse(widget.timelapse1.videoUrl));
    _controller2 = VideoPlayerController.networkUrl(Uri.parse(widget.timelapse2.videoUrl));

    await Future.wait([
      _controller1.initialize(),
      _controller2.initialize(),
    ]);

    if (mounted) {
      setState(() {
        _initialized = true;
      });
    }
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timelapse Comparison'),
      ),
      body: !_initialized
          ? const Center(child: CircularProgressIndicator())
          : Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(widget.timelapse1.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: CustomVideoPlayer(
                          videoPlayerController: _controller1,
                          videoQualities: {'Auto': widget.timelapse1.videoUrl},
                          autoplay: true,
                          looping: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(widget.timelapse2.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: CustomVideoPlayer(
                          videoPlayerController: _controller2,
                          videoQualities: {'Auto': widget.timelapse2.videoUrl},
                          autoplay: true,
                          looping: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
