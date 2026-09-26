import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_badge.dart';

/// Phase 1 Opportunity Screen
/// Presents the detected underperformance pattern and the recommended experiment action.
class OpportunityScreen extends StatelessWidget {
  const OpportunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Business Signal',
      currentIndex: 1,
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Opportunity Signal Card
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatusBadge(
                          text: 'Tuesday • 4 PM – 7 PM',
                          type: BadgeType.info,
                        ),
                        StatusBadge(
                          text: '24% below normal',
                          type: BadgeType.warning,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'Tuesday evening slowdown',
                      style: AppTextStyles.pageTitle,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Tuesday • 4 PM – 7 PM',
                      style: AppTextStyles.secondary,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Metric Comparison Row
                    const Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            label: 'Historical Baseline',
                            value: '₹13,800',
                            subtitle: 'Average 4-week sales',
                            icon: Icons.history,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: MetricCard(
                            label: 'Recent Performance',
                            value: '₹10,488',
                            trend: -24.0,
                            subtitle: 'During 4 PM – 7 PM',
                            icon: Icons.trending_down,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Explanation Block
                    const SectionHeader(
                      title: 'Pattern Explanation',
                      subtitle: 'AI-interpreted merchant context',
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: AppSpacing.paddingMd,
                      decoration: const BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: AppRadius.roundedSmall,
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.insights,
                            color: AppColors.primary,
                            size: 20.0,
                          ),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(
                              'Every Tuesday between 4 PM and 7 PM, sales consistently drop 24% below the store baseline. Testing a targeted 3-hour discount or combo offer can recover customer footfall.',
                              style: AppTextStyles.body,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    // Action CTA
                    PrimaryButton(
                      text: 'Test this opportunity',
                      icon: Icons.science_outlined,
                      onPressed: () {
                        Navigator.pushNamed(context, AppRouter.experiment);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
