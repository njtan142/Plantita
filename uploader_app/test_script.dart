import 'dart:async';

// Simulated UploadModel
class UploadModel {
  String id;
  String status;
  UploadModel(this.id, this.status);
}

void main() async {
  final uploadQueue = List.generate(30, (i) => UploadModel('id_$i', 'pending'));

  print('--- BASELINE: SEQUENTIAL UPLOAD ---');
  final sw1 = Stopwatch()..start();
  for (final upload in uploadQueue) {
    if (upload.status == 'uploading' || upload.status == 'completed') {
      continue;
    }
    await _uploadFile(upload);
  }
  sw1.stop();
  final sequentialTime = sw1.elapsedMilliseconds;
  print('Sequential time: ${sequentialTime}ms');

  // Reset
  for (final upload in uploadQueue) upload.status = 'pending';

  print('\n--- OPTIMIZATION: CONCURRENT UPLOAD (Pool Size: 3) ---');
  final sw2 = Stopwatch()..start();

  final int maxConcurrentUploads = 3;
  final List<Future<void>> activeUploads = [];

  for (final upload in uploadQueue) {
    if (upload.status == 'uploading' || upload.status == 'completed') {
      continue;
    }

    final future = _uploadFile(upload);
    activeUploads.add(future);
    future.whenComplete(() => activeUploads.remove(future));

    if (activeUploads.length >= maxConcurrentUploads) {
      await Future.any(activeUploads);
    }
  }

  if (activeUploads.isNotEmpty) {
    await Future.wait(activeUploads);
  }

  sw2.stop();
  final concurrentTime = sw2.elapsedMilliseconds;
  print('Concurrent time: ${concurrentTime}ms');

  final improvement = sequentialTime - concurrentTime;
  final percent = ((improvement / sequentialTime) * 100).toStringAsFixed(1);
  print('\nImprovement: ${improvement}ms ($percent% faster)');
}

Future<void> _uploadFile(UploadModel upload) async {
  upload.status = 'uploading';
  // Simulate network/io delay
  await Future.delayed(const Duration(milliseconds: 100));
  upload.status = 'completed';
}
