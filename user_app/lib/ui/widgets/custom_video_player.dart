
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'dart:collection'; // For LinkedHashMap

class CustomVideoPlayer extends StatefulWidget {
  final VideoPlayerController videoPlayerController; // External controller
  final Map<String, String> videoQualities; // Map of quality label to video URL
  final bool looping;
  final bool autoplay;

  const CustomVideoPlayer({
    Key? key,
    required this.videoPlayerController,
    required this.videoQualities,
    this.looping = false,
    this.autoplay = false,
  }) : super(key: key);

  @override
  State<CustomVideoPlayer> createState() => _CustomVideoPlayerState();
}

class _CustomVideoPlayerState extends State<CustomVideoPlayer> {
  ChewieController? _chewieController;
  late int _currentQualityIndex; // Index of the currently selected quality

  @override
  void initState() {
    super.initState();
    _currentQualityIndex = 0; // Start with the first quality
    _initializePlayer();
  }

  @override
  void didUpdateWidget(covariant CustomVideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoPlayerController != oldWidget.videoPlayerController) {
      _chewieController?.dispose();
      _initializePlayer();
    }
  }

  Future<void> _initializePlayer() async {
    _chewieController = ChewieController(
      videoPlayerController: widget.videoPlayerController,
      aspectRatio: widget.videoPlayerController.value.aspectRatio,
      autoPlay: widget.autoplay,
      looping: widget.looping,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            errorMessage,
            style: const TextStyle(color: Colors.white),
          ),
        );
      },
    );
    setState(() {});
  }

  void _changeVideoQuality(int newQualityIndex) async {
    if (newQualityIndex == _currentQualityIndex) return;

    final oldChewieController = _chewieController;

    setState(() {
      _currentQualityIndex = newQualityIndex;
      _chewieController = null; // Clear controller to show loading
    });

    oldChewieController?.dispose();

    // Dispose and re-initialize the external videoPlayerController
    await widget.videoPlayerController.dispose();
    // Re-initialize with new quality URL
    await widget.videoPlayerController.initialize();
    _initializePlayer();
  }

  @override
  Widget build(BuildContext context) {
    return _chewieController != null &&
            _chewieController!.videoPlayerController.value.isInitialized
        ? Stack(
            children: [
              Chewie(controller: _chewieController!),
              Positioned(
                top: 0,
                right: 0,
                child: Semantics(
                  label: 'Video quality settings',
                  button: true,
                  child: PopupMenuButton<int>(
                    onSelected: _changeVideoQuality,
                    itemBuilder: (BuildContext context) {
                      return List.generate(widget.videoQualities.length, (index) {
                        return PopupMenuItem<int>(
                          value: index,
                          child: Text(widget.videoQualities.keys.elementAt(index)),
                        );
                      });
                    },
                    icon: const Icon(Icons.settings, color: Colors.white),
                  ),
                ),
              ),
            ],
          )
        : const Center(
            child: CircularProgressIndicator(),
          );
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    super.dispose();
  }
}
