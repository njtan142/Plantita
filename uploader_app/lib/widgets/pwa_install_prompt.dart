import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../services/pwa_service.dart';
import '../services/analytics_service.dart';
import 'pwa/components/pwa_status_widget.dart';
import 'pwa/components/pwa_background_sync_indicator.dart';
import 'pwa/components/pwa_install_button.dart';

export 'pwa/components/pwa_status_widget.dart';
export 'pwa/components/pwa_background_sync_indicator.dart';
export 'pwa/components/pwa_install_button.dart';

/// PWA Install Prompt Widget
class PWAInstallPrompt extends StatefulWidget {
  final Widget child;
  final Duration promptDelay;
  final bool showOnMobileOnly;

  const PWAInstallPrompt({
    super.key,
    required this.child,
    this.promptDelay = const Duration(seconds: 3),
    this.showOnMobileOnly = true,
  });

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
              Theme.of(context).primaryColor.withAlpha((255 * 0.8).round()),
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
                      Text('Install as an app for a better experience',
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                          color: Colors.white.withAlpha((255 * 0.9).round()),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: _dismissPrompt,
                  icon: Icon(
                    Icons.close,
                    color: Colors.white.withAlpha((255 * 0.7).round()),
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
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Later'),
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
