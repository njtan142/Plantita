
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user_app/state_management/reel_provider.dart';
import 'package:user_app/ui/widgets/custom_video_player.dart';
import 'package:video_player/video_player.dart';
import 'package:user_app/ui/widgets/error_state_widget.dart'; // Import ErrorStateWidget
import 'package:user_app/ui/widgets/comment_bottom_sheet.dart'; // Import CommentBottomSheet

class ReelsView extends StatefulWidget {
  const ReelsView({Key? key}) : super(key: key);

  @override
  State<ReelsView> createState() => _ReelsViewState();
}

class _ReelsViewState extends State<ReelsView> {
  PageController _pageController = PageController();
  final Map<String, VideoPlayerController> _videoControllers = {};
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Fetch reels when the view is initialized
    Provider.of<ReelProvider>(context, listen: false).fetchReels().then((_) {
      _initializeVideoControllers();
    });

    _pageController.addListener(() {
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

    // Initialize current, previous, and next video controllers
    for (int i = -1; i <= 1; i++) {
      int indexToLoad = _currentPage + i;
      if (indexToLoad >= 0 && indexToLoad < reels.length) {
        final reel = reels[indexToLoad];
        if (!_videoControllers.containsKey(reel.id)) {
          final controller = VideoPlayerController.networkUrl(Uri.parse(reel.videoUrl));
          controller.initialize().then((_) {
            setState(() {}); // Rebuild to show video once initialized
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

    // Determine which reels should be active (current, prev, next)
    for (int i = -1; i <= 1; i++) {
      int index = _currentPage + i;
      if (index >= 0 && index < reels.length) {
        activeReelIds.add(reels[index].id);
      }
    }

    // Dispose controllers that are no longer active
    _videoControllers.keys.toList().forEach((reelId) {
      if (!activeReelIds.contains(reelId)) {
        _videoControllers[reelId]?.dispose();
        _videoControllers.remove(reelId);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _videoControllers.forEach((key, value) => value.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Semantics(
          label: 'Reels screen title',
          child: Text('Reels'),
        ),
      ),
      body: Consumer<ReelProvider>(
        builder: (context, reelProvider, child) {
          if (reelProvider.isLoading) {
            return const Semantics(
              label: 'Loading reels',
              child: Center(child: CircularProgressIndicator()),
            );
          } else if (reelProvider.errorMessage != null) {
            return Semantics(
              label: 'Error loading reels',
              child: ErrorStateWidget(
                message: reelProvider.errorMessage!,
                onRetry: () => reelProvider.fetchReels(),
              ),
            );
          } else if (reelProvider.reels.isEmpty) {
            return const Semantics(
              label: 'No reels available',
              child: Center(child: Text('No reels available.')),
            );
          } else {
            return Semantics(
              label: 'Pull down to refresh reels',
              child: RefreshIndicator(
                onRefresh: () => reelProvider.fetchReels(),
                child: FocusTraversalGroup(
                  child: Semantics(
                    label: 'Swipe up or down to view next or previous reel',
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
                    '720p': reel.videoUrl.replaceFirst('.mp4', '_720p.mp4'), // Dummy URL
                    '480p': reel.videoUrl.replaceFirst('.mp4', '_480p.mp4'), // Dummy URL
                  };
                  return Stack(
                    children: [
                      Semantics(
                        label: 'Video player for reel titled ${reel.title}',
                        child: CustomVideoPlayer(
                          videoPlayerController: videoController,
                          videoQualities: videoQualities,
                          autoplay: true,
                          looping: true,
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Semantics(
                              label: 'Reel title: ${reel.title}',
                              child: Text(
                                reel.title,
                                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Semantics(
                              label: 'Reel description: ${reel.description}',
                              child: Text(
                                reel.description,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Semantics(
                                  button: true,
                                  label: 'Like button. Currently ${reel.likesCount} likes.',
                                  child: IconButton(
                                    icon: const Icon(Icons.favorite, color: Colors.white),
                                    onPressed: () => reelProvider.likeReel(reel.id),
                                  ),
                                ),
                                Semantics(
                                  label: '${reel.likesCount} likes',
                                  child: Text(
                                    '${reel.likesCount}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Semantics(
                                  button: true,
                                  label: 'Comment button. Currently ${reel.commentsCount} comments.',
                                  child: IconButton(
                                    icon: const Icon(Icons.comment, color: Colors.white),
                                    onPressed: () {
                                      showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (context) => CommentBottomSheet(reelId: reel.id),
                                      );
                                    },
                                  ),
                                ),
                                Semantics(
                                  label: '${reel.commentsCount} comments',
                                  child: Text(
                                    '${reel.commentsCount}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Semantics(
                                  button: true,
                                  label: 'Share button. Currently ${reel.sharesCount} shares.',
                                  child: IconButton(
                                    icon: const Icon(Icons.share, color: Colors.white),
                                    onPressed: () => reelProvider.shareReel(reel.id),
                                  ),
                                ),
                                Semantics(
                                  label: '${reel.sharesCount} shares',
                                  child: Text(
                                    '${reel.sharesCount}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
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
