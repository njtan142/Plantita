
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerService {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @visibleForTesting
  VideoPlayerController createVideoPlayerController(String videoUrl) {
    return VideoPlayerController.networkUrl(Uri.parse(videoUrl));
  }

  @visibleForTesting
  ChewieController createChewieController(VideoPlayerController controller) {
    return ChewieController(
      videoPlayerController: controller,
      autoPlay: true,
      looping: false,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  Future<void> initializePlayer(String videoUrl) async {
    _videoPlayerController = createVideoPlayerController(videoUrl);
    await _videoPlayerController!.initialize();
    _chewieController = createChewieController(_videoPlayerController!);
  }

  VideoPlayerController? get videoPlayerController => _videoPlayerController;
  ChewieController? get chewieController => _chewieController;

  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
  }
}
