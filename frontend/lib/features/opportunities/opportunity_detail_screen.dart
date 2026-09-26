import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../models/ai_response.dart';
import '../../services/api/api_client.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/loading_state.dart';
import '../../shared/widgets/status_badge.dart';
import '../../shared/buttons/primary_button.dart';
import '../../core/utils/currency_formatter.dart';

class OpportunityDetailScreen extends StatefulWidget {
  final String opportunityId;

  const OpportunityDetailScreen({super.key, required this.opportunityId});

  @override
  State<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState extends State<OpportunityDetailScreen> {
  final ApiClient _apiClient = ApiClient();
  RecommendationResponse? _recommendation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOpportunity();
  }

  Future<void> _loadOpportunity() async {
    setState(() => _isLoading = true);
    final rec = await _apiClient.getRecommendation(widget.opportunityId);
    if (mounted) {
      setState(() {
        _recommendation = rec;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Opportunity Analysis',
      currentIndex: 1,
      body: _isLoading
          ? const LoadingState(message: 'Generating AI explanation...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: AppColors.surface,
                    child: Padding(
                      padding: const EdgeInsets.all(18.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StatusBadge(
                                label: 'Tuesday 16:00 - 19:00',
                                backgroundColor: AppColors.lightBlue,
                                textColor: AppColors.primary,
                              ),
                              StatusBadge(
                                label: '24% Decline',
                                backgroundColor: Color(0xFFFEF3C7),
                                textColor: AppColors.warning,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _recommendation?.title ??
                                'Tuesday Evening Slowdown',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Sales Baseline vs Recent Comparison
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Historical Baseline',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        CurrencyFormatter.formatRupee(13800),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 30,
                                  width: 1,
                                  color: Colors.grey.shade300,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 14.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Recent Tuesday Sales',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          CurrencyFormatter.formatRupee(10488),
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // AI Explanation Box
                          const Text(
                            'AI Explanation',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.lightBlue,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.secondaryBlue.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  color: AppColors.secondaryBlue,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _recommendation?.explanation ?? '',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.textPrimary,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Recommended Action
                          const Text(
                            'Recommended Action',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _recommendation?.recommendation ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 24),

                          PrimaryButton(
                            label: 'Run 3-Hour Promotion Experiment',
                            icon: Icons.science,
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/experiment',
                                arguments: widget.opportunityId,
                              );
                            },
                          ),
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
