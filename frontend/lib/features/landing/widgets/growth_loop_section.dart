import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import 'landing_vectors.dart';

/// Section 4: Growth Loop.
/// The signature 4-step closed-loop intelligence cycle of VyapaarPilot.
class GrowthLoopSection extends StatelessWidget {
  const GrowthLoopSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 1024;

    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppSpacing.xxxl : AppSpacing.lg,
        vertical: isDesktop ? 80.0 : 52.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.maxContentWidth,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Eyebrow badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: const Text(
                  'CLOSED GROWTH LOOP',
                  style: TextStyle(
                    fontSize: 11.0,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                    color: AppColors.secondaryBlue,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Headline
              Text(
                'From payment signal to business action.',
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
                'Not another dashboard. A closed growth loop.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.0,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48.0),

              // 4 Loop Nodes
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildStepCard(
                        '01',
                        'DETECT',
                        'Tuesday 4–7 PM',
                        '↓ 24% vs normal',
                        Icons.search_rounded,
                        AppColors.warning,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 48.0,
                        left: 8.0,
                        right: 8.0,
                      ),
                      child: FlowStepArrow(),
                    ),
                    Expanded(
                      child: _buildStepCard(
                        '02',
                        'EXPLAIN',
                        '4 consecutive weeks',
                        '₹13,800 baseline',
                        Icons.analytics_outlined,
                        AppColors.secondaryBlue,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 48.0,
                        left: 8.0,
                        right: 8.0,
                      ),
                      child: FlowStepArrow(),
                    ),
                    Expanded(
                      child: _buildStepCard(
                        '03',
                        'ACT',
                        'Test a targeted promotion',
                        '3-hr 10% discount',
                        Icons.bolt_rounded,
                        AppColors.primary,
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                        top: 48.0,
                        left: 8.0,
                        right: 8.0,
                      ),
                      child: FlowStepArrow(),
                    ),
                    Expanded(child: _buildOutcomeStepCard()),
                  ],
                )
              else
                Column(
                  children: [
                    _buildStepCard(
                      '01',
                      'DETECT',
                      'Tuesday 4–7 PM',
                      '↓ 24% vs normal',
                      Icons.search_rounded,
                      AppColors.warning,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: FlowStepArrow(isVertical: true),
                    ),
                    _buildStepCard(
                      '02',
                      'EXPLAIN',
                      '4 consecutive weeks',
                      '₹13,800 baseline',
                      Icons.analytics_outlined,
                      AppColors.secondaryBlue,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: FlowStepArrow(isVertical: true),
                    ),
                    _buildStepCard(
                      '03',
                      'ACT',
                      'Test a targeted promotion',
                      '3-hr 10% discount',
                      Icons.bolt_rounded,
                      AppColors.primary,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: FlowStepArrow(isVertical: true),
                    ),
                    _buildOutcomeStepCard(),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(
    String stepNum,
    String title,
    String detail,
    String subtext,
    IconData icon,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.roundedMedium,
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 3.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(4.0),
                ),
                child: Text(
                  stepNum,
                  style: const TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Icon(icon, color: accentColor, size: 20.0),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            detail,
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            subtext,
            style: const TextStyle(
              fontSize: 12.0,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutcomeStepCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.roundedMedium,
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 3.0,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                ),
                child: const Text(
                  '04',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
              const Icon(
                Icons.verified_rounded,
                color: AppColors.success,
                size: 20.0,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'MEASURE',
            style: TextStyle(
              fontSize: 13.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4.0),
          const Text(
            '₹13,800 → ₹17,250',
            style: TextStyle(
              fontSize: 15.0,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 2.0),
          const Text(
            '+25% measured uplift',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(4.0),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'Synthetic demo simulation',
              style: TextStyle(
                fontSize: 9.0,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
