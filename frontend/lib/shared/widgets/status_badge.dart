import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

enum BadgeType { info, warning, success, error, neutral }

/// Reusable status badge pill with restrained rounded corners.
class StatusBadge extends StatelessWidget {
  final String? text;
  final String? label;
  final BadgeType? type;
  final Color? backgroundColor;
  final Color? textColor;

  const StatusBadge({
    super.key,
    this.text,
    this.label,
    this.type,
    this.backgroundColor,
    this.textColor,
  }) : assert(
         text != null || label != null,
         'Either text or label must be provided',
       );

  String get _badgeText => text ?? label ?? '';

  Color _resolveBg() {
    if (backgroundColor != null) return backgroundColor!;
    switch (type) {
      case BadgeType.warning:
        return AppColors.warningLight;
      case BadgeType.success:
        return AppColors.successLight;
      case BadgeType.error:
        return AppColors.error.withValues(alpha: 0.1);
      case BadgeType.neutral:
        return AppColors.background;
      case BadgeType.info:
      default:
        return AppColors.lightBlue;
    }
  }

  Color _resolveText() {
    if (textColor != null) return textColor!;
    switch (type) {
      case BadgeType.warning:
        return AppColors.warning;
      case BadgeType.success:
        return AppColors.success;
      case BadgeType.error:
        return AppColors.error;
      case BadgeType.neutral:
        return AppColors.textSecondary;
      case BadgeType.info:
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: _resolveBg(),
        borderRadius: AppRadius.roundedSmall,
      ),
      child: Text(
        _badgeText,
        style: AppTextStyles.badge.copyWith(color: _resolveText()),
      ),
    );
  }
}
