import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/pwa_service.dart';
import '../services/analytics_service.dart';

/// PWA Install Prompt Widget
class PWAInstallPrompt extends StatefulWidget {
  final Widget child;
  final Duration promptDelay;
  final bool showOnMobileOnly;

  const PWAInstallPrompt({
    Key? key,
    required this.child,
    this.promptDelay = const Duration(seconds: 3),
    this.showOnMobileOnly = true,
  }) : super(key: key);

  @override
  State<PWAInstallPrompt> createState() => _PWAInstallPromptState();
}

class _PWAInstallPromptState extends State<PWAInstallPrompt>
    with WidgetsBindingObserver {
  final PWAService _pwaService = PWAService();
  final AnalyticsService _analyticsService = AnalyticsService();

  bool _showPrompt = false;
  bool _isVisible = false;
  Timer? _promptTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _initializePWA();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _promptTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkInstallPrompt();
    }
  }

  Future<void> _initializePWA() async {
    try {
      await _pwaService.initialize();

      // Listen to PWA service messages
      _pwaService.messageStream.listen((message) {
        _showSnackBar(message);
      });

      // Listen to online/offline status
      _pwaService.onlineStatusStream.listen((isOnline) {
        if (!isOnline) {
          _showSnackBar('You are offline. App will work with limited functionality.');
        }
      });

      // Check for install prompt after delay
      _promptTimer = Timer(widget.promptDelay, _checkInstallPrompt);

      // Log PWA initialization
      await _analyticsService.logPWAEvent(action: 'initialized');
    } catch (e) {
      debugPrint('PWA Install Prompt: Initialization failed: $e');
    }
  }

  void _checkInstallPrompt() {
    if (!mounted) return;

    // Don't show on desktop unless explicitly allowed
    if (widget.showOnMobileOnly && !_isMobileDevice()) return;

    // Don't show if already installed
    if (_pwaService.isInstalled) return;

    // Don't show if prompt already visible
    if (_isVisible) return;

    setState(() {
      _showPrompt = true;
      _isVisible = true;
    });

    // Log install prompt shown
    _analyticsService.logPWAEvent(action: 'install_prompt_shown');
  }

  bool _isMobileDevice() {
    // Check if running on mobile device
    return defaultTargetPlatform == TargetPlatform.iOS ||
           defaultTargetPlatform == TargetPlatform.android;
  }

  void _showSnackBar(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'OK',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  void _dismissPrompt() {
    setState(() {
      _showPrompt = false;
      _isVisible = false;
    });

    // Log install prompt dismissed
    _analyticsService.logPWAEvent(action: 'install_prompt_dismissed');
  }

  Future<void> _installPWA() async {
    try {
      await _pwaService.showInstallPrompt();
      _dismissPrompt();

      // Log PWA install started
      await _analyticsService.logPWAEvent(action: 'install_started');
    } catch (e) {
      debugPrint('PWA Install: Failed to show install prompt: $e');
      _showSnackBar('Installation prompt failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_showPrompt)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: _buildInstallPrompt(),
          ),
      ],
    );
  }

  Widget _buildInstallPrompt() {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.download_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Install Plantita Uploader',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Install as an app for a better experience',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _dismissPrompt,
                  icon: Icon(
                    Icons.close,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _installPWA,
                    icon: const Icon(Icons.download),
                    label: const Text('Install'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Theme.of(context).primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _dismissPrompt,
                    child: const Text('Later'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// PWA Status Widget
class PWAStatusWidget extends StatelessWidget {
  final PWAService pwaService;

  const PWAStatusWidget({
    Key? key,
    required this.pwaService,
  }) : super(key: key);

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
              if (!isOnline) ...[
                const SizedBox(width: 8),
                Text(
                  '(${pwaService.syncStream.length} pending)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// PWA Background Sync Indicator
class PWABackgroundSyncIndicator extends StatelessWidget {
  final PWAService pwaService;

  const PWABackgroundSyncIndicator({
    Key? key,
    required this.pwaService,
  }) : super(key: key);

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
            color: Colors.blue.withOpacity(0.1),
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

/// PWA Install Button
class PWAInstallButton extends StatelessWidget {
  final PWAService pwaService;
  final VoidCallback? onInstallStarted;

  const PWAInstallButton({
    Key? key,
    required this.pwaService,
    this.onInstallStarted,
  }) : super(key: key);

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