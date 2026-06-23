import 'package:flutter/material.dart';

/// Breakpoints for responsive layout.
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1024;
}

/// Utility for detecting screen size category.
class ResponsiveLayout {
  final bool isMobile;
  final bool isTablet;
  final bool isDesktop;

  const ResponsiveLayout._({
    required this.isMobile,
    required this.isTablet,
    required this.isDesktop,
  });

  factory ResponsiveLayout.fromContext(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return ResponsiveLayout._(
      isMobile: width < Breakpoints.mobile,
      isTablet: width >= Breakpoints.mobile && width < Breakpoints.tablet,
      isDesktop: width >= Breakpoints.tablet,
    );
  }

  /// Whether the device supports touch input as primary input method.
  bool get isTouchPrimary => isMobile;

  /// Whether side panels (file tree, outline) should be shown inline.
  bool get showSidePanelsInline => isDesktop;

  /// Whether to use drawer navigation for side panels.
  bool get useDrawerForSidePanels => isMobile;

  /// Whether to show the toolbar at the bottom of the screen.
  bool get bottomToolbar => isMobile;

  /// Whether keyboard shortcuts are available.
  bool get hasKeyboardShortcuts => isDesktop;

  /// Icon size for toolbar buttons.
  double get toolbarIconSize => isMobile ? 22 : 20;

  /// Minimum touch target size.
  double get touchTargetSize => isMobile ? 48 : 40;
}
