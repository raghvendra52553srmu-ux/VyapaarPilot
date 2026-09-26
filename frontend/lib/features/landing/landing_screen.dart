import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'widgets/differentiation_section.dart';
import 'widgets/growth_loop_section.dart';
import 'widgets/hero_section.dart';
import 'widgets/landing_footer.dart';
import 'widgets/landing_nav_bar.dart';
import 'widgets/problem_section.dart';
import 'widgets/product_showcase_section.dart';
import 'widgets/voice_agent_section.dart';

/// Premium Public Landing Page for VyapaarPilot.
/// Designed for 15-second hackathon judge comprehension and high-trust Indian fintech aesthetics.
class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  final ScrollController _scrollController = ScrollController();

  final GlobalKey _growthLoopKey = GlobalKey();
  final GlobalKey _voiceAiKey = GlobalKey();
  final GlobalKey _whyKey = GlobalKey();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToKey(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        top: true,
        bottom: false,
        child: Column(
          children: [
            // Sticky top navigation bar
            LandingNavBar(
              onHowItWorksTap: () => _scrollToKey(_growthLoopKey),
              onWhyVyapaarPilotTap: () => _scrollToKey(_whyKey),
              onVoiceAiTap: () => _scrollToKey(_voiceAiKey),
            ),

            // Scrollable body containing all structured sections
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    // Section 2: Hero
                    HeroSection(
                      onHowItWorksTap: () => _scrollToKey(_growthLoopKey),
                    ),

                    // Section 3: The Problem
                    const ProblemSection(),

                    // Section 4: Signature Growth Loop
                    GrowthLoopSection(key: _growthLoopKey),

                    // Section 5: Realistic Product Showcase & Evidence
                    const ProductShowcaseSection(),

                    // Section 6: Voice / Multilingual Conversational Agent
                    VoiceAgentSection(key: _voiceAiKey),

                    // Section 7: Differentiation & Final Conversion CTA
                    DifferentiationSection(key: _whyKey),

                    // Footer
                    const LandingFooter(),
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
