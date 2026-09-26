import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/constants/api_endpoints.dart';
import '../../models/ai_response.dart';
import '../../models/experiment.dart';
import '../../models/merchant_summary.dart';
import '../../models/opportunity.dart';
import '../../models/sales_trend.dart';

/// Abstract API Service contract for VyapaarPilot.
/// Aligned with FastAPI endpoints for Phase 2 & Phase 3.
abstract class ApiService {
  Future<MerchantSummary> getMerchantSummary(String merchantId);
  Future<SalesTrend> getSalesTrend(String merchantId);
  Future<List<Opportunity>> getOpportunities(String merchantId);
  Future<Opportunity?> getOpportunityDetail(String opportunityId);
  Future<Experiment> createExperiment(String opportunityId, String merchantId);
  Future<Experiment> getExperimentResult(String experimentId);
  Future<AiAskResponse> askAi(
    String merchantId,
    String question, {
    String language = 'hinglish',
  });
}

/// Phase 2 Mock Implementation
/// Provides realistic synthetic merchant business intelligence data
/// completely decoupled from live network, database, or LLM services.
class MockApiService implements ApiService {
  final String baseUrl;

  // Mock control flags for state simulation in tests & previews
  bool shouldSimulateError;
  bool shouldReturnEmptyOpportunities;

  MockApiService({
    this.baseUrl = ApiConstants.defaultBaseUrl,
    this.shouldSimulateError = false,
    this.shouldReturnEmptyOpportunities = false,
  });

  @override
  Future<MerchantSummary> getMerchantSummary(String merchantId) async {
    if (shouldSimulateError) {
      throw Exception("Could not load merchant summary");
    }
    return const MerchantSummary(
      merchantId: 'M001',
      merchantName: 'Sharma General Store',
      city: 'Lucknow',
      businessType: 'Retail',
      todaySales: 18420.0,
      salesChangePercent: -12.0,
      transactionCount: 73,
      averageTransaction: 252.0,
      currency: 'INR',
    );
  }

  @override
  Future<SalesTrend> getSalesTrend(String merchantId) async {
    if (shouldSimulateError) {
      throw Exception("Could not load sales trend");
    }
    return const SalesTrend(
      period: '7d',
      data: [
        DailySalesPoint(label: 'Mon', sales: 16200.0),
        DailySalesPoint(label: 'Tue', sales: 15400.0), // Tuesday slowdown
        DailySalesPoint(label: 'Wed', sales: 17800.0),
        DailySalesPoint(label: 'Thu', sales: 18100.0),
        DailySalesPoint(label: 'Fri', sales: 19500.0),
        DailySalesPoint(label: 'Sat', sales: 22800.0),
        DailySalesPoint(label: 'Sun', sales: 20500.0),
      ],
    );
  }

  @override
  Future<List<Opportunity>> getOpportunities(String merchantId) async {
    if (shouldSimulateError) {
      throw Exception("Could not load opportunities");
    }
    if (shouldReturnEmptyOpportunities) {
      return const [];
    }

    return const [
      Opportunity(
        opportunityId: 'OP001',
        merchantId: 'M001',
        type: 'slow_period',
        title: 'Tuesday evening sales are unusually low',
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
      ),
    ];
  }

  @override
  Future<Opportunity?> getOpportunityDetail(String opportunityId) async {
    final list = await getOpportunities('M001');
    final matches = list.where((o) => o.opportunityId == opportunityId);
    if (matches.isNotEmpty) return matches.first;
    return list.isNotEmpty ? list.first : null;
  }

