import 'package:flutter/material.dart';
import '../../../services/pwa_service.dart';

class PWAStatusWidget extends StatelessWidget {
  final PWAService pwaService;

  const PWAStatusWidget({
    super.key,
    required this.pwaService,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: pwaService.onlineStatusStream,
      initialData: pwaService.isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? true;

        if (isOnline && pwaService.isInstalled) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: isOnline ? Colors.green : Colors.orange,
          child: Row(
            children: [
              Icon(
                isOnline ? Icons.wifi : Icons.wifi_off,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                isOnline
                    ? 'Online - PWA Ready'
                    : 'Offline - Limited functionality',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
