import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/status_badge.dart';

/// Clean merchant header displaying greeting, business name, and location/category.
class DashboardHeader extends StatelessWidget {
  final String greeting;
  final String merchantName;
  final String locationAndCategory;

  const DashboardHeader({
    super.key,
    this.greeting = 'Good morning',
    this.merchantName = 'Sharma General Store',
    this.locationAndCategory = 'Lucknow • Retail',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTextStyles.secondary.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    merchantName,
                    style: AppTextStyles.pageTitle.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs / 2),
                  Text(
                    locationAndCategory,
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const StatusBadge(text: 'OPEN', type: BadgeType.success),
          ],
        ),
      ],
    );
  }
}
