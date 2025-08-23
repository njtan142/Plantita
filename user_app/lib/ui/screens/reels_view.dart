
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/state_management/reel_provider.dart';
import 'package:user_app/ui/widgets/custom_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:user_app/ui/widgets/error_state_widget.dart'; // Import ErrorStateWidget

class ReelsView extends StatefulWidget {
  const ReelsView({Key? key}) : super(key: key);

  @override
  State<ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends State<ReelsView> {
  @override
  void initState() {
    super.initState();
    // Fetch reels when the view is initialized
    Provider.of<ReelProvider>(context, listen: false).fetchReels();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reels'),
      ),
      body: Consumer<ReelProvider>(
        builder: (context, reelProvider, child) {
          if (reelProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (reelProvider.errorMessage != null) {
            return ErrorStateWidget(
              message: reelProvider.errorMessage!,
              onRetry: () => reelProvider.fetchReels(),
            );
          } else if (reelProvider.reels.isEmpty) {
            return const Center(child: Text('No reels available.'));
          } else {
            return PageView.builder(
              scrollDirection: Axis.vertical,
              itemCount: reelProvider.reels.length,
              itemBuilder: (context, index) {
                final reel = reelProvider.reels[index];
                return Stack(
                  children: [
                    CustomVideoPlayer(
                      videoPlayerController: VideoPlayerController.networkUrl(Uri.parse(reel.videoUrl)),
                      autoplay: true,
                      looping: true,
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reel.title,
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            reel.description,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }
        },
      ),
    );
  }
}
}
