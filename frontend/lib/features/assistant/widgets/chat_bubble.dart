import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../models/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onConfirmAction;
  final VoidCallback? onCancelAction;

  const ChatBubble({
    super.key,
    required this.message,
    this.onConfirmAction,
    this.onCancelAction,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isUser) {
      return _buildUserBubble();
    }
    return _buildAssistantBubble(context);
  }

  Widget _buildUserBubble() {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(left: 48.0, bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(14.0),
            topRight: Radius.circular(14.0),
            bottomLeft: Radius.circular(14.0),
            bottomRight: Radius.circular(2.0),
          ),
        ),
        child: Text(
          message.text,
          style: const TextStyle(
            fontSize: 14.0,
            color: Colors.white,
            height: 1.35,
          ),
        ),
      ),
    );
  }

  Widget _buildAssistantBubble(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 32.0, bottom: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: AppColors.lightBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 16.0,
                    color: AppColors.secondaryBlue,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(2.0),
                        topRight: Radius.circular(14.0),
                        bottomLeft: Radius.circular(14.0),
                        bottomRight: Radius.circular(14.0),
                      ),
                      border: Border.all(
                        color: AppColors.border,
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      message.text,
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Tool Execution Indicator
            if (message.toolName != null) ...[
              Container(
                margin: const EdgeInsets.only(left: 36.0, top: AppSpacing.xs),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 4.0,
                ),
                decoration: BoxDecoration(
                  color: AppColors.lightBlue.withValues(alpha: 0.5),
                  borderRadius: AppRadius.roundedSmall,
                  border: Border.all(
                    color: AppColors.secondaryBlue.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.settings_suggest,
                      size: 14.0,
                      color: AppColors.secondaryBlue,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      'Executed: ${message.toolName}',
                      style: const TextStyle(
                        fontSize: 11.0,
                        fontFamily: 'monospace',
                        color: AppColors.secondaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Agentic Action Confirmation Card
            if (message.actionProposal != null) ...[
              Padding(
                padding: const EdgeInsets.only(left: 36.0, top: AppSpacing.sm),
                child: _buildActionConfirmationCard(
                  context,
                  message.actionProposal!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionConfirmationCard(
    BuildContext context,
    ActionProposal proposal,
  ) {
    return Container(
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedMedium,
        border: Border.all(
          color: proposal.isConfirmed
              ? AppColors.success
              : AppColors.warning.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (proposal.isConfirmed ? AppColors.success : AppColors.warning)
                .withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                proposal.isConfirmed
                    ? Icons.check_circle
                    : Icons.bolt,
                size: 18.0,
                color: proposal.isConfirmed
                    ? AppColors.success
                    : AppColors.warning,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                proposal.isConfirmed
                    ? 'ACTION CONFIRMED'
                    : 'AGENTIC ACTION PROPOSAL',
                style: TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                  color: proposal.isConfirmed
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            proposal.title,
            style: const TextStyle(
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2.0),
          Text(
            proposal.description,
            style: const TextStyle(
              fontSize: 12.0,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          if (proposal.isConfirmed)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4.0,
              ),
              decoration: const BoxDecoration(
                color: AppColors.successLight,
                borderRadius: AppRadius.roundedSmall,
              ),
              child: const Text(
                'Starting simulation on synthetic data...',
                style: TextStyle(
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  color: AppColors.success,
                ),
              ),
            )
          else if (proposal.isCancelled)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: 4.0,
              ),
              decoration: const BoxDecoration(
                color: AppColors.background,
                borderRadius: AppRadius.roundedSmall,
              ),
              child: const Text(
                'Action cancelled by merchant.',
                style: TextStyle(
                  fontSize: 12.0,
                  color: AppColors.textSecondary,
                ),
              ),
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  key: const Key('assistant_cancel_action_button'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: const BorderSide(color: AppColors.border),
                  ),
                  onPressed: onCancelAction,
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 13.0,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                ElevatedButton(
                  key: const Key('assistant_confirm_action_button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    elevation: 0,
                  ),
                  onPressed: onConfirmAction,
                  child: const Text(
                    'Confirm',
                    style: TextStyle(
                      fontSize: 13.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
