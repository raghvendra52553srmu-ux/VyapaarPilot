import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import 'landing_vectors.dart';

/// Section 6: Voice & Multilingual Agent.
/// Dark Navy contrast section showcasing English, Hindi, and Hinglish agentic flow with human confirmation.
class VoiceAgentSection extends StatelessWidget {
  const VoiceAgentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 1024;

    return Container(
      width: double.infinity,
      color: AppColors.deepNavy,
      padding: EdgeInsets.symmetric(
        horizontal: isDesktop ? AppSpacing.xxxl : AppSpacing.lg,
        vertical: isDesktop ? 88.0 : 56.0,
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
                  horizontal: 12.0,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20.0),
                  border: Border.all(
                    color: AppColors.paymentBlue.withValues(alpha: 0.4),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mic, color: AppColors.paymentBlue, size: 14.0),
                    SizedBox(width: 6.0),
                    Flexible(
                      child: Text(
                        'MULTILINGUAL CONVERSATIONAL INTELLIGENCE',
                        style: TextStyle(
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Headline
              Text(
                "Business intelligence that speaks the merchant's language.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isDesktop ? 34.0 : 24.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.25,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Subtitle
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: const Text(
                  'Ask in English, Hindi or Hinglish. VyapaarPilot can understand the request, retrieve business context and execute approved actions through controlled tools.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Color(0xFFBAC7D5),
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Voice Waveform Graphic
              const VoiceWaveformVector(
                width: 160.0,
                height: 36.0,
                barColor: AppColors.paymentBlue,
              ),
              const SizedBox(height: 40.0),

              // Interactive Conversational UI Mockup
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  decoration: BoxDecoration(
                    color: const Color(0xFF132F4C),
                    borderRadius: AppRadius.roundedLarge,
                    border: Border.all(color: const Color(0xFF1E4976)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header showing languages
                      Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: [
                          const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.record_voice_over_rounded,
                                color: AppColors.paymentBlue,
                                size: 18,
                              ),
                              SizedBox(width: AppSpacing.sm),
                              Text(
                                'Live Conversation',
                                style: TextStyle(
                                  fontSize: 13.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          Wrap(
                            spacing: 4.0,
                            runSpacing: 4.0,
                            children: [
                              _buildLanguagePill('English'),
                              _buildLanguagePill('हिंदी'),
                              _buildLanguagePill('Hinglish', isActive: true),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Divider(color: Color(0xFF1E4976), height: 1.0),
                      const SizedBox(height: AppSpacing.lg),

                      // Turn 1: Merchant query
                      _buildChatTurn(
                        isUser: true,
                        speaker: 'Merchant (Voice)',
                        text: 'Meri sales mein kya opportunity hai?',
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Turn 1: Agent response
                      _buildChatTurn(
                        isUser: false,
                        speaker: 'VyapaarPilot',
                        text: 'Tuesday ko 4–7 PM ke beech aapki sales normal se 24% kam rahi hain (₹13,800 baseline vs ₹10,488 actual). Kya hum targeted promo test karein?',
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Turn 2: Merchant Action command
                      _buildChatTurn(
                        isUser: true,
                        speaker: 'Merchant',
                        text: 'Experiment start karo.',
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Turn 2: Confirmation Proposal (Controlled tool execution)
                      Container(
                        margin: EdgeInsets.only(left: isDesktop ? 28.0 : 0.0),
                        padding: const EdgeInsets.all(AppSpacing.md),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F263D),
                          borderRadius: AppRadius.roundedMedium,
                          border: Border.all(
                            color: AppColors.warning.withValues(alpha: 0.6),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.security_rounded,
                                  color: AppColors.warning,
                                  size: 16,
                                ),
                                SizedBox(width: 6.0),
                                Flexible(
                                  child: Text(
                                    'HUMAN CONFIRMATION REQUIRED',
                                    style: TextStyle(
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                      color: AppColors.warning,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6.0),
                            const Text(
                              'Tuesday 4–7 PM experiment start karun?',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 6.0,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(4.0),
                                    border: Border.all(color: Colors.white24),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0,
                                    vertical: 6.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryBlue,
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: const Text(
                                    'Confirm',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Outcome success
                      Container(
                        margin: EdgeInsets.only(left: isDesktop ? 28.0 : 0.0),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 6.0,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4.0),
                          border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: 2.0),
                              child: Icon(
                                Icons.check_circle_rounded,
                                size: 14.0,
                                color: AppColors.success,
                              ),
                            ),
                            SizedBox(width: 6.0),
                            Flexible(
                              child: Text(
                                'Experiment created ✓ Baseline: ₹13,800 → Result: ₹17,250 (+25% Uplift)',
                                style: TextStyle(
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40.0),

              // Architecture pipeline hint
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF132F4C),
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(color: const Color(0xFF1E4976)),
                ),
                child: const Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8.0,
                  runSpacing: 6.0,
                  children: [
                    Text(
                      'VOICE',
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.paymentBlue,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: Colors.white38,
                    ),
                    Text(
                      'UNDERSTAND',
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: Colors.white38,
                    ),
                    Text(
                      'TOOL',
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: Colors.white38,
                    ),
                    Text(
                      'CONFIRM',
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.warning,
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 12,
                      color: Colors.white38,
                    ),
                    Text(
                      'ACT',
                      style: TextStyle(
                        fontSize: 11.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.success,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      '• Human approval before actions',
                      style: TextStyle(
                        fontSize: 11.0,
                        color: Color(0xFFBAC7D5),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLanguagePill(String lang, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
      decoration: BoxDecoration(
        color: isActive ? AppColors.paymentBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(4.0),
      ),
      child: Text(
        lang,
        style: TextStyle(
          fontSize: 10.0,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? Colors.white : Colors.white60,
        ),
      ),
    );
  }

  Widget _buildChatTurn({
    required bool isUser,
    required String speaker,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: isUser ? AppColors.primary : AppColors.secondaryBlue,
          child: Icon(
            isUser ? Icons.person : Icons.auto_awesome,
            size: 13.0,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                speaker,
                style: const TextStyle(
                  fontSize: 10.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white60,
                ),
              ),
              const SizedBox(height: 2.0),
              Text(
                text,
                style: const TextStyle(
                  fontSize: 13.0,
                  color: Colors.white,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
