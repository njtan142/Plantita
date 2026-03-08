
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:user_app/data/models/reel.dart';
import 'package:user_app/data/repositories/reel_repository.dart';
import 'package:user_app/state_management/reel_provider.dart';

// Create a MockReelRepository using Mockito
class MockReelRepository extends Mock implements ReelRepository {}

void main() {
  group('ReelProvider', () {
    late ReelProvider reelProvider;
    late MockReelRepository mockReelRepository;

    setUp(() {
      mockReelRepository = MockReelRepository();
      reelProvider = ReelProvider(mockReelRepository);
    });

    test('reels is empty and isLoading is false initially', () {
      expect(reelProvider.reels, isEmpty);
      expect(reelProvider.isLoading, false);
      expect(reelProvider.errorMessage, isNull);
    });

    test('fetchReels sets isLoading to true and then false', () async {
      when(mockReelRepository.fetchReels()).thenAnswer((_) async => []);

      final future = reelProvider.fetchReels();
      expect(reelProvider.isLoading, true);
      await future;
      expect(reelProvider.isLoading, false);
    });

    test('fetchReels populates reels on success', () async {
      final mockReels = [
        Reel(
          id: '1',
          videoUrl: 'url1',
          thumbnailUrl: 'thumb1',
          title: 'title1',
          description: 'desc1',
          uploadDate: DateTime.now(),
          likesCount: 1,
          commentsCount: 1,
          sharesCount: 1,
          userId: 'user1',
        ),
      ];
      when(mockReelRepository.fetchReels()).thenAnswer((_) async => mockReels);

      await reelProvider.fetchReels();
      expect(reelProvider.reels, mockReels);
      expect(reelProvider.errorMessage, isNull);
    });

    test('fetchReels sets errorMessage on failure', () async {
      when(mockReelRepository.fetchReels()).thenThrow(Exception('Failed to fetch'));

      await reelProvider.fetchReels();
      expect(reelProvider.reels, isEmpty);
      expect(reelProvider.errorMessage, contains('Failed to fetch'));
    });
  });
}
