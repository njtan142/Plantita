
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerService {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  final VideoPlayerController Function(String)? videoPlayerControllerFactory;
  final ChewieController Function(VideoPlayerController)? chewieControllerFactory;

  VideoPlayerService({
    this.videoPlayerControllerFactory,
    this.chewieControllerFactory,
  });

  Future<void> initializePlayer(String videoUrl) async {
    _videoPlayerController = videoPlayerControllerFactory != null
        ? videoPlayerControllerFactory!(videoUrl)
        : VideoPlayerController.networkUrl(Uri.parse(videoUrl));

    await _videoPlayerController!.initialize();

    _chewieController = chewieControllerFactory != null
        ? chewieControllerFactory!(_videoPlayerController!)
        : ChewieController(
            videoPlayerController: _videoPlayerController!,
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

  VideoPlayerController? get videoPlayerController => _videoPlayerController;
  ChewieController? get chewieController => _chewieController;

  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
  }
}
