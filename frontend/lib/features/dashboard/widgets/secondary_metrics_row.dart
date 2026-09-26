import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';

/// Compact row displaying secondary metrics: Transactions & Average Transaction value.
class SecondaryMetricsRow extends StatelessWidget {
  final int transactionCount;
  final double averageTransaction;

  const SecondaryMetricsRow({
    super.key,
    required this.transactionCount,
    required this.averageTransaction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _CompactMetricTile(
            value: '$transactionCount',
            label: 'Transactions',
            icon: Icons.receipt_long_outlined,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _CompactMetricTile(
            value: CurrencyFormatter.formatRupee(averageTransaction),
            label: 'Avg. transaction',
            icon: Icons.shopping_bag_outlined,
          ),
        ),
      ],
    );
  }
}

class _CompactMetricTile extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _CompactMetricTile({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.roundedMedium,
        side: BorderSide(color: AppColors.border, width: 1.0),
      ),
      child: Padding(
        padding: AppSpacing.paddingMd,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Icon(icon, size: 18.0, color: AppColors.textSecondary),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