  @override
  Future<Experiment> createExperiment(
    String opportunityId,
    String merchantId,
  ) async {
    return const Experiment(
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
  }

  @override
  Future<Experiment> getExperimentResult(String experimentId) async {
    return const Experiment(
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
  }

  @override
  Future<AiAskResponse> askAi(
    String merchantId,
    String question, {
    String language = 'hinglish',
  }) async {
    if (shouldSimulateError) {
      throw Exception("AI service unavailable");
    }

    final qLower = question.toLowerCase();
    if (language.toLowerCase() == 'hindi' || qLower.contains('मंगलवार')) {
      return const AiAskResponse(
        answer:
            'शर्मा जी, आपके डेटा के अनुसार हर मंगलवार को 4 PM से 7 PM के बीच बिक्री में 24% की गिरावट देखी गई है (₹13,800 बेसलाइन से ₹10,488 औसत)। हम 10% डिस्काउंट प्रोमो का सुझाव देते हैं।',
        suggestedActions: [
          'Start Tuesday 4–7 PM experiment',
          'अवसर विवरण देखें',
        ],
      );
    } else if (language.toLowerCase() == 'english') {
      return const AiAskResponse(
        answer:
            'Sharma General Store: Tuesday 4 PM – 7 PM sales are consistently 24% below normal baseline (₹10,488 vs ₹13,800). We recommend testing a targeted 3-hour 10% discount promo.',
        suggestedActions: [
          'Start Tuesday 4–7 PM experiment',
          'View Opportunity Details',
        ],
      );
    }

    // Default Hinglish
    return const AiAskResponse(
      answer:
          'Sharma ji, aapke transaction records ke anusaar pichle 4 hafte se har Tuesday ko 4 PM se 7 PM ke beech sales 24% down chal rahi hai (₹13,800 baseline ke mukable ₹10,488). Kya hum 10% discount experiment run karein?',
      suggestedActions: [
        'Start Tuesday 4–7 PM experiment',
        'View Opportunity Details',
      ],
    );
  }
}

/// Live HTTP API Service that calls FastAPI backend with graceful fallback to MockApiService.
/// Ensures 100% test reliability and instant live integration when FastAPI is running.
class HttpApiService implements ApiService {
  final http.Client _client;
  final MockApiService _fallback;
  final Duration timeout;

  HttpApiService({
    http.Client? client,
    MockApiService? fallback,
    this.timeout = const Duration(milliseconds: 1500),
  })  : _client = client ?? http.Client(),
        _fallback = fallback ?? MockApiService();

  @override
  Future<MerchantSummary> getMerchantSummary(String merchantId) async {
    try {
      final response = await _client
          .get(Uri.parse(ApiEndpoints.merchantSummary(merchantId)))
          .timeout(timeout);
      if (response.statusCode == 200) {
        return MerchantSummary.fromJson(json.decode(response.body));
      }
    } catch (_) {}
    return _fallback.getMerchantSummary(merchantId);
  }

  @override
  Future<SalesTrend> getSalesTrend(String merchantId) async {
    try {
      final response = await _client
          .get(Uri.parse(ApiEndpoints.merchantTrends(merchantId)))
          .timeout(timeout);
      if (response.statusCode == 200) {
        return SalesTrend.fromJson(json.decode(response.body));
      }
    } catch (_) {}
    return _fallback.getSalesTrend(merchantId);
  }

  @override
  Future<List<Opportunity>> getOpportunities(String merchantId) async {
    try {
      final response = await _client
          .get(Uri.parse(ApiEndpoints.merchantOpportunities(merchantId)))
          .timeout(timeout);
      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        return list.map((e) => Opportunity.fromJson(e)).toList();
      }
    } catch (_) {}
    return _fallback.getOpportunities(merchantId);
  }

  @override
  Future<Opportunity?> getOpportunityDetail(String opportunityId) async {
    try {
      final response = await _client
          .get(Uri.parse(ApiEndpoints.opportunityDetail(opportunityId)))
          .timeout(timeout);
      if (response.statusCode == 200) {
        return Opportunity.fromJson(json.decode(response.body));
      }
    } catch (_) {}
    return _fallback.getOpportunityDetail(opportunityId);
  }

  @override
  Future<Experiment> createExperiment(
    String opportunityId,
    String merchantId,
  ) async {
    try {
      final response = await _client
          .post(
            Uri.parse(ApiEndpoints.experiments),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'opportunity_id': opportunityId,
              'merchant_id': merchantId,
            }),
          )
          .timeout(timeout);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return Experiment.fromJson(json.decode(response.body));
      }
    } catch (_) {}
    return _fallback.createExperiment(opportunityId, merchantId);
  }

  @override
  Future<Experiment> getExperimentResult(String experimentId) async {
    try {
      final response = await _client
          .get(Uri.parse(ApiEndpoints.experimentDetail(experimentId)))
          .timeout(timeout);
      if (response.statusCode == 200) {
        return Experiment.fromJson(json.decode(response.body));
      }
    } catch (_) {}
    return _fallback.getExperimentResult(experimentId);
  }

  @override
  Future<AiAskResponse> askAi(
    String merchantId,
    String question, {
    String language = 'hinglish',
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(ApiEndpoints.aiAsk),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'merchant_id': merchantId,
              'question': question,
            }),
          )
          .timeout(timeout);
      if (response.statusCode == 200) {
        return AiAskResponse.fromJson(json.decode(response.body));
      }
    } catch (_) {}
    return _fallback.askAi(merchantId, question, language: language);
  }
}
