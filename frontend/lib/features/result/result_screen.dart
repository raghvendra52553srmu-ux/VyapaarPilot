import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/experiment.dart';
import '../../repositories/experiment_repository.dart';
import '../../services/api/api_service.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/loading_state.dart';
import '../../shared/widgets/primary_button.dart';
import '../../shared/widgets/status_badge.dart';

/// Phase 3 Result Screen — Visual climax of the MVP action loop.
/// Accurately renders measured outcome compared to historical baseline with
/// prominent synthetic simulation disclaimers and next action guidance.
class ResultScreen extends StatefulWidget {
  final ExperimentResult? initialResult;
  final String experimentId;
  final ExperimentRepository? repository;
  final ApiService? apiService;

  const ResultScreen({
    super.key,
    this.initialResult,
    this.experimentId = 'EXP001',
    this.repository,
    this.apiService,
  });

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  late final ExperimentRepository _repository;
  ExperimentResult? _result;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? DefaultExperimentRepository();

    if (widget.initialResult != null) {
      _result = widget.initialResult;
    } else {
      _loadResult();
    }
  }

  Future<void> _loadResult() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final res = await _repository.getResult(widget.experimentId);
      if (mounted) {
        setState(() {
          _result = res;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          // Deterministic fallback
          _result = const ExperimentResult(
            experimentId: 'EXP001',
            opportunityId: 'OP001',
            merchantId: 'M001',
            baseline: 13800.0,
            result: 17250.0,
            upliftPercent: 25.0,
            incrementalAmount: 3450.0,
            status: 'completed',
            isSynthetic: true,
          );
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const AppScaffold(
        title: 'Experiment Result',
        currentIndex: 3,
        body: LoadingState(message: 'Loading experiment results...'),
      );
    }

    final data = _result ??
        const ExperimentResult(
          experimentId: 'EXP001',
          opportunityId: 'OP001',
          merchantId: 'M001',
          baseline: 13800.0,
          result: 17250.0,
          upliftPercent: 25.0,
          incrementalAmount: 3450.0,
          status: 'completed',
          isSynthetic: true,
        );

    final baselineFormatted = CurrencyFormatter.formatRupee(data.baseline);
    final experimentFormatted = CurrencyFormatter.formatRupee(data.result);
    final incrementalFormatted =
        CurrencyFormatter.formatRupee(data.incrementalAmount);
    final upliftFormatted = '+${data.upliftPercent.toStringAsFixed(0)}%';

    return AppScaffold(
      title: 'Experiment Result',
      currentIndex: 3,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: SingleChildScrollView(
            key: const Key('result_screen'),
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Status Badges
                const Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.xs,
                  alignment: WrapAlignment.spaceBetween,
                  children: [
                    StatusBadge(
                      text: 'Experiment complete ✓',
                      type: BadgeType.success,
                    ),
                    StatusBadge(
                      text: 'Tuesday • 4 PM – 7 PM',
                      type: BadgeType.info,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),

                // Main Outcome Card
                Card(
                  elevation: 0,
                  color: AppColors.surface,
                  shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.roundedMedium,
                    side: BorderSide(color: AppColors.border, width: 1.0),
                  ),
                  child: Padding(
                    padding: AppSpacing.cardPadding,
                    child: Column(
                      children: [
                        // Baseline vs Experiment Result comparison
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final isNarrow = constraints.maxWidth < 450;
                            if (isNarrow) {
                              return Column(
                                children: [
                                  _buildMetricPill(
                                    label: 'Historical baseline',
                                    value: baselineFormatted,
                                    valueKey: 'result_baseline_value',
                                    color: AppColors.textPrimary,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(
                                      vertical: AppSpacing.sm,
                                    ),
                                    child: Icon(
                                      Icons.arrow_downward,
                                      color: AppColors.secondaryBlue,
                                      size: 24.0,
                                    ),
                                  ),
                                  _buildMetricPill(
                                    label: 'Experiment result',
                                    value: experimentFormatted,
                                    valueKey: 'result_experiment_value',
                                    color: AppColors.primary,
                                  ),
                                ],
                              );
                            }
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: _buildMetricPill(
                                    label: 'Historical baseline',
                                    value: baselineFormatted,
                                    valueKey: 'result_baseline_value',
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                  ),
                                  child: Icon(
                                    Icons.arrow_forward,
                                    color: AppColors.secondaryBlue,
                                    size: 26.0,
                                  ),
                                ),
                                Expanded(
                                  child: _buildMetricPill(
                                    label: 'Experiment result',
                                    value: experimentFormatted,
                                    valueKey: 'result_experiment_value',
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        const Divider(height: 1, color: AppColors.divider),
                        const SizedBox(height: AppSpacing.xl),

                        // Visual Climax: +25% Uplift (largest visual element)
                        Container(
                          width: double.infinity,
                          padding: AppSpacing.paddingLg,
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: AppRadius.roundedMedium,
                            border: Border.all(
                              color: AppColors.success.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                upliftFormatted,
                                key: const Key('result_uplift_value'),
                                style: const TextStyle(
                                  fontSize: 48.0,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.success,
                                  letterSpacing: -1.0,
                                  height: 1.0,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              const Text(
                                'vs historical baseline',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 4.0,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: AppRadius.roundedLarge,
                                  border: Border.all(
                                    color: AppColors.success.withValues(alpha: 0.4),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '$incrementalFormatted above baseline',
                                    key: const Key('result_incremental_value'),
                                    style: const TextStyle(
                                      fontSize: 13.0,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),

                        // Synthetic Demo Simulation Disclosure Card
                        Container(
                          key: const Key('synthetic_result_disclaimer'),
                          width: double.infinity,
                          padding: AppSpacing.paddingMd,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: AppRadius.roundedSmall,
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.science_outlined,
                                size: 18.0,
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
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 2.0),
                                    Text(
                                      'This result uses synthetic hackathon data. It does not represent guaranteed merchant revenue.',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                // NEXT STEP Guidance Card
                Container(
                  width: double.infinity,
                  padding: AppSpacing.paddingLg,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: AppRadius.roundedMedium,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            size: 18.0,
                            color: AppColors.warning,
                          ),
                          SizedBox(width: AppSpacing.xs),
                          Text(
                            'NEXT STEP',
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpacing.sm),
                      Text(
                        'This test performed above the historical baseline in the simulation. Consider repeating the test and comparing future results before drawing a conclusion.',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: AppColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Primary Action: Back to Dashboard
                KeyedSubtree(
                  key: const Key('back_to_dashboard_button'),
                  child: PrimaryButton(
                    key: const Key('result_back_dashboard_button'),
                    text: 'Back to Dashboard',
                    icon: Icons.dashboard_outlined,
                    onPressed: () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRouter.dashboard,
                        (route) => false,
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // Optional secondary action: Ask Assistant
                OutlinedButton.icon(
                  key: const Key('result_ask_assistant_button'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48.0),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.roundedSmall,
                    ),
                    side: const BorderSide(color: AppColors.primary),
                  ),
                  icon: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 18),
                  label: const Text(
                    'Ask VyapaarPilot',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRouter.assistant);
                  },
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricPill({
    required String label,
    required String value,
    required String valueKey,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.0,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.xs / 2),
        Text(
          value,
          key: Key(valueKey),
          style: TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
