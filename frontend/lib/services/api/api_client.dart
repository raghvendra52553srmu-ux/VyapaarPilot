import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_endpoints.dart';
import '../../models/merchant_summary.dart';
import '../../models/opportunity.dart';
import '../../models/experiment.dart';
import '../../models/ai_response.dart';

class ApiClient {
  final http.Client _client;

  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<MerchantSummary> getMerchantSummary(String merchantId) async {
    try {
      final response = await _client.get(
        Uri.parse(ApiEndpoints.merchantSummary(merchantId)),
      );
      if (response.statusCode == 200) {
        return MerchantSummary.fromJson(json.decode(response.body));
      }
    } catch (_) {}

    // Fallback mock model for offline/scaffold preview
    return MerchantSummary(
      merchantId: merchantId,
      merchantName: 'Sharma General Store',
      todaySales: 18420,
      salesChangePercent: -12,
      transactionCount: 73,
      averageTransaction: 252,
    );
  }

  Future<List<Opportunity>> getMerchantOpportunities(String merchantId) async {
    try {
      final response = await _client.get(
        Uri.parse(ApiEndpoints.merchantOpportunities(merchantId)),
      );
      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        return list.map((e) => Opportunity.fromJson(e)).toList();
      }
    } catch (_) {}

    return [
      Opportunity(
        opportunityId: 'OP001',
        merchantId: merchantId,
        type: 'slow_period',
        title: 'Tuesday evening slowdown',
        day: 'Tuesday',
        period: '16:00-19:00',
        declinePercent: 24,
        baseline: 13800,
        current: 10488,
        weeksObserved: 4,
      ),
    ];
  }

  Future<RecommendationResponse> getRecommendation(
    String opportunityId, {
    String language = 'hinglish',
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiEndpoints.recommendAction(opportunityId)),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'merchant_id': 'M001',
          'preferred_language': language,
        }),
      );
      if (response.statusCode == 200) {
        return RecommendationResponse.fromJson(json.decode(response.body));
      }
    } catch (_) {}

    return RecommendationResponse(
      opportunityId: opportunityId,
      title: 'Tuesday evening slowdown',
      explanation: 'Pichle 4 hafte se Har Tuesday ko 4 PM se 7 PM ke dauran sales 24% tak drop ho rahi hai.',
      recommendation: 'Tuesday 4-7 PM ke liye 10% discount promo run karein taaki footfall aur sales badhe.',
      experimentPeriod: '16:00-19:00',
    );
  }

  Future<Experiment> createExperiment(String opportunityId) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiEndpoints.experiments),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'opportunity_id': opportunityId,
          'merchant_id': 'M001',
        }),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Experiment.fromJson(json.decode(response.body));
      }
    } catch (_) {}

    return Experiment(
      experimentId: 'EXP001',
      opportunityId: opportunityId,
      merchantId: 'M001',
      baseline: 13800,
      result: 17250,
      upliftPercent: 25,
      status: 'completed',
    );
  }
}
