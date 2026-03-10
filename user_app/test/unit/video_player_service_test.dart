
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:user_app/services/video_player_service.dart';
import 'package:mockito/annotations.dart';

import 'video_player_service_test.mocks.dart';

@GenerateMocks([VideoPlayerController, ChewieController])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('VideoPlayerService', () {
    late VideoPlayerService videoPlayerService;
    late MockVideoPlayerController mockVideoPlayerController;
    late MockChewieController mockChewieController;

    setUp(() {
      mockVideoPlayerController = MockVideoPlayerController();
      mockChewieController = MockChewieController();

      videoPlayerService = VideoPlayerService(
        videoPlayerControllerFactory: (url) => mockVideoPlayerController,
        chewieControllerFactory: (controller) => mockChewieController,
      );
    });

    test('initializePlayer initializes controllers using factories', () async {
      // Arrange
      const testUrl = 'https://example.com/video.mp4';

      when(mockVideoPlayerController.initialize())
          .thenAnswer((_) async {});

      when(mockVideoPlayerController.value)
          .thenReturn(VideoPlayerValue(duration: const Duration(seconds: 10), isInitialized: true));

      // Act
      await videoPlayerService.initializePlayer(testUrl);

      // Assert
      expect(videoPlayerService.videoPlayerController, equals(mockVideoPlayerController));
      expect(videoPlayerService.chewieController, equals(mockChewieController));
      verify(mockVideoPlayerController.initialize()).called(1);
    });

    test('dispose calls dispose on both controllers', () async {
      // Arrange
      when(mockVideoPlayerController.initialize())
          .thenAnswer((_) async {});

      when(mockVideoPlayerController.value)
          .thenReturn(VideoPlayerValue(duration: const Duration(seconds: 10), isInitialized: true));

      // Mock dispose to do nothing
      when(mockVideoPlayerController.dispose()).thenAnswer((_) async {});

      // We first need to initialize them to set them in the service
      await videoPlayerService.initializePlayer('https://example.com/video.mp4');

      // Act
      videoPlayerService.dispose();

      // Assert
      verify(mockVideoPlayerController.dispose()).called(1);
      verify(mockChewieController.dispose()).called(1);
    });
  });
}
