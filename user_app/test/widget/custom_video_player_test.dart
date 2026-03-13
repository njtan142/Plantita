import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:user_app/ui/widgets/custom_video_player.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'custom_video_player_test.mocks.dart';

@GenerateMocks([VideoPlayerController])
void main() {
  group('CustomVideoPlayer', () {
    late MockVideoPlayerController mockVideoPlayerController;
    final Map<String, String> mockQualities = {'Auto': 'http://example.com/video.mp4'};

    setUp(() {
      mockVideoPlayerController = MockVideoPlayerController();
      
      when(mockVideoPlayerController.value).thenReturn(const VideoPlayerValue(
        duration: Duration(seconds: 10),
        isInitialized: true,
        size: Size(1920, 1080),
      ));
      when(mockVideoPlayerController.initialize()).thenAnswer((_) async => {});
      when(mockVideoPlayerController.dispose()).thenAnswer((_) async => {});
      when(mockVideoPlayerController.addListener(any)).thenReturn(null);
      when(mockVideoPlayerController.removeListener(any)).thenReturn(null);
    });

    testWidgets('displays CircularProgressIndicator when not initialized', (WidgetTester tester) async {
      when(mockVideoPlayerController.value).thenReturn(const VideoPlayerValue(
        duration: Duration.zero,
        isInitialized: false,
      ));

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomVideoPlayer(
            videoPlayerController: mockVideoPlayerController,
            videoQualities: mockQualities,
          ),
        ),
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays Chewie when initialized', (WidgetTester tester) async {
       await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CustomVideoPlayer(
            videoPlayerController: mockVideoPlayerController,
            videoQualities: mockQualities,
          ),
        ),
      ));

      await tester.pump(); 

      expect(find.byType(Chewie), findsOneWidget);
    });
  });
}
