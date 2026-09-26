import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';

/// Section 5: Product Showcase.
/// Realistic UI composition exhibiting Opportunity, Evidence, Action, and Experiment Result.
class ProductShowcaseSection extends StatelessWidget {
  const ProductShowcaseSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 1024;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppSpacing.xxxl : AppSpacing.lg,
        vertical: isDesktop ? 80.0 : 48.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.maxContentWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Eyebrow
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  'INTERACTIVE DEMO PREVIEW',
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Headline
              Text(
                'One opportunity. Clear evidence. One next step.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 32.0 : 24.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.25,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'VyapaarPilot isolates a single high-impact pattern and equips the merchant with a clear testable action.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.0,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 48.0),

              // Realistic 2-column or stacked UI composition
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildOpportunityEvidenceCard(context),
                    ),
                    const SizedBox(width: 32.0),
                    Expanded(
                      flex: 5,
                      child: _buildExperimentResultCard(context),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    _buildOpportunityEvidenceCard(context),
                    const SizedBox(height: 24.0),
                    _buildExperimentResultCard(context),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOpportunityEvidenceCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.roundedLarge,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header badge
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                ),
                child: const Text(
                  'BUSINESS OPPORTUNITY',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: AppColors.warning,
                  ),
                ),
              ),
              const Text(
                'Tuesday • 4 PM – 7 PM',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Title & Drop Metric
          const Text(
            'Tuesday evening slowdown',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4.0),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: 4.0,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 3.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  '24% below normal',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.warning,
                  ),
                ),
              ),
              const Text(
                '₹10,488 vs ₹13,800 usual',
                style: TextStyle(
                  fontSize: 13.0,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          const Divider(color: AppColors.divider, height: 1.0),
          const SizedBox(height: AppSpacing.lg),

          // Evidence Box
          const Text(
            'WHY ARE WE SHOWING THIS?',
            style: TextStyle(
              fontSize: 11.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _buildEvidenceItem(
            '4 consecutive Tuesdays showing identical slowdown',
          ),
          _buildEvidenceItem('Same 4 PM – 7 PM evening tea/commute window'),
          _buildEvidenceItem('Historical baseline: ₹13,800 normal volume'),
          _buildEvidenceItem('Recent average: ₹10,488 (consistent ₹3,312 gap)'),
          const SizedBox(height: AppSpacing.lg),

          // Recommendation & CTA
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.veryLightBlue,
              borderRadius: AppRadius.roundedMedium,
              border: Border.all(color: AppColors.lightBlue),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WHAT YOU CAN TRY',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: AppColors.secondaryBlue,
                  ),
                ),
                const SizedBox(height: 4.0),
                const Text(
                  'Test a targeted 10% promotion during Tuesday 4–7 PM to recover shopper footfall.',
                  style: TextStyle(
                    fontSize: 13.0,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ElevatedButton(
                  key: const Key('landing_showcase_test_button'),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.opportunity);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 10.0,
                    ),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.roundedSmall,
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          'Test this opportunity',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 6.0),
                      Icon(Icons.arrow_forward_rounded, size: 14.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperimentResultCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.roundedLarge,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8.0,
            runSpacing: 4.0,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                ),
                child: const Text(
                  'MEASURED OUTCOME',
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                    color: AppColors.success,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 2.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4.0),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Text(
                  'Synthetic demo simulation',
                  style: TextStyle(
                    fontSize: 10.0,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          const Text(
            'Targeted Promotion Result',
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4.0),
          const Text(
            'Tuesday 4 PM – 7 PM • 10% Snack & Beverage Discount',
            style: TextStyle(fontSize: 12.0, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Baseline vs Experiment comparison
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: const BoxDecoration(
                    color: AppColors.background,
                    borderRadius: AppRadius.roundedMedium,
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HISTORICAL',
                        style: TextStyle(
                          fontSize: 10.0,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        '₹13,800',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Baseline sales',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.secondaryBlue,
                  size: 20.0,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.successLight.withValues(alpha: 0.5),
                    borderRadius: AppRadius.roundedMedium,
                    border: Border.all(
                      color: AppColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'EXPERIMENT',
                        style: TextStyle(
                          fontSize: 10.0,
                          color: AppColors.success,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        '₹17,250',
                        style: TextStyle(
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        '+25% Uplift',
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // Net incremental impact
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.lightBlue.withValues(alpha: 0.5),
              borderRadius: AppRadius.roundedMedium,
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  color: AppColors.secondaryBlue,
                  size: 20.0,
                ),
                SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '₹3,450 Incremental Revenue',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        'Recovered Tuesday evening loss through targeted local action.',
                        style: TextStyle(
                          fontSize: 11.0,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEvidenceItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_rounded,
            size: 16.0,
            color: AppColors.success,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13.0,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
