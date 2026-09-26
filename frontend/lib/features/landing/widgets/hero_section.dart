import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';
import 'landing_vectors.dart';

/// Asymmetric Hero Section for VyapaarPilot.
/// Combines punchy fintech value proposition with a high-fidelity live product composition.
class HeroSection extends StatelessWidget {
  final VoidCallback onHowItWorksTap;

  const HeroSection({super.key, required this.onHowItWorksTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 1024;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          bottom: BorderSide(color: AppColors.divider, width: 1.0),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppSpacing.xxxl : AppSpacing.lg,
        vertical: isDesktop ? 64.0 : 40.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.maxContentWidth,
          ),
          child: isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 6,
                      child: _buildLeftHeroContent(context, true),
                    ),
                    const SizedBox(width: 48.0),
                    Expanded(
                      flex: 5,
                      child: _buildRightProductComposition(context, true),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLeftHeroContent(context, false),
                    const SizedBox(height: 40.0),
                    _buildRightProductComposition(context, false),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLeftHeroContent(BuildContext context, bool isDesktop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Eyebrow badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: AppColors.secondaryBlue.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8.0,
                height: 8.0,
                decoration: const BoxDecoration(
                  color: AppColors.paymentBlue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8.0),
              const Flexible(
                child: Text(
                  'AI growth partner for small merchants',
                  style: TextStyle(
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Headline
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: isDesktop ? 44.0 : 30.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.15,
              letterSpacing: -1.0,
            ),
            children: const [
              TextSpan(
                text: 'Your payments know what happened.\nVyapaarPilot tells you ',
              ),
              TextSpan(
                text: 'what to do next.',
                style: TextStyle(color: AppColors.paymentBlue),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Supporting copy
        Text(
          'VyapaarPilot turns everyday transaction patterns into clear opportunities, testable actions and measurable outcomes — in the language a merchant actually uses.',
          style: TextStyle(
            fontSize: isDesktop ? 16.0 : 14.0,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),

        // Action Buttons
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.sm,
          children: [
            ElevatedButton(
              key: const Key('landing_hero_explore_button'),
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.dashboard);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 24.0 : 16.0,
                  vertical: isDesktop ? 16.0 : 12.0,
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
                      'Explore VyapaarPilot',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Icon(Icons.arrow_forward_rounded, size: 18.0),
                ],
              ),
            ),
            OutlinedButton(
              key: const Key('landing_hero_how_it_works_button'),
              onPressed: onHowItWorksTap,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.border, width: 1.5),
                backgroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? 20.0 : 14.0,
                  vertical: isDesktop ? 16.0 : 12.0,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.roundedSmall,
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.play_circle_outline_rounded,
                    size: 18.0,
                    color: AppColors.secondaryBlue,
                  ),
                  SizedBox(width: 8.0),
                  Flexible(
                    child: Text(
                      'See how it works',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),

        // Trust line
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified_user_outlined,
              size: 15.0,
              color: AppColors.success,
            ),
            const SizedBox(width: 6.0),
            Flexible(
              child: Text(
                'Built on synthetic merchant data • Human-approved actions',
                style: TextStyle(
                  fontSize: 12.0,
                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRightProductComposition(BuildContext context, bool isDesktop) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Main Merchant Sales Overview Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: AppRadius.roundedLarge,
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Header
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.lightBlue,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: const Icon(
                            Icons.storefront,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        const Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Good morning,',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                'Sharma General Store',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: const Text(
                      'Lucknow • Retail',
                      style: TextStyle(
                        fontSize: 10.0,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              // Today's Sales Metric
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.end,
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.xs,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TODAY'S SALES",
                        style: TextStyle(
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        '₹18,420',
                        style: TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: const Text(
                      '↓ 12% vs usual',
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              const Divider(color: AppColors.divider, height: 1.0),
              const SizedBox(height: AppSpacing.md),

              // Transaction stream preview
              const Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8.0,
                runSpacing: 4.0,
                children: [
                  Text(
                    '73 Transactions • Avg. ₹252',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  PaymentStreamVector(width: 80, height: 20),
                ],
              ),
            ],
          ),
        ),

        // Connected Opportunity Callout Card
        Positioned(
          left: isDesktop ? -16.0 : 8.0,
          bottom: -28.0,
          right: isDesktop ? 20.0 : 8.0,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppRadius.roundedMedium,
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: AppColors.warningLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.trending_down_rounded,
                    color: AppColors.warning,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6.0,
                        runSpacing: 2.0,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6.0,
                              vertical: 2.0,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warningLight,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: const Text(
                              'OPPORTUNITY DETECTED',
                              style: TextStyle(
                                fontSize: 9.0,
                                fontWeight: FontWeight.bold,
                                color: AppColors.warning,
                              ),
                            ),
                          ),
                          const Text(
                            '↓ 24% vs normal',
                            style: TextStyle(
                              fontSize: 11.0,
                              fontWeight: FontWeight.bold,
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3.0),
                      const Text(
                        'Tuesday evening • 4 PM – 7 PM',
                        style: TextStyle(
                          fontSize: 13.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        'Observed consistently for 4 weeks',
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
        ),

        // Voice Query Floating Pill (Top Right)
        Positioned(
          top: -16.0,
          right: isDesktop ? -12.0 : 8.0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12.0,
              vertical: 8.0,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.mic, color: AppColors.paymentBlue, size: 16),
                SizedBox(width: 6.0),
                Flexible(
                  child: Text(
                    '"Meri sales mein kya opportunity hai?"',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
