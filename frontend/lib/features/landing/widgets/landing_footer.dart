import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import 'landing_vectors.dart';

/// Minimal footer for VyapaarPilot public landing page.
class LandingFooter extends StatelessWidget {
  const LandingFooter({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.maxContentWidth,
          ),
          child: Column(
            children: [
              const Divider(color: AppColors.divider, height: 1.0),
              const SizedBox(height: AppSpacing.xl),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: AppSpacing.xl,
                runSpacing: AppSpacing.lg,
                children: [
                  _buildBrandInfo(),
                  _buildTeamInfo(),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                '© 2026 VyapaarPilot • Built for Hack-e-Awadh 2026 • Synthetic Demo Environment',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11.0,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBrandInfo() {
    return const Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: 4.0,
      children: [
        VyapaarLogoMark(size: 24.0),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'VyapaarPilot',
              style: TextStyle(
                fontSize: 15.0,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              'Har payment se, agla smart kadam.',
              style: TextStyle(fontSize: 11.0, color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamInfo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Aarambh Coders 2.0',
          style: TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 2.0),
        Text(
          'Sundram Gupta • Sara Ali Ahmad • Raghvendra Pandey',
          style: TextStyle(fontSize: 11.0, color: AppColors.textSecondary),
        ),
        SizedBox(height: 2.0),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.code_rounded,
              size: 12.0,
              color: AppColors.secondaryBlue,
            ),
            SizedBox(width: 4.0),
            Text(
              'github.com/sundramdotdev',
              style: TextStyle(
                fontSize: 11.0,
                fontWeight: FontWeight.w500,
                color: AppColors.secondaryBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
