import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/routing/app_router.dart';
import 'landing_vectors.dart';

/// Minimal sticky top navigation for VyapaarPilot public landing page.
class LandingNavBar extends StatelessWidget {
  final VoidCallback onHowItWorksTap;
  final VoidCallback onWhyVyapaarPilotTap;
  final VoidCallback onVoiceAiTap;

  const LandingNavBar({
    super.key,
    required this.onHowItWorksTap,
    required this.onWhyVyapaarPilotTap,
    required this.onVoiceAiTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 960;

    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppSpacing.xxxl : AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppBreakpoints.maxContentWidth,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left: Logo & Wordmark
              Flexible(
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRouter.landing,
                      (route) => false,
                    );
                  },
                  borderRadius: AppRadius.roundedSmall,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const VyapaarLogoMark(size: 32.0),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: Text(
                          'VyapaarPilot',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: isDesktop ? 20.0 : 18.0,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      if (isDesktop) ...[
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6.0,
                          vertical: 2.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightBlue,
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: const Text(
                          'AI Growth Partner',
                          style: TextStyle(
                            fontSize: 10.0,
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Middle: Navigation links (Desktop only)
            if (isDesktop)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NavLink(label: 'How it works', onTap: onHowItWorksTap),
                  const SizedBox(width: AppSpacing.xxl),
                  _NavLink(
                    label: 'Why VyapaarPilot',
                    onTap: onWhyVyapaarPilotTap,
                  ),
                  const SizedBox(width: AppSpacing.xxl),
                  _NavLink(label: 'Voice AI', onTap: onVoiceAiTap),
                ],
              ),

            // Right: Primary App Launch CTA
            ElevatedButton(
              key: const Key('landing_nav_open_app_button'),
              onPressed: () {
                Navigator.pushNamed(context, AppRouter.dashboard);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop ? AppSpacing.lg : AppSpacing.md,
                  vertical: isDesktop ? AppSpacing.md : AppSpacing.sm,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.roundedSmall,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Open VyapaarPilot',
                      style: TextStyle(
                        fontSize: isDesktop ? 13.0 : 12.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4.0),
                    const Icon(Icons.arrow_forward_rounded, size: 14.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _NavLink({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
