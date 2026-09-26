import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';

/// Reusable MetricCard for key financial indicators.
/// Uses pure white surface, subtle border, and high-contrast typography.
class MetricCard extends StatelessWidget {
  final String? label;
  final String? title;
  final String value;
  final String? subtitle;
  final double? trend;
  final double? changePercent;
  final IconData? icon;

  const MetricCard({
    super.key,
    this.label,
    this.title,
    required this.value,
    this.subtitle,
    this.trend,
    this.changePercent,
    this.icon,
  }) : assert(
         label != null || title != null,
         'Either label or title must be provided',
       );

  String get _cardLabel => label ?? title ?? '';
  double? get _trendValue => trend ?? changePercent;

  @override
  Widget build(BuildContext context) {
    final trendVal = _trendValue;
    final isNegative = (trendVal ?? 0) < 0;
    final trendColor = isNegative ? AppColors.error : AppColors.success;

    return Card(
      color: AppColors.surface,
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.roundedMedium,
        side: BorderSide(color: AppColors.border, width: 1.0),
      ),
      child: Padding(
        padding: AppSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    _cardLabel,
                    style: AppTextStyles.secondary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (icon != null)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs + 2),
                    decoration: const BoxDecoration(
                      color: AppColors.lightBlue,
                      borderRadius: AppRadius.roundedSmall,
                    ),
                    child: Icon(icon, size: 18.0, color: AppColors.primary),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(value, style: AppTextStyles.display.copyWith(fontSize: 24.0)),
            const SizedBox(height: AppSpacing.xs),
            if (trendVal != null)
              Row(
                children: [
                  Icon(
                    isNegative ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 14.0,
                    color: trendColor,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    '${trendVal.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold,
                      color: trendColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Flexible(
                      child: Text(
                        subtitle!,
                        style: AppTextStyles.caption,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              )
            else if (subtitle != null)
              Text(subtitle!, style: AppTextStyles.caption),
          ],
        ),
      ),
    );
  }
}
