import 'package:flutter/material.dart';

/// Centralized modern Indian fintech color palette for VyapaarPilot.
/// Strictly follows specifications without scattering hex values in widgets.
class AppColors {
  AppColors._();

  // Core Brand & Surface Colors
  static const Color primary = Color(0xFF123B66); // Deep Navy
  static const Color lightBlue = Color(0xFFE8F3FF); // Soft Ice Blue
  static const Color secondaryBlue = Color(0xFF2F80ED); // Primary / Accent Blue
  static const Color background = Color(0xFFF7F9FC); // Slate Tint
  static const Color surface = Color(0xFFFFFFFF); // Pure White

  // Text Colors
  static const Color textPrimary = Color(0xFF17212B); // Dark Slate
  static const Color textSecondary = Color(0xFF667085); // Muted Grey

  // Semantic Status Colors
  static const Color success = Color(0xFF16A34A); // Growth Green
  static const Color warning = Color(0xFFF59E0B); // Opportunity Amber
  static const Color error = Color(0xFFDC2626); // Alert Red

  // Subtle Borders & Surfaces
  static const Color border = Color(0xFFE2E8F0); // Subtle Card Border
  static const Color divider = Color(0xFFEDF2F7); // Subtle Divider Line
  static const Color warningLight = Color(0xFFFEF3C7); // Soft Amber Container
  static const Color successLight = Color(0xFFDCFCE7); // Soft Green Container
}
