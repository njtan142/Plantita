import 'package:flutter/material.dart';
import '../../../services/pwa_service.dart';
import '../../../models/pwa_models.dart';

class PWABackgroundSyncIndicator extends StatelessWidget {
  final PWAService pwaService;

  const PWABackgroundSyncIndicator({
    super.key,
    required this.pwaService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<BackgroundSyncTask>(
      stream: pwaService.syncStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final task = snapshot.data!;
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withAlpha((255 * 0.1).round()),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Syncing: ${task.type}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
