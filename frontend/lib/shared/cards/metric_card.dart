import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final double? changePercent;
  final IconData icon;

  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.changePercent,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = (changePercent ?? 0) < 0;
    final changeColor = isNegative ? AppColors.error : AppColors.success;

    return Card(
      color: AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 18, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            if (changePercent != null)
              Row(
                children: [
                  Icon(
                    isNegative ? Icons.arrow_downward : Icons.arrow_upward,
                    size: 14,
                    color: changeColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${changePercent!.abs().toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: changeColor,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(width: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ]
                ],
              )
            else if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
    );
  }
}
