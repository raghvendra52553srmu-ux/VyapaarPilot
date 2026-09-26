import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/primary_button.dart';

/// Card presenting the recommended merchant action distinctly as an experiment proposition.
class OpportunityRecommendationCard extends StatelessWidget {
  final String recommendation;
  final VoidCallback onTestOpportunity;

  const OpportunityRecommendationCard({
    super.key,
    required this.recommendation,
    required this.onTestOpportunity,
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
        padding: AppSpacing.paddingLg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'What you can try',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs / 2,
                  ),
                  decoration: const BoxDecoration(
                    color: AppColors.lightBlue,
                    borderRadius: AppRadius.roundedSmall,
                  ),
                  child: const Text(
                    'PROPOSED ACTION',
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryBlue,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              recommendation.isNotEmpty ? recommendation : 'Test a targeted promotion between 4 PM and 7 PM next Tuesday.',
              style: AppTextStyles.body.copyWith(height: 1.45),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              key: const Key('test_opportunity_button'),
              text: 'Test this opportunity',
              icon: Icons.science_outlined,
              onPressed: onTestOpportunity,
            ),
          ],
        ),
      ),
    );
  }
}
