import 'package:flutter/material.dart';
import 'package:user_app/data/models/timelapse.dart';
import 'package:user_app/ui/widgets/custom_video_player.dart';

class TimelapseComparisonScreen extends StatelessWidget {
  final Timelapse timelapse1;
  final Timelapse timelapse2;

  const TimelapseComparisonScreen({
    Key? key,
    required this.timelapse1,
    required this.timelapse2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Timelapse Comparison'),
      ),
      body: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Text(timelapse1.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: CustomVideoPlayer(
                    videoQualities: {'Auto': timelapse1.videoUrl},
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
                Text(timelapse2.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Expanded(
                  child: CustomVideoPlayer(
                    videoQualities: {'Auto': timelapse2.videoUrl},
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
