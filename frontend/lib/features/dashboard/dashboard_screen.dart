import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../models/merchant_summary.dart';
import '../../models/opportunity.dart';
import '../../models/sales_trend.dart';
import '../../services/api/api_service.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/loading_state.dart';
import '../../shared/widgets/section_header.dart';
import 'widgets/dashboard_header.dart';
import 'widgets/opportunity_banner_card.dart';
import 'widgets/primary_sales_card.dart';
import 'widgets/sales_trend_card.dart';
import 'widgets/secondary_metrics_row.dart';

/// Phase 2 Merchant Dashboard Screen
/// Integrates real-like merchant business performance, sales trends, and detected opportunities.
class DashboardScreen extends StatefulWidget {
  final ApiService? apiService;

  const DashboardScreen({super.key, this.apiService});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final ApiService _apiService;

  MerchantSummary? _summary;
  SalesTrend? _salesTrend;
  List<Opportunity> _opportunities = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? HttpApiService();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final summaryFuture = _apiService.getMerchantSummary('M001');
      final trendFuture = _apiService.getSalesTrend('M001');
      final opportunitiesFuture = _apiService.getOpportunities('M001');

      final results = await Future.wait([
        summaryFuture,
        trendFuture,
        opportunitiesFuture,
      ]);

      if (mounted) {
        setState(() {
          _summary = results[0] as MerchantSummary;
          _salesTrend = results[1] as SalesTrend;
          _opportunities = results[2] as List<Opportunity>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = "We couldn't load your business insights.";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'VyapaarPilot',
      currentIndex: 0,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingState(message: 'Loading your business...');
    }

    if (_errorMessage != null) {
      return ErrorState(message: _errorMessage!, onRetry: _loadDashboardData);
    }

    final summary = _summary;
    if (summary == null) {
      return const EmptyState(
        title: 'No business data available',
        subtitle: 'VyapaarPilot will keep watching your business.',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: AppSpacing.screenPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Merchant Header
            DashboardHeader(
              greeting: 'Good morning',
              merchantName: summary.merchantName,
              locationAndCategory: '${summary.city} • ${summary.businessType}',
            ),
            const SizedBox(height: AppSpacing.lg),

            // 2. Primary Sales Card
            PrimarySalesCard(
              salesAmount: summary.todaySales,
              changePercent: summary.salesChangePercent,
              comparisonText: 'vs usual',
            ),
            const SizedBox(height: AppSpacing.md),

            // 3. Secondary Metrics Row
            SecondaryMetricsRow(
              transactionCount: summary.transactionCount,
              averageTransaction: summary.averageTransaction,
            ),
            const SizedBox(height: AppSpacing.xl),

            // 4. Compact Sales Trend
            if (_salesTrend != null) ...[
              SalesTrendCard(trend: _salesTrend!),
              const SizedBox(height: AppSpacing.xl),
            ],

            // 5. Opportunity Section
            const SectionHeader(
              title: 'OPPORTUNITY FOR YOU',
              subtitle: 'Important pattern requiring your attention',
            ),
            const SizedBox(height: AppSpacing.sm),

            if (_opportunities.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.sm),
                child: EmptyState(
                  title: 'No new opportunities found.',
                  subtitle: 'VyapaarPilot will keep watching your business.',
                ),
              )
            else
              ..._opportunities.map(
                (opportunity) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: OpportunityBannerCard(
                    opportunity: opportunity,
                    onViewInsight: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.opportunity,
                        arguments: opportunity,
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
