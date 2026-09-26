import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_badge.dart';

/// Phase 1 Experiment Screen
/// Establishes the experiment setup parameters and simulation trigger.
class ExperimentScreen extends StatelessWidget {
  const ExperimentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Run Experiment',
      currentIndex: 2,
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Simulation Notice Pill
            Container(
              padding: AppSpacing.paddingMd,
              decoration: const BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: AppRadius.roundedSmall,
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20.0,
                    color: AppColors.secondaryBlue,
                  ),
                  SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'HACKATHON DEMO: Experiments simulate outcome uplift using synthetic transaction history.',
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
                        StatusBadge(
                          text: 'Tuesday • 4 PM – 7 PM',
                          type: BadgeType.info,
                        ),
                        StatusBadge(
                          text: 'READY TO RUN',
                          type: BadgeType.neutral,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    const Text(
                      'Targeted 3-Hour Promotion',
                      style: AppTextStyles.pageTitle,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Test a 10% discount on key items to lift evening transactions.',
                      style: AppTextStyles.secondary,
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    const SectionHeader(title: 'Experiment Parameters'),
                    const SizedBox(height: AppSpacing.md),

                    const Row(
                      children: [
                        Expanded(
                          child: MetricCard(
                            label: 'Historical baseline',
                            value: '₹13,800',
                            subtitle: 'Expected Tuesday 4-7 PM',
                            icon: Icons.history,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: MetricCard(
                            label: 'Target Window',
                            value: '3 Hours',
                            subtitle: '4:00 PM – 7:00 PM',
                            icon: Icons.timer_outlined,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.xxl),

                    PrimaryButton(
                      text: 'Start Experiment',
                      icon: Icons.play_arrow,
                      onPressed: () {
                        Navigator.pushNamed(context, AppRouter.result);
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
