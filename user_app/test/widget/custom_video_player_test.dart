
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:user_app/ui/widgets/custom_video_player.dart';
import 'package:mockito/mockito.dart';

// Mock VideoPlayerController and ChewieController
class MockVideoPlayerController extends Mock implements VideoPlayerController {}
class MockChewieController extends Mock implements ChewieController {}

void main() {
  group('CustomVideoPlayer', () {
    late MockVideoPlayerController mockVideoPlayerController;

    setUp(() {
      mockVideoPlayerController = MockVideoPlayerController();
      // Stub the value getter for isInitialized and aspectRatio
      when(mockVideoPlayerController.value).thenReturn(VideoPlayerValue(duration: Duration.zero, isInitialized: true, aspectRatio: 16 / 9));
      when(mockVideoPlayerController.initialize()).thenAnswer((_) async => Future.value());
      when(mockVideoPlayerController.dispose()).thenAnswer((_) async => Future.value());
    });

    testWidgets('displays CircularProgressIndicator when not initialized', (WidgetTester tester) async {
      when(mockVideoPlayerController.value).thenReturn(VideoPlayerValue(duration: Duration.zero, isInitialized: false));

      await tester.pumpWidget(MaterialApp(
        home: CustomVideoPlayer(
          videoPlayerController: mockVideoPlayerController,
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    // Note: Testing Chewie directly is complex due to its internal state and dependencies.
    // This test focuses on the CustomVideoPlayer's interaction with Chewie and its initial state.
    testWidgets('displays Chewie when initialized', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CustomVideoPlayer(
          videoPlayerController: mockVideoPlayerController,
        ),
      ));

      await tester.pumpAndSettle(); // Allow Chewie to initialize

      expect(find.byType(Chewie), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('dispose calls dispose on videoPlayerController and chewieController', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CustomVideoPlayer(
          videoPlayerController: mockVideoPlayerController,
        ),
      ));

      await tester.pumpAndSettle();

      final CustomVideoPlayerState state = tester.state(find.byType(CustomVideoPlayer));
      state.dispose();

      verify(mockVideoPlayerController.dispose()).called(1);
      // Verifying chewieController dispose is harder without direct access or mocking ChewieController constructor
    });
  });
}
