import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/experiment.dart';
import '../../services/api/api_client.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/buttons/primary_button.dart';
import '../../core/utils/currency_formatter.dart';

class ExperimentScreen extends StatefulWidget {
  final String opportunityId;

  const ExperimentScreen({
    super.key,
    required this.opportunityId,
  });

  @override
  State<ExperimentScreen> createState() => _ExperimentScreenState();
}

class _ExperimentScreenState extends State<ExperimentScreen> {
  final ApiClient _apiClient = ApiClient();
  Experiment? _experiment;
  bool _isLoading = false;

  Future<void> _runExperiment() async {
    setState(() => _isLoading = true);
    final exp = await _apiClient.createExperiment(widget.opportunityId);
    if (mounted) {
      setState(() {
        _experiment = exp;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Synthetic Experiment Setup',
      currentIndex: 2,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Synthetic Demo Notice Banner
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.lightBlue,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.secondaryBlue.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.secondaryBlue, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'HACKATHON DEMO MODE: All experiment results are simulated using synthetic transaction data.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (_experiment == null) ...[
              Card(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Targeted 3-Hour Promotion',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Test a 10% discount during Tuesday 4:00 PM - 7:00 PM to evaluate footfall and sales uplift.',
                        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 20),
                      PrimaryButton(
                        label: 'Simulate Experiment Now',
                        icon: Icons.play_arrow,
                        isLoading: _isLoading,
                        onPressed: _runExperiment,
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Experiment Result Card
              Card(
                color: AppColors.surface,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatusBadge(
                            label: 'Experiment Completed',
                            backgroundColor: Color(0xFFDCFCE7),
                            textColor: AppColors.success,
                          ),
                          StatusBadge(
                            label: 'Synthetic Simulation',
                            backgroundColor: AppColors.lightBlue,
                            textColor: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Measured Sales Outcome',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 20),

                      // Uplift Highlight Container
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Sales Uplift', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                                SizedBox(height: 4),
                                Text(
                                  '+25.0% Uplift',
                                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.success),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.success,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.trending_up, color: Colors.white, size: 24),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Comparison Rows
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Baseline Sales', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyFormatter.formatRupee(_experiment!.baseline),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Experiment Sales', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyFormatter.formatRupee(_experiment!.result),
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.success),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Return to Dashboard',
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/');
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
