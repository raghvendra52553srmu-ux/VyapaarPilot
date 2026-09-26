import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/opportunity.dart';
import '../widgets/status_badge.dart';

class OpportunityCard extends StatelessWidget {
  final Opportunity opportunity;
  final VoidCallback onTap;

  const OpportunityCard({
    super.key,
    required this.opportunity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatusBadge(
                    label: '${opportunity.day} ${opportunity.period}',
                    backgroundColor: AppColors.lightBlue,
                    textColor: AppColors.primary,
                  ),
                  StatusBadge(
                    label:
                        '${opportunity.declinePercent.abs().toStringAsFixed(0)}% Slowdown',
                    backgroundColor: AppColors.warning.withValues(alpha: 0.15),
                    textColor: AppColors.warning,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                opportunity.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Sales decline observed across ${opportunity.weeksObserved} consecutive weeks.',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'View Opportunity',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondaryBlue,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: AppColors.secondaryBlue,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
