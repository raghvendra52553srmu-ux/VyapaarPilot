import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/metric_card.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/status_badge.dart';

/// Phase 1 Dashboard Screen
/// Establishes page structure, typography, metrics, and navigation CTA.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'VyapaarPilot',
      currentIndex: 0,
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Merchant Identity Card
            Card(
              child: Padding(
                padding: AppSpacing.cardPadding,
                child: Row(
                  children: [
                    Container(
                      width: 48.0,
                      height: 48.0,
                      decoration: const BoxDecoration(
                        color: AppColors.lightBlue,
                        borderRadius: AppRadius.roundedSmall,
                      ),
                      child: const Icon(
                        Icons.store_mall_directory_outlined,
                        color: AppColors.primary,
                        size: 24.0,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sharma General Store',
                            style: AppTextStyles.pageTitle,
                          ),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            'Lucknow • Retail',
                            style: AppTextStyles.secondary,
                          ),
                        ],
                      ),
                    ),
                    const StatusBadge(text: 'ACTIVE', type: BadgeType.success),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Financial Metrics Overview
            const SectionHeader(
              title: 'Overview',
              subtitle: 'Today\'s business snapshot',
            ),
            const SizedBox(height: AppSpacing.md),

            // Responsive Metrics Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= AppBreakpoints.mobile;
                if (isWide) {
                  return const Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          label: "Today's Sales",
                          value: '₹18,420',
                          trend: -12.0,
                          subtitle: 'vs yesterday',
                          icon: Icons.trending_up,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: MetricCard(
                          label: 'Transactions',
                          value: '73',
                          subtitle: 'Completed today',
                          icon: Icons.receipt_long_outlined,
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: MetricCard(
                          label: 'Avg Order Value',
                          value: '₹252',
                          subtitle: 'Per transaction',
                          icon: Icons.shopping_bag_outlined,
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Column(
                    children: [
                      MetricCard(
                        label: "Today's Sales",
                        value: '₹18,420',
                        trend: -12.0,
                        subtitle: 'vs yesterday',
                        icon: Icons.trending_up,
                      ),
                      SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              label: 'Transactions',
                              value: '73',
                              subtitle: 'Completed today',
                              icon: Icons.receipt_long_outlined,
                            ),
                          ),
                          SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: MetricCard(
                              label: 'Avg Order',
                              value: '₹252',
                              subtitle: 'Per order',
                              icon: Icons.shopping_bag_outlined,
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),

            const SizedBox(height: AppSpacing.xxl),

            // Opportunities Section with Navigation CTA
            const SectionHeader(
              title: 'Business Signals',
              subtitle: 'Detected anomalies requiring attention',
            ),
            const SizedBox(height: AppSpacing.md),

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
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Tuesday evening slowdown',
                      style: AppTextStyles.sectionHeading,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'Recurring drop in sales observed over the past 4 weeks during evening peak hours.',
                      style: AppTextStyles.secondary,
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRouter.opportunity);
                        },
                        icon: const Icon(
                          Icons.arrow_forward,
                          size: 16.0,
                          color: AppColors.secondaryBlue,
                        ),
                        label: const Text(
                          'View Opportunity',
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryBlue,
                          ),
                        ),
                      ),
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
