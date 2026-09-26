import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routing/app_router.dart';
import '../../models/opportunity.dart';
import '../../services/api/api_service.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/error_state.dart';
import '../../shared/widgets/loading_state.dart';
import 'widgets/opportunity_comparison_card.dart';
import 'widgets/opportunity_evidence_card.dart';
import 'widgets/opportunity_explanation_card.dart';
import 'widgets/opportunity_hero_card.dart';
import 'widgets/opportunity_recommendation_card.dart';

/// Phase 2 Opportunity Details Screen
/// Explains WHAT was detected, WHY (evidence & comparison), and WHAT action to test.
class OpportunityScreen extends StatefulWidget {
  final Opportunity? opportunity;
  final String opportunityId;
  final ApiService? apiService;

  const OpportunityScreen({
    super.key,
    this.opportunity,
    this.opportunityId = 'OP001',
    this.apiService,
  });

  @override
  State<OpportunityScreen> createState() => _OpportunityScreenState();
}

class _OpportunityScreenState extends State<OpportunityScreen> {
  late final ApiService _apiService;
  Opportunity? _opportunity;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _apiService = widget.apiService ?? HttpApiService();

    if (widget.opportunity != null) {
      _opportunity = widget.opportunity;
    } else {
      _loadOpportunity();
    }
  }

  Future<void> _loadOpportunity() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final opp = await _apiService.getOpportunityDetail(widget.opportunityId);
      if (mounted) {
        setState(() {
          _opportunity = opp;
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
      title: 'Business Opportunity',
      currentIndex: 1,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const LoadingState(message: 'Looking for opportunities...');
    }

    if (_errorMessage != null) {
      return ErrorState(message: _errorMessage!, onRetry: _loadOpportunity);
    }

    final opp = _opportunity;
    if (opp == null) {
      return ErrorState(
        message: "Opportunity details not found.",
        onRetry: _loadOpportunity,
      );
    }

    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Main Opportunity Hero
          OpportunityHeroCard(opportunity: opp),
          const SizedBox(height: AppSpacing.lg),

          // 2. Why are we showing this? (Evidence)
          OpportunityEvidenceCard(opportunity: opp),
          const SizedBox(height: AppSpacing.lg),

          // 3. Performance Comparison
          OpportunityComparisonCard(opportunity: opp),
          const SizedBox(height: AppSpacing.lg),

          // 4. VyapaarPilot says (AI / Business Explanation)
          OpportunityExplanationCard(explanation: opp.explanation),
          const SizedBox(height: AppSpacing.lg),

          // 5. What you can try (Recommendation & Phase 3 Handoff CTA)
          OpportunityRecommendationCard(
            recommendation: opp.recommendation,
            onTestOpportunity: () {
              Navigator.pushNamed(
                context,
                AppRouter.experiment,
                arguments: opp,
              );
            },
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}
