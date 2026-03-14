import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../services/pwa_service.dart';

class PWAInstallButton extends StatelessWidget {
  final PWAService pwaService;
  final VoidCallback? onInstallStarted;

  const PWAInstallButton({
    super.key,
    required this.pwaService,
    this.onInstallStarted,
  });

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || pwaService.isInstalled) {
      return const SizedBox.shrink();
    }

    return ElevatedButton.icon(
      onPressed: () async {
        try {
          await pwaService.showInstallPrompt();
          onInstallStarted?.call();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Installation failed: $e'),
              action: SnackBarAction(
                label: 'Retry',
                onPressed: () => pwaService.showInstallPrompt(),
              ),
            ),
          );
        }
      },
      icon: const Icon(Icons.download),
      label: const Text('Install App'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
