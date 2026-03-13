import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/state_management/reel_provider.dart';
import 'package:user_app/ui/widgets/custom_video_player.dart';
import 'package:user_app/ui/widgets/comment_dialog.dart';
import 'package:video_player/video_player.dart';
import 'package:user_app/ui/widgets/error_state_widget.dart';

class ReelsView extends StatefulWidget {
  const ReelsView({super.key});

  @override
  State<ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends State<ReelsView> {
  final PageController _pageController = PageController();
  final Map<String, VideoPlayerController> _videoControllers = {};
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    Provider.of<ReelProvider>(context, listen: false).fetchReels().then((_) {
      _initializeVideoControllers();
    });

    _pageController.addListener(() {
      if (_pageController.page == null) return;
      int nextPageIndex = _pageController.page!.round();
      if (_currentPage != nextPageIndex) {
        _currentPage = nextPageIndex;
        _disposeUnusedControllers();
        _initializeVideoControllers();
        final reelProvider = Provider.of<ReelProvider>(context, listen: false);
        if (_currentPage < reelProvider.reels.length) {
          reelProvider.trackReelView(reelProvider.reels[_currentPage].id);
        }
      }
    });
  }

  void _initializeVideoControllers() {
    final reelProvider = Provider.of<ReelProvider>(context, listen: false);
    final reels = reelProvider.reels;

    for (int i = -1; i <= 1; i++) {
      int indexToLoad = _currentPage + i;
      if (indexToLoad >= 0 && indexToLoad < reels.length) {
        final reel = reels[indexToLoad];
        if (!_videoControllers.containsKey(reel.id)) {
          final controller = VideoPlayerController.networkUrl(Uri.parse(reel.videoUrl));
          controller.initialize().then((_) {
            if (mounted) setState(() {});
          });
          _videoControllers[reel.id] = controller;
        }
      }
    }
  }

  void _disposeUnusedControllers() {
    final reelProvider = Provider.of<ReelProvider>(context, listen: false);
    final reels = reelProvider.reels;
    Set<String> activeReelIds = {};

    for (int i = -1; i <= 1; i++) {
      int index = _currentPage + i;
      if (index >= 0 && index < reels.length) {
        activeReelIds.add(reels[index].id);
      }
    }

    _videoControllers.removeWhere((reelId, controller) {
      if (!activeReelIds.contains(reelId)) {
        controller.dispose();
        return true;
      }
      return false;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
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
            return RefreshIndicator(
              onRefresh: () => reelProvider.fetchReels(),
              child: PageView.builder(
                controller: _pageController,
                scrollDirection: Axis.vertical,
                itemCount: reelProvider.reels.length,
                itemBuilder: (context, index) {
                  final reel = reelProvider.reels[index];
                  final videoController = _videoControllers[reel.id];

                  if (videoController == null || !videoController.value.isInitialized) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final Map<String, String> videoQualities = {
                    'Auto': reel.videoUrl,
                    '720p': reel.videoUrl.replaceFirst('.mp4', '_720p.mp4'),
                    '480p': reel.videoUrl.replaceFirst('.mp4', '_480p.mp4'),
                  };

                  return Stack(
                    children: [
                      CustomVideoPlayer(
                        videoPlayerController: videoController,
                        videoQualities: videoQualities,
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
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              reel.description,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.favorite, color: Colors.white),
                                  onPressed: () => reelProvider.likeReel(reel.id),
                                ),
                                Text(
                                  '${reel.likesCount}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(width: 20),
                                IconButton(
                                  icon: const Icon(Icons.comment, color: Colors.white),
                                  onPressed: () {
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => Container(
                                        height: MediaQuery.of(context).size.height * 0.7,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.vertical(top: Radius.circular(20)),
                                        ),
                                        child: CommentDialog(reelId: reel.id),
                                      ),
                                    );
                                  },
                                ),
                                Text(
                                  '${reel.commentsCount}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(width: 20),
                                IconButton(
                                  icon: const Icon(Icons.share, color: Colors.white),
                                  onPressed: () => reelProvider.shareReel(reel.id),
                                ),
                                Text(
                                  '${reel.sharesCount}',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
