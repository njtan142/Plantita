import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:user_app/services/video_player_service.dart';

class MockVideoPlayerController extends Mock implements VideoPlayerController {}
class MockChewieController extends Mock implements ChewieController {}

class TestableVideoPlayerService extends VideoPlayerService {
  final VideoPlayerController mockVideoController;
  final ChewieController mockChewieController;

  TestableVideoPlayerService({
    required this.mockVideoController,
    required this.mockChewieController,
  });

  @override
  VideoPlayerController createVideoPlayerController(String videoUrl) {
    return mockVideoController;
  }

  @override
  ChewieController createChewieController(VideoPlayerController controller) {
    return mockChewieController;
  }

  // Expose error builder for testing
  Widget Function(BuildContext, String) getErrorBuilder() {
    return super.createChewieController(mockVideoController).errorBuilder!;
  }
}

void main() {
  setUpAll(() {
    registerFallbackValue(Duration.zero);
  });

  group('VideoPlayerService', () {
    late TestableVideoPlayerService videoPlayerService;
    late MockVideoPlayerController mockVideoPlayerController;
    late MockChewieController mockChewieController;

    setUp(() {
      mockVideoPlayerController = MockVideoPlayerController();
      mockChewieController = MockChewieController();
      videoPlayerService = TestableVideoPlayerService(
        mockVideoController: mockVideoPlayerController,
        mockChewieController: mockChewieController,
      );
    });

    test('initializePlayer initializes controllers and sets them correctly', () async {
      when(() => mockVideoPlayerController.initialize())
          .thenAnswer((_) async => Future.value());
      when(() => mockVideoPlayerController.value)
          .thenReturn(const VideoPlayerValue(duration: Duration(seconds: 10), isInitialized: true));

      await videoPlayerService.initializePlayer('http://example.com/video.mp4');

      verify(() => mockVideoPlayerController.initialize()).called(1);

      expect(videoPlayerService.videoPlayerController, equals(mockVideoPlayerController));
      expect(videoPlayerService.chewieController, equals(mockChewieController));
    });

    test('dispose calls dispose on underlying controllers', () async {
      when(() => mockVideoPlayerController.initialize())
          .thenAnswer((_) async => Future.value());
      when(() => mockVideoPlayerController.dispose())
          .thenAnswer((_) async => Future.value());
      when(() => mockChewieController.dispose())
          .thenAnswer((_) {});

      // First initialize to set the internal controllers
      await videoPlayerService.initializePlayer('http://example.com/video.mp4');

      videoPlayerService.dispose();

      verify(() => mockVideoPlayerController.dispose()).called(1);
      verify(() => mockChewieController.dispose()).called(1);
    });

    testWidgets('errorBuilder builds Center with white Text', (WidgetTester tester) async {
      when(() => mockVideoPlayerController.setLooping(any()))
          .thenAnswer((_) async => Future.value());
      when(() => mockVideoPlayerController.setPlaybackSpeed(any()))
          .thenAnswer((_) async => Future.value());
      when(() => mockVideoPlayerController.play())
          .thenAnswer((_) async => Future.value());
      when(() => mockVideoPlayerController.value)
          .thenReturn(const VideoPlayerValue(duration: Duration(seconds: 10), isInitialized: true));

      final errorBuilder = videoPlayerService.getErrorBuilder();
      final errorMessage = 'Failed to load video';

      final widget = MaterialApp(
        home: Scaffold(
          body: Builder(builder: (context) {
            return errorBuilder(context, errorMessage);
          }),
        ),
      );

      await tester.pumpWidget(widget);

      expect(find.byType(Center), findsOneWidget);
      final textFinder = find.text(errorMessage);
      expect(textFinder, findsOneWidget);

      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.color, Colors.white);
    });
  });
}
