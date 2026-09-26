import 'package:flutter/material.dart';
import '../../models/merchant_summary.dart';
import '../../models/opportunity.dart';
import '../../services/api/api_client.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/loading_state.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/cards/metric_card.dart';
import '../../shared/cards/opportunity_card.dart';
import '../../shared/charts/trend_chart.dart';
import '../../core/utils/currency_formatter.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiClient _apiClient = ApiClient();
  MerchantSummary? _summary;
  List<Opportunity> _opportunities = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    final summary = await _apiClient.getMerchantSummary('M001');
    final opportunities = await _apiClient.getMerchantOpportunities('M001');
    if (mounted) {
      setState(() {
        _summary = summary;
        _opportunities = opportunities;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'VyapaarPilot Dashboard',
      currentIndex: 0,
      body: _isLoading
          ? const LoadingState(message: 'Analyzing business data...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Merchant Summary Metrics Grid
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          title: "Today's Sales",
                          value: CurrencyFormatter.formatRupee(_summary?.todaySales ?? 18420),
                          changePercent: _summary?.salesChangePercent ?? -12,
                          subtitle: 'vs yesterday',
                          icon: Icons.account_balance_wallet_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MetricCard(
                          title: 'Transactions',
                          value: '${_summary?.transactionCount ?? 73}',
                          subtitle: 'Completed today',
                          icon: Icons.receipt_long_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MetricCard(
                          title: 'Avg Order Value',
                          value: CurrencyFormatter.formatRupee(_summary?.averageTransaction ?? 252),
                          subtitle: 'Per transaction',
                          icon: Icons.shopping_bag_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Sales Trend Chart
                  const TrendChart(),

                  const SizedBox(height: 24),

                  // Growth Opportunities Section
                  const SectionHeader(title: 'Growth Opportunities Identified'),
                  const SizedBox(height: 12),

                  if (_opportunities.isEmpty)
                    const Text('No opportunities detected currently.')
                  else
                    ..._opportunities.map(
                      (opp) => OpportunityCard(
                        opportunity: opp,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/opportunity',
                            arguments: opp.opportunityId,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}
