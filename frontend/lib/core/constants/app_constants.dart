import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Centralized spacing system based on 4px / 8px grid
class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double xxxl = 32.0;
  static const double huge = 40.0;

  // EdgeInsets presets
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  static const EdgeInsets paddingXxl = EdgeInsets.all(xxl);

  static const EdgeInsets screenPadding = EdgeInsets.all(lg);
  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
}

/// Centralized border radius system
class AppRadius {
  AppRadius._();

  static const double small = 8.0;
  static const double medium = 12.0;
  static const double large = 16.0;

  static const BorderRadius roundedSmall = BorderRadius.all(
    Radius.circular(small),
  );
  static const BorderRadius roundedMedium = BorderRadius.all(
    Radius.circular(medium),
  );
  static const BorderRadius roundedLarge = BorderRadius.all(
    Radius.circular(large),
  );
}

/// Centralized responsive layout breakpoints
class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600.0;
  static const double tablet = 1024.0;
  static const double maxContentWidth = 1200.0;
}

/// Centralized text style definitions for visual hierarchy
class AppTextStyles {
  AppTextStyles._();

  /// Display / Major Metric: 28–36px, bold, high contrast
  static const TextStyle display = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  /// Page Title: 22–24px, semi-bold
  static const TextStyle pageTitle = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Section Heading: 17–18px, semi-bold
  static const TextStyle sectionHeading = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
  );

  /// Body: 14–16px, regular
  static const TextStyle body = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  /// Secondary Text: 13–14px, regular/muted
  static const TextStyle secondary = TextStyle(
    fontSize: 13.0,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  /// Caption: 12–13px, medium/muted
  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Badge / Pill Label: 11–12px, semi-bold
  static const TextStyle badge = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
  );
}
