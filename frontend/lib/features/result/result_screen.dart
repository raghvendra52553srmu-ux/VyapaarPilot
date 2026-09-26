import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_badge.dart';

/// Phase 1 Result Screen
/// Displays the measured outcome of the promotion experiment with explicit synthetic demo notices.
class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Experiment Result',
      currentIndex: 2,
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Synthetic Demo Notice Banner
            Container(
              padding: AppSpacing.paddingMd,
              decoration: const BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: AppRadius.roundedSmall,
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.science,
                    color: AppColors.secondaryBlue,
                    size: 20.0,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'DEMO RESULT: Measured uplift generated from synthetic simulation data.',
                      style: AppTextStyles.caption,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        StatusBadge(text: 'COMPLETED', type: BadgeType.success),
                        StatusBadge(
                          text: 'Tuesday • 4 PM – 7 PM',
                          type: BadgeType.info,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'Experiment Complete',
                      style: AppTextStyles.pageTitle,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Targeted 3-Hour Promotion test completed.',
                      style: AppTextStyles.secondary,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    // Uplift Highlight Card
                    Container(
                      padding: AppSpacing.paddingLg,
                      decoration: const BoxDecoration(
                        color: AppColors.successLight,
                        borderRadius: AppRadius.roundedMedium,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Measured Uplift',
                                style: AppTextStyles.secondary.copyWith(
                                  color: AppColors.success,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              const Text(
                                '+25% observed uplift',
                                style: TextStyle(
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 24.0,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // Financial Comparison
                    const SectionHeader(title: 'Performance Comparison'),
                    const SizedBox(height: AppSpacing.md),

                    const Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            label: 'Historical Baseline',
                            value: '₹13,800',
                            subtitle: 'Baseline Tuesday sales',
                            icon: Icons.history,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: MetricCard(
                            label: 'Experiment Result',
                            value: '₹17,250',
                            trend: 25.0,
                            subtitle: 'During promotion',
                            icon: Icons.trending_up,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    PrimaryButton(
                      text: 'Back to Dashboard',
                      icon: Icons.dashboard_outlined,
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          AppRouter.dashboard,
                          (route) => false,
                        );
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
