import 'dart:async';
import 'dart:math';

// Simplified UploadModel
class UploadModel {
  String id;
  String status;
  UploadModel(this.id, this.status);
}

void main() async {
  final _uploadQueue = List.generate(20, (i) => UploadModel('id_$i', 'pending'));

  // SEQUENTIAL
  print('Running SEQUENTIAL...');
  final sw1 = Stopwatch()..start();
  for (final upload in _uploadQueue) {
    if (upload.status == 'uploading' || upload.status == 'completed') continue;
    await _uploadFile(upload);
  }
  sw1.stop();
  print('Sequential time: ${sw1.elapsedMilliseconds}ms');

  // Reset
  for (final upload in _uploadQueue) upload.status = 'pending';

  // CONCURRENT (Pool)
  print('\nRunning CONCURRENT (max 3)...');
  final sw2 = Stopwatch()..start();

  final int maxConcurrentUploads = 3;
  final List<Future<void>> activeUploads = [];

  for (final upload in _uploadQueue) {
    if (upload.status == 'uploading' || upload.status == 'completed') {
      continue;
    }

    // Start the upload and add it to our tracking list
    final future = _uploadFile(upload);
    activeUploads.add(future);

    // When an upload completes, remove it from the tracking list
    future.whenComplete(() => activeUploads.remove(future));

    // If we've reached our concurrency limit, wait for at least one to finish
    if (activeUploads.length >= maxConcurrentUploads) {
      await Future.any(activeUploads);
    }
  }

  // Wait for any remaining uploads to finish
  if (activeUploads.isNotEmpty) {
    await Future.wait(activeUploads);
  }

  sw2.stop();
  print('Concurrent time: ${sw2.elapsedMilliseconds}ms');
}

Future<void> _uploadFile(UploadModel upload) async {
  upload.status = 'uploading';
  // Simulate network
  await Future.delayed(Duration(milliseconds: 100));
  upload.status = 'completed';
}
