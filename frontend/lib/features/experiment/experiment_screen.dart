import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/experiment.dart';
import '../../models/opportunity.dart';
import '../../repositories/experiment_repository.dart';
import '../../services/api/api_service.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/status_badge.dart';

enum ExperimentExecutionState {
  idle,
  running,
  error,
  invalidOpportunity,
}

/// Phase 3 Experiment Setup & Execution Screen.
/// Clearly communicates what was detected, the test parameters, historical baseline,
/// and upfront synthetic simulation disclosure before allowing execution.
class ExperimentScreen extends StatefulWidget {
  final Opportunity? opportunity;
  final String? opportunityId;
  final ExperimentRepository? repository;
  final ApiService? apiService;

  const ExperimentScreen({
    super.key,
    this.opportunity,
    this.opportunityId = 'OP001',
    this.repository,
    this.apiService,
  });

  @override
  State<ExperimentScreen> createState() => _ExperimentScreenState();
}

class _ExperimentScreenState extends State<ExperimentScreen> {
  late final ExperimentRepository _repository;
  Opportunity? _opportunity;
  ExperimentExecutionState _executionState = ExperimentExecutionState.idle;
  String? _errorMessage;
  bool _isExecuting = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? DefaultExperimentRepository();

    if (widget.opportunity != null) {
      _opportunity = widget.opportunity;
    } else if (widget.opportunityId == 'invalid' ||
        widget.opportunityId == 'empty') {
      _executionState = ExperimentExecutionState.invalidOpportunity;
    } else {
      // Default fallback opportunity for M001
      _opportunity = const Opportunity(
        opportunityId: 'OP001',
        merchantId: 'M001',
        type: 'slow_period',
        title: 'Tuesday evening slowdown',
        day: 'Tuesday',
        period: '4 PM – 7 PM',
        declinePercent: 24.0,
        baseline: 13800.0,
        current: 10488.0,
        weeksObserved: 4,
        evidence: [
          '4 consecutive Tuesdays',
          'Same 4–7 PM period',
          'Normal baseline: ₹13,800',
          'Recent average: ₹10,488',
        ],
        explanation:
            'Your Tuesday evening sales have been consistently lower than your normal Tuesday sales over the last four weeks.',
        recommendation:
            'Test a targeted promotion between 4 PM and 7 PM next Tuesday.',
      );
    }
  }

  Future<void> _startExperiment() async {
    // Prevent duplicate rapid taps
    if (_isExecuting) return;
    _isExecuting = true;

    setState(() {
      _executionState = ExperimentExecutionState.running;
      _errorMessage = null;
    });

    try {
      final oppId = _opportunity?.opportunityId ?? widget.opportunityId ?? 'OP001';
      final request = ExperimentRequest(
        merchantId: 'M001',
        opportunityId: oppId,
      );

      final result = await _repository.startExperiment(request);

      if (!mounted) return;

      _isExecuting = false;
      _executionState = ExperimentExecutionState.idle;

      // Navigate to Result screen with measured outcome
      Navigator.pushNamed(
        context,
        AppRouter.result,
        arguments: result,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isExecuting = false;
        _executionState = ExperimentExecutionState.error;
        _errorMessage = "We couldn't run the experiment.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Test this opportunity',
      currentIndex: 2,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            key: const Key('experiment_screen'),
            padding: AppSpacing.screenPadding,
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_executionState == ExperimentExecutionState.invalidOpportunity) {
      return _buildInvalidOpportunityView(context);
    }

    if (_executionState == ExperimentExecutionState.error) {
      return _buildErrorState(context);
    }

    final opp = _opportunity!;
    final baselineFormatted = CurrencyFormatter.formatRupee(opp.baseline);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Headline & Title
        Text(
          opp.title.isNotEmpty ? opp.title : 'Tuesday evening slowdown',
          key: const Key('experiment_opportunity_title'),
          style: AppTextStyles.pageTitle.copyWith(
            fontSize: 22.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),

        // Opportunity period & Status
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            Container(
              key: const Key('experiment_period'),
              child: StatusBadge(
                text: '${opp.day} • ${opp.period}',
                type: BadgeType.info,
              ),
            ),
            const StatusBadge(
              text: 'READY TO RUN',
              type: BadgeType.neutral,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),

        // Baseline Card
        Card(
          elevation: 0,
          color: AppColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.roundedMedium,
            side: BorderSide(color: AppColors.border, width: 1.0),
          ),
          child: Padding(
            padding: AppSpacing.paddingLg,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Historical baseline',
                        style: TextStyle(
                          fontSize: 13.0,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        baselineFormatted,
                        key: const Key('experiment_baseline_value'),
                        style: const TextStyle(
                          fontSize: 28.0,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: const BoxDecoration(
                    color: AppColors.lightBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.history,
                    color: AppColors.secondaryBlue,
                    size: 26.0,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        // WHY TEST THIS? Card
        _buildInfoCard(
          title: 'WHY TEST THIS?',
          content:
              'Sales during this period have been below your usual Tuesday evening level for four consecutive weeks.',
          icon: Icons.help_outline,
          iconColor: AppColors.secondaryBlue,
        ),
        const SizedBox(height: AppSpacing.md),

        // TEST Card
        _buildInfoCard(
          title: 'TEST',
          content: 'Try a targeted promotion during Tuesday 4 PM – 7 PM.',
          icon: Icons.local_offer_outlined,
          iconColor: AppColors.primary,
        ),
        const SizedBox(height: AppSpacing.md),

        // WHAT WE'LL COMPARE Card
        _buildInfoCard(
          title: "WHAT WE'LL COMPARE",
          content: 'Historical baseline vs experiment-period performance',
          icon: Icons.compare_arrows,
          iconColor: AppColors.textPrimary,
        ),
        const SizedBox(height: AppSpacing.xl),

        // Upfront Synthetic Demo Disclosure Notice
        Container(
          key: const Key('synthetic_demo_badge'),
          padding: AppSpacing.paddingMd,
          decoration: BoxDecoration(
            color: AppColors.lightBlue,
            borderRadius: AppRadius.roundedSmall,
            border: Border.all(
              color: AppColors.secondaryBlue.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.science,
                size: 20.0,
                color: AppColors.secondaryBlue,
              ),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Synthetic demo simulation',
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: 2.0),
                    Text(
                      'HACKATHON DEMO: Experiments simulate outcome uplift using synthetic transaction history. No real financial or store changes occur.',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Loading execution state indicator
        if (_executionState == ExperimentExecutionState.running) ...[
          Container(
            key: const Key('experiment_loading_state'),
            padding: AppSpacing.paddingLg,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: AppRadius.roundedMedium,
              border: Border.all(color: AppColors.secondaryBlue, width: 1.5),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryBlue),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Text(
                  'Running synthetic experiment...',
                  style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Start Experiment CTA Button
        PrimaryButton(
          key: const Key('start_experiment_button'),
          text: _isExecuting ? 'Running experiment...' : 'Start Experiment',
          icon: _isExecuting ? null : Icons.play_arrow,
          isLoading: _isExecuting,
          onPressed: _isExecuting ? null : _startExperiment,
        ),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.paddingMd,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedMedium,
        border: Border.all(color: AppColors.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16.0, color: iconColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11.0,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.6,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13.5,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Container(
      key: const Key('experiment_error_state'),
      padding: AppSpacing.paddingXl,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedMedium,
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 36.0,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            _errorMessage ?? "We couldn't run the experiment.",
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Your experiment was not started. Please try again.',
            style: TextStyle(
              fontSize: 13.0,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () {
                  setState(() {
                    _executionState = ExperimentExecutionState.idle;
                  });
                },
                child: const Text('Back'),
              ),
              const SizedBox(width: AppSpacing.md),
              ElevatedButton(
                key: const Key('experiment_retry_button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: _startExperiment,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInvalidOpportunityView(BuildContext context) {
    return Container(
      padding: AppSpacing.paddingXl,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.roundedMedium,
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            size: 40.0,
            color: AppColors.warning,
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Opportunity unavailable',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            "The opportunity you're trying to test could not be loaded.",
            style: TextStyle(
              fontSize: 13.0,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.lg),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Back to Opportunities'),
          ),
        ],
      ),
    );
  }
}
