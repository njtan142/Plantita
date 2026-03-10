
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:user_app/data/repositories/comment_repository.dart';
import 'package:user_app/services/api_service.dart';
import 'package:user_app/data/models/comment.dart';

// Create a MockApiService using Mockito
class MockApiService extends Mock implements ApiService {}

void main() {
  group('CommentRepository', () {
    late CommentRepository commentRepository;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      commentRepository = CommentRepository(mockApiService);
    });

    test('fetchComments returns a list of comments on success', () async {
      final mockResponse = {
        'comments': [
          {
            'id': 'c1',
            'text': 'Great reel!',
            'userId': 'user3',
            'reelId': 'r1',
            'timestamp': '2023-01-01T13:00:00.000Z',
          },
          {
            'id': 'c2',
            'text': 'Nice work!',
            'userId': 'user4',
            'reelId': 'r1',
            'timestamp': '2023-01-01T14:00:00.000Z',
          },
        ]
      };

      when(mockApiService.get('reels/r1/comments')).thenAnswer((_) async => mockResponse);

      final comments = await commentRepository.fetchComments('r1');

      expect(comments, isA<List<Comment>>());
      expect(comments.length, 2);
      expect(comments[0].text, 'Great reel!');
      expect(comments[1].text, 'Nice work!');
    });

    test('fetchComments throws an exception on API error', () async {
      when(mockApiService.get('reels/r1/comments')).thenThrow(Exception('API error'));

      expect(() => commentRepository.fetchComments('r1'), throwsException);
    });

    test('addComment returns true on success', () async {
      when(mockApiService.post('reels/r1/comments', {'text': 'Awesome!'}))
          .thenAnswer((_) async => {'status': 'success'});

      final result = await commentRepository.addComment('r1', 'Awesome!');

      expect(result, true);
    });

    test('addComment returns false on API error', () async {
      when(mockApiService.post('reels/r1/comments', {'text': 'Awesome!'}))
          .thenThrow(Exception('API error'));

      final result = await commentRepository.addComment('r1', 'Awesome!');

      expect(result, false);
    });
  });
}
