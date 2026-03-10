import 'dart:async';

class BackgroundSyncTask {
  final String id;
  final String type;
  final Map<String, dynamic> data;

  BackgroundSyncTask({required this.id, required this.type, required this.data});
}

Future<void> executeSyncTask(BackgroundSyncTask task) async {
  // Simulate network/db latency
  await Future.delayed(Duration(milliseconds: 50));
}

Future<void> processQueueSequential(List<BackgroundSyncTask> queue) async {
  for (final task in List.from(queue)) {
    try {
      await executeSyncTask(task);
      queue.remove(task);
    } catch (e) {
      //
    }
  }
}

Future<void> processQueueConcurrentGroupedByType(List<BackgroundSyncTask> queue) async {
  final tasksByType = <String, List<BackgroundSyncTask>>{};
  for (final task in List.from(queue)) {
    tasksByType.putIfAbsent(task.type, () => []).add(task);
  }

  await Future.wait(tasksByType.values.map((tasks) async {
    for (final task in tasks) {
      try {
        await executeSyncTask(task);
        queue.remove(task);
      } catch (e) {
        break;
      }
    }
  }));
}

void main() async {
  final stopwatch = Stopwatch();

  // Create test data: 30 upload tasks, 30 update tasks, 30 delete tasks
  final queue1 = [
    ...List.generate(30, (i) => BackgroundSyncTask(id: 'u$i', type: 'upload', data: {})),
    ...List.generate(30, (i) => BackgroundSyncTask(id: 'up$i', type: 'update', data: {})),
    ...List.generate(30, (i) => BackgroundSyncTask(id: 'd$i', type: 'delete', data: {})),
  ];

  stopwatch.start();
  await processQueueSequential(queue1);
  stopwatch.stop();
  final sequentialTime = stopwatch.elapsedMilliseconds;

  // Create identical test data
  final queue2 = [
    ...List.generate(30, (i) => BackgroundSyncTask(id: 'u$i', type: 'upload', data: {})),
    ...List.generate(30, (i) => BackgroundSyncTask(id: 'up$i', type: 'update', data: {})),
    ...List.generate(30, (i) => BackgroundSyncTask(id: 'd$i', type: 'delete', data: {})),
  ];

  stopwatch.reset();
  stopwatch.start();
  await processQueueConcurrentGroupedByType(queue2);
  stopwatch.stop();
  final concurrentTime = stopwatch.elapsedMilliseconds;

  print('Sequential time: ${sequentialTime}ms');
  print('Concurrent (Grouped By Type) time: ${concurrentTime}ms');
  print('Improvement: ${sequentialTime - concurrentTime}ms (${((sequentialTime - concurrentTime) / sequentialTime * 100).toStringAsFixed(2)}%)');
}
