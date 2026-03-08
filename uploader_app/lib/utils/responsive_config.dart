import 'package:flutter/material.dart';

/// Configuration for responsive design
class ResponsiveConfig {
  final BuildContext context;

  const ResponsiveConfig(this.context);

  /// Returns the responsive wrapper for the app (simplified for now)
  static Widget getResponsiveWrapper({
    required Widget child,
    required BuildContext context,
  }) {
    return child; // Simplified wrapper - can be enhanced later
  }

  /// Returns true if the current screen is mobile
  static bool isMobileStatic(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  /// Returns true if the current screen is tablet
  static bool isTabletStatic(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  /// Returns true if the current screen is desktop
  static bool isDesktopStatic(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  /// Get responsive font size based on screen size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isMobileStatic(context)) {
      return baseSize * 0.8;
    } else if (isTabletStatic(context)) {
      return baseSize * 0.9;
    } else {
      return baseSize;
    }
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobileStatic(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTabletStatic(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  /// Get responsive spacing based on screen size
  static double getResponsiveSpacing(BuildContext context) {
    if (isMobileStatic(context)) {
      return 16.0;
    } else if (isTabletStatic(context)) {
      return 24.0;
    } else {
      return 32.0;
    }
  }

  // Instance methods for login screen usage
  bool get isMobile => isMobileStatic(context);
  bool get isTablet => isTabletStatic(context);
  bool get isDesktop => isDesktopStatic(context);

  double get horizontalPadding => isMobile ? 20.0 : 40.0;
  double get verticalPadding => isMobile ? 20.0 : 40.0;

  double get iconSize => isMobile ? 24.0 : 32.0;
  double get titleFontSize => isMobile ? 32.0 : 48.0;
  double get subtitleFontSize => isMobile ? 16.0 : 20.0;
  double get headerFontSize => isMobile ? 24.0 : 32.0;
  double get bodyFontSize => isMobile ? 14.0 : 16.0;

  EdgeInsets get responsivePadding => ResponsiveConfig.getResponsivePadding(context);
  double get responsiveSpacing => ResponsiveConfig.getResponsiveSpacing(context);
}