import 'package:flutter/material.dart';
import 'package:responsive_framework/responsive_framework.dart';

/// Configuration for responsive design framework
class ResponsiveConfig {
  /// Returns the responsive wrapper for the app
  static Widget getResponsiveWrapper({
    required Widget child,
    required BuildContext context,
  }) {
    return ResponsiveWrapper.builder(
      child,
      maxWidth: 1200,
      minWidth: 480,
      defaultScale: true,
      breakpoints: [
        const ResponsiveBreakpoint.resize(480, name: MOBILE),
        const ResponsiveBreakpoint.autoScale(800, name: TABLET),
        const ResponsiveBreakpoint.resize(1000, name: DESKTOP),
      ],
      background: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
    );
  }

  /// Returns true if the current screen is mobile
  static bool isMobile(BuildContext context) {
    return ResponsiveWrapper.of(context).isMobile;
  }

  /// Returns true if the current screen is tablet
  static bool isTablet(BuildContext context) {
    return ResponsiveWrapper.of(context).isTablet;
  }

  /// Returns true if the current screen is desktop
  static bool isDesktop(BuildContext context) {
    return ResponsiveWrapper.of(context).isDesktop;
  }

  /// Get responsive font size based on screen size
  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isMobile(context)) {
      return baseSize * 0.8;
    } else if (isTablet(context)) {
      return baseSize * 0.9;
    } else {
      return baseSize;
    }
  }

  /// Get responsive padding based on screen size
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isMobile(context)) {
      return const EdgeInsets.all(16.0);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(32.0);
    }
  }

  /// Get responsive spacing based on screen size
  static double getResponsiveSpacing(BuildContext context) {
    if (isMobile(context)) {
      return 16.0;
    } else if (isTablet(context)) {
      return 24.0;
    } else {
      return 32.0;
    }
  }
}