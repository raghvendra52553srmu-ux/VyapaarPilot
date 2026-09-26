import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// Card presenting VyapaarPilot's business explanation of the observed pattern.
class OpportunityExplanationCard extends StatelessWidget {
  final String explanation;

  const OpportunityExplanationCard({super.key, required this.explanation});

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
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.xs + 2),
                  decoration: const BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: AppRadius.roundedSmall,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 16.0,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'VyapaarPilot says',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: AppSpacing.paddingMd,
              decoration: BoxDecoration(
                color: AppColors.lightBlue.withValues(alpha: 0.5),
                borderRadius: AppRadius.roundedSmall,
                border: Border.all(
                  color: AppColors.secondaryBlue.withValues(alpha: 0.2),
                  width: 1.0,
                ),
              ),
              child: Text(
                explanation.isNotEmpty ? explanation : 'Your Tuesday evening sales have been consistently lower than your normal Tuesday sales over the last four weeks.',
                style: AppTextStyles.body.copyWith(height: 1.45),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
