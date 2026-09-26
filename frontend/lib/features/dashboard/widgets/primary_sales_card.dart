import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';

/// Primary hero card displaying Today's Sales with strong financial hierarchy.
class PrimarySalesCard extends StatelessWidget {
  final double salesAmount;
  final double changePercent;
  final String comparisonText;

  const PrimarySalesCard({
    super.key,
    required this.salesAmount,
    required this.changePercent,
    this.comparisonText = 'vs usual',
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = changePercent < 0;
    // Muted semantic indication without alarming the merchant
    final changeColor = isNegative ? AppColors.warning : AppColors.success;
    final changeIcon = isNegative ? Icons.arrow_downward : Icons.arrow_upward;

    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.roundedMedium,
        side: BorderSide(color: AppColors.border, width: 1.0),
      ),
      child: Padding(
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Text(
                    "Today's Sales",
                    style: TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: changeColor.withValues(alpha: 0.12),
                    borderRadius: AppRadius.roundedSmall,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(changeIcon, size: 13.0, color: changeColor),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '${changePercent.abs().toStringAsFixed(0)}% $comparisonText',
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold,
                          color: changeColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              CurrencyFormatter.formatRupee(salesAmount),
              style: AppTextStyles.display.copyWith(
                fontSize: 34.0,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
