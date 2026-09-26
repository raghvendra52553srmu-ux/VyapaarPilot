import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';

/// Section 7: Differentiation + Final Conversion CTA.
/// Focuses purely on the distinct value proposition of closing the commercial loop.
class DifferentiationSection extends StatelessWidget {
  const DifferentiationSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 800;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppSpacing.xxxl : AppSpacing.lg,
        vertical: isDesktop ? 80.0 : 48.0,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
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
                  'WHY VYAAPAARPILOT',
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
                "Don't give merchants another dashboard.\nGive them a growth loop.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 32.0 : 24.0,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.25,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 48.0),

              // Comparison Table / Cards
              if (isDesktop)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildTraditionalCard()),
                    const SizedBox(width: 32.0),
                    Expanded(child: _buildVyapaarPilotCard()),
                  ],
                )
              else
                Column(
                  children: [
                    _buildTraditionalCard(),
                    const SizedBox(height: 20.0),
                    _buildVyapaarPilotCard(),
                  ],
                ),

              const SizedBox(height: 56.0),

              // Final Conversion Call-To-Action
              ElevatedButton(
                key: const Key('landing_open_app_button'),
                onPressed: () {
                  Navigator.pushNamed(context, AppRouter.dashboard);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 32.0 : 16.0,
                    vertical: isDesktop ? 18.0 : 14.0,
                  ),
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.roundedSmall,
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'Open VyapaarPilot',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isDesktop ? 16.0 : 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    const Icon(Icons.arrow_forward_rounded, size: 18.0),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              const Text(
                'Hack-e-Awadh • PS-02 Merchant Growth AI',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTraditionalCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: AppRadius.roundedMedium,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TRADITIONAL ANALYTICS',
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _buildRow('What happened?', true, isDimmed: false),
          const SizedBox(height: AppSpacing.sm),
          _buildRow('Why does it matter?', false, isDimmed: true),
          const SizedBox(height: AppSpacing.sm),
          _buildRow('What can I try?', false, isDimmed: true),
          const SizedBox(height: AppSpacing.sm),
          _buildRow('Did it work?', false, isDimmed: true),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Leaves the merchant with charts but no direction.',
            style: TextStyle(
              fontSize: 12.0,
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVyapaarPilotCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.roundedMedium,
        border: Border.all(
          color: AppColors.paymentBlue.withValues(alpha: 0.6),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.paymentBlue.withValues(alpha: 0.08),
            blurRadius: 18,
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
              const Text(
                'VYAAPAARPILOT',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: AppColors.secondaryBlue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6.0,
                  vertical: 2.0,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.all(Radius.circular(4.0)),
                ),
                child: const Text(
                  'CLOSED LOOP',
                  style: TextStyle(
                    fontSize: 9.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _buildRow('What happened?', true, isHighlight: true),
          const SizedBox(height: AppSpacing.sm),
          _buildRow('Why does it matter?', true, isHighlight: true),
          const SizedBox(height: AppSpacing.sm),
          _buildRow('What can I try?', true, isHighlight: true),
          const SizedBox(height: AppSpacing.sm),
          _buildRow('Did it work?', true, isHighlight: true),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'Detects, explains, acts, and measures measurable business outcome.',
            style: TextStyle(
              fontSize: 12.0,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
    String question,
    bool isSupported, {
    bool isDimmed = false,
    bool isHighlight = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2.0),
          child: Icon(
            isSupported
                ? Icons.check_circle_rounded
                : Icons.remove_circle_outline_rounded,
            size: 16.0,
            color: isSupported
                ? (isHighlight ? AppColors.success : AppColors.textSecondary)
                : AppColors.border,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            '"$question"',
            style: TextStyle(
              fontSize: 14.0,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.normal,
              color: isDimmed
                  ? AppColors.textSecondary.withValues(alpha: 0.5)
                  : AppColors.textPrimary,
              decoration: (!isSupported && isDimmed)
                  ? TextDecoration.lineThrough
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}
