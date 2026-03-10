import 'dart:async';

void main() async {
  Future<dynamic> mockFetch(String id, int ms) async {
    await Future.delayed(Duration(milliseconds: ms));
    return 'data_$id';
  }

  Future<List<dynamic>> fetchUploadedContentSequential(List<String> contentIds) async {
    List<dynamic> uploadedContent = [];
    for (String id in contentIds) {
      try {
        if (id.startsWith('reel-')) {
          final reel = await mockFetch(id, 10);
          uploadedContent.add(reel);
        } else if (id.startsWith('timelapse-')) {
          final timelapse = await mockFetch(id, 15);
          uploadedContent.add(timelapse);
        }
      } catch (e) {
      }
    }
    return uploadedContent;
  }

  Future<List<dynamic>> fetchUploadedContentConcurrent(List<String> contentIds) async {
    List<Future<dynamic>> futures = [];
    for (String id in contentIds) {
      if (id.startsWith('reel-')) {
        futures.add(mockFetch(id, 10));
      } else if (id.startsWith('timelapse-')) {
        futures.add(mockFetch(id, 15));
      }
    }

    try {
      final results = await Future.wait(futures);
      return results;
    } catch (e) {
      return [];
    }
  }

  List<String> ids = List.generate(50, (i) => i % 2 == 0 ? 'reel-$i' : 'timelapse-$i');

  final startSeq = DateTime.now();
  await fetchUploadedContentSequential(ids);
  final endSeq = DateTime.now();

  final startCon = DateTime.now();
  await fetchUploadedContentConcurrent(ids);
  final endCon = DateTime.now();

  print('Sequential: ${endSeq.difference(startSeq).inMilliseconds}ms');
  print('Concurrent: ${endCon.difference(startCon).inMilliseconds}ms');
}
