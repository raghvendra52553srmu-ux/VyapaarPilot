import 'package:flutter/material.dart';

import '../constants/app_constants.dart';

/// Centralized responsive layout utility and widget builder.
class Responsive extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const Responsive({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// Screen dimension accessors
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;

  /// Breakpoint checks
  static bool isMobile(BuildContext context) =>
      width(context) < AppBreakpoints.mobile;

  static bool isTablet(BuildContext context) =>
      width(context) >= AppBreakpoints.mobile &&
      width(context) <= AppBreakpoints.tablet;

  static bool isDesktop(BuildContext context) =>
      width(context) > AppBreakpoints.tablet;

  /// Returns responsive padding based on screen size
  static EdgeInsets screenPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(AppSpacing.xxxl);
    } else if (isTablet(context)) {
      return const EdgeInsets.all(AppSpacing.xxl);
    }
    return const EdgeInsets.all(AppSpacing.lg);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > AppBreakpoints.tablet && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= AppBreakpoints.mobile &&
            tablet != null) {
          return tablet!;
        } else {
          return mobile;
        }
      },
    );
  }
}

/// Also alias ResponsiveLayout for compatibility with existing imports
typedef ResponsiveLayout = Responsive;
