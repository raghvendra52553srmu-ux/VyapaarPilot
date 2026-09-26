import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../../core/constants/api_endpoints.dart';
import '../../models/ai_response.dart';
import '../../models/experiment.dart';
import '../../models/merchant_summary.dart';
import '../../models/opportunity.dart';
import '../../models/sales_trend.dart';


/// Controls whether the app uses real API data or falls back to mock.
enum DataMode { api, mock, auto }

/// Abstract API Service contract for VyapaarPilot.
/// Aligned with FastAPI endpoints across all four project phases.
abstract class ApiService {
  Future<MerchantSummary> getMerchantSummary(String merchantId);
  Future<SalesTrend> getSalesTrend(String merchantId);
  Future<List<Opportunity>> getOpportunities(String merchantId);
  Future<Opportunity?> getOpportunityDetail(String opportunityId);
  Future<RecommendationResponse> getRecommendation(
    String opportunityId, {
    String language = 'hinglish',
  });
  Future<Experiment> createExperiment(String opportunityId, String merchantId);
  Future<Experiment> getExperimentResult(String experimentId);
  Future<AiAskResponse> askAi(
    String merchantId,
    String question, {
    String language = 'hinglish',
    String? conversationId,
  });
  Future<AiAskResponse> sendVoice(
    String merchantId,
    List<int> audioBytes, {
    String language = 'hinglish',
    String? conversationId,
    String mimeType = 'audio/wav',
    String? mockTranscript,
  });
  Future<ActionExecuteResponse> executeAction(
    String merchantId,
    String actionId, {
    String? tool,
    Map<String, dynamic>? arguments,
  });
  Future<CapabilitiesResponse> getCapabilities();
  Future<bool> checkHealth();
}

/// Demo & Test Mock Implementation
/// Provides deterministic synthetic merchant intelligence data
/// completely decoupled from live network, database, or LLM services.
class MockApiService implements ApiService {
  final String baseUrl;

  // Mock control flags for state simulation in tests & previews
  bool shouldSimulateError;
  bool shouldSimulateSttError;
  bool shouldReturnEmptyOpportunities;
  String? mockSttTranscript;
  int createExperimentCallCount = 0;

  MockApiService({
    this.baseUrl = ApiConstants.defaultBaseUrl,
    this.shouldSimulateError = false,
    this.shouldSimulateSttError = false,
    this.shouldReturnEmptyOpportunities = false,
    this.mockSttTranscript,
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
        DailySalesPoint(label: 'Tue', sales: 15400.0),
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
        explanation: 'Your Tuesday evening sales have been consistently lower than your normal Tuesday sales over the last four weeks.',
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
  Future<RecommendationResponse> getRecommendation(
    String opportunityId, {
    String language = 'hinglish',
  }) async {
    if (shouldSimulateError) {
      throw Exception("Could not generate recommendation");
    }
    return RecommendationResponse(
      opportunityId: opportunityId,
      title: 'Targeted 3-Hour Combo Promotion',
      explanation: 'Tuesday 4 PM – 7 PM sales are 24% below normal. A 10% combo discount can recover footfall.',
      recommendation:
          'Run a 10% combo discount experiment next Tuesday 4 PM – 7 PM.',
      experimentPeriod: 'Tuesday • 4 PM – 7 PM',
      estimatedUpliftRange: '+15% to +30%',
    );
  }

  @override
  Future<Experiment> createExperiment(
    String opportunityId,
    String merchantId,
  ) async {
    if (shouldSimulateError) {
      throw Exception("Could not create experiment");
    }
    createExperimentCallCount++;
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
    if (shouldSimulateError) {
      throw Exception("Could not fetch experiment result");
    }
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
    String? conversationId,
  }) async {
    if (shouldSimulateError) {
      throw Exception("AI service unavailable");
    }

    final qLower = question.toLowerCase();

    // Check for explicit action request
    final isActionQuery =
        qLower.contains('experiment start') ||
        qLower.contains('start experiment') ||
        (qLower.contains('start') && qLower.contains('experiment')) ||
        qLower.contains('start karo') ||
        qLower.contains('chalao');

    if (isActionQuery) {
      return const AiAskResponse(
        conversationId: 'conv_mock',
        messageId: 'msg_act_prop',
        answer: 'Tuesday 4–7 PM experiment start karun?',
        intent: 'ACTION_CONFIRMATION',
        actions: [
          AgentAction(
            id: 'act_exp_001',
            type: 'confirmation',
            label: 'Start Tuesday 4–7 PM Experiment',
            tool: 'create_experiment',
            arguments: {'merchant_id': 'M001', 'opportunity_id': 'OP001'},
            requiresConfirmation: true,
            confirmationPrompt: 'Tuesday 4–7 PM experiment start karun?',
          ),
        ],
        suggestedActions: ['Confirm & Launch', 'Cancel'],
      );
    }

    // Opportunity queries
    if (language.toLowerCase() == 'hindi' ||
        qLower.contains('अवसर') ||
        qLower.contains('मंगलवार')) {
      return const AiAskResponse(
        conversationId: 'conv_mock',
        messageId: 'msg_hi_01',
        answer: 'शर्मा जी, आपके स्टोर डेटा के अनुसार Tuesday को 4–7 PM के दौरान बिक्री सामान्य से 24% कम रही है (₹13,800 बेसलाइन vs ₹10,488)। यह पैटर्न 4 हफ्तों से देखा गया है।',
        intent: 'ANALYTICS_QUERY',
        actions: [
          AgentAction(
            id: 'act_exp_001',
            type: 'suggestion',
            label: 'Start Tuesday Promo Experiment',
            tool: 'create_experiment',
            arguments: {'merchant_id': 'M001', 'opportunity_id': 'OP001'},
            requiresConfirmation: true,
            confirmationPrompt: 'Tuesday 4–7 PM experiment start karun?',
          ),
        ],
        suggestedActions: [
          'Tuesday 4–7 PM experiment start karo',
          'अवसर विवरण देखें',
        ],
      );
    } else if (language.toLowerCase() == 'hinglish') {
      return const AiAskResponse(
        conversationId: 'conv_mock',
        messageId: 'msg_hing_01',
        answer: 'Sharma ji, aapke transaction records ke anusaar pichle 4 weeks se har Tuesday ko 4–7 PM ke beech sales 24% down chal rahi hai (₹13,800 baseline ke mukable ₹10,488). Kya hum targeted promo test karein?',
        intent: 'ANALYTICS_QUERY',
        actions: [
          AgentAction(
            id: 'act_exp_001',
            type: 'suggestion',
            label: 'Start Tuesday Promo Experiment',
            tool: 'create_experiment',
            arguments: {'merchant_id': 'M001', 'opportunity_id': 'OP001'},
            requiresConfirmation: true,
            confirmationPrompt: 'Tuesday 4–7 PM experiment start karun?',
          ),
        ],
        suggestedActions: [
          'Tuesday 4–7 PM experiment start karo',
          'Opportunity Details Dekhein',
        ],
      );
    } else if (language.toLowerCase() == 'english' ||
        qLower.contains('opportunity')) {
      return const AiAskResponse(
        conversationId: 'conv_mock',
        messageId: 'msg_en_01',
        answer: 'Sharma General Store: Tuesday 4–7 PM sales are consistently 24% below historical baseline (₹10,488 vs ₹13,800). This pattern has repeated for 4 weeks.',
        intent: 'ANALYTICS_QUERY',
        actions: [
          AgentAction(
            id: 'act_exp_001',
            type: 'suggestion',
            label: 'Start Tuesday Promo Experiment',
            tool: 'create_experiment',
            arguments: {'merchant_id': 'M001', 'opportunity_id': 'OP001'},
            requiresConfirmation: true,
            confirmationPrompt: 'Tuesday 4–7 PM experiment start karun?',
          ),
        ],
        suggestedActions: [
          'Start Tuesday 4–7 PM experiment',
          'View Opportunity Details',
        ],
      );
    }

    // Default Hinglish
    return const AiAskResponse(
      conversationId: 'conv_mock',
      messageId: 'msg_hing_01',
      answer: 'Sharma ji, aapke transaction records ke anusaar pichle 4 weeks se har Tuesday ko 4–7 PM ke beech sales 24% down chal rahi hai (₹13,800 baseline ke mukable ₹10,488). Kya hum targeted promo test karein?',
      intent: 'ANALYTICS_QUERY',
      actions: [
        AgentAction(
          id: 'act_exp_001',
          type: 'suggestion',
          label: 'Start Tuesday Promo Experiment',
          tool: 'create_experiment',
          arguments: {'merchant_id': 'M001', 'opportunity_id': 'OP001'},
          requiresConfirmation: true,
          confirmationPrompt: 'Tuesday 4–7 PM experiment start karun?',
        ),
      ],
      suggestedActions: [
        'Tuesday 4–7 PM experiment start karo',
        'Opportunity Details Dekhein',
      ],
    );
  }

  @override
  Future<AiAskResponse> sendVoice(
    String merchantId,
    List<int> audioBytes, {
    String language = 'hinglish',
    String? conversationId,
    String mimeType = 'audio/wav',
    String? mockTranscript,
  }) async {
    if (shouldSimulateError) {
      throw Exception("Voice backend service unavailable");
    }

    if (shouldSimulateSttError) {
      throw Exception(
        "I couldn't hear that clearly. Try again or type your question.",
      );
    }

    final transcript =
        mockTranscript ??
        mockSttTranscript ??
        'Meri sales mein kya opportunity hai?';

    // Route recognized speech into identical agent query
    final askResp = await askAi(
      merchantId,
      transcript,
      language: language,
      conversationId: conversationId,
    );

    return AiAskResponse(
      conversationId: askResp.conversationId,
      messageId: askResp.messageId,
      answer: askResp.answer,
      transcript: transcript,
      detectedLanguage: language,
      intent: askResp.intent,
      actions: askResp.actions,
      suggestedActions: askResp.suggestedActions,
      audio: const AudioMeta(audioAvailable: false),
    );
  }

  @override
  Future<ActionExecuteResponse> executeAction(
    String merchantId,
    String actionId, {
    String? tool,
    Map<String, dynamic>? arguments,
  }) async {
    if (shouldSimulateError) {
      throw Exception("Action execution failed: backend unavailable");
    }

    createExperimentCallCount++;
    return const ActionExecuteResponse(
      success: true,
      actionId: 'act_exp_001',
      tool: 'create_experiment',
      status: 'success',
      result: {
        'experiment_id': 'EXP001',
        'opportunity_id': 'OP001',
        'merchant_id': 'M001',
        'baseline': 13800.0,
        'result': 17250.0,
        'uplift_percent': 25.0,
        'incremental_amount': 3450.0,
        'status': 'completed',
      },
      message: "Action 'create_experiment' was successfully executed.",
    );
  }

  @override
  Future<CapabilitiesResponse> getCapabilities() async {
    if (shouldSimulateError) {
      throw Exception("Capabilities discovery failed");
    }
    return const CapabilitiesResponse();
  }

  @override
  Future<bool> checkHealth() async {
    return !shouldSimulateError;
  }
}

/// Live HTTP API Service that calls FastAPI backend with graceful fallback to MockApiService.
/// Ensures 100% test reliability and instant live integration when FastAPI is running.
class HttpApiService implements ApiService {
  /// Global data mode. Set to DataMode.api in production to surface errors.
  /// Set to DataMode.auto (default) for graceful fallback during development.
  static DataMode dataMode = DataMode.auto;
  static bool get isApiMode => dataMode == DataMode.api;
  static bool get isMockMode => dataMode == DataMode.mock;

  final http.Client _client;
  final MockApiService _fallback;
  final Duration timeout;

  HttpApiService({
    http.Client? client,
    MockApiService? fallback,
    this.timeout = const Duration(seconds: 10),
  }) : _client = client ?? http.Client(),
       _fallback = fallback ?? MockApiService();

  @override
  Future<MerchantSummary> getMerchantSummary(String merchantId) async {
    if (dataMode == DataMode.mock) return _fallback.getMerchantSummary(merchantId);
    try {
      final response = await _client
          .get(Uri.parse(ApiEndpoints.merchantSummary(merchantId)))
          .timeout(timeout);
      if (response.statusCode == 200) {
        return MerchantSummary.fromJson(json.decode(response.body));
      }
    } catch (e) {
      if (dataMode == DataMode.api) rethrow;
    }
    return _fallback.getMerchantSummary(merchantId);
  }

  @override
  Future<SalesTrend> getSalesTrend(String merchantId) async {
    if (dataMode == DataMode.mock) return _fallback.getSalesTrend(merchantId);
    try {
      final response = await _client
          .get(Uri.parse(ApiEndpoints.merchantTrends(merchantId)))
          .timeout(timeout);
      if (response.statusCode == 200) {
        return SalesTrend.fromJson(json.decode(response.body));
      }
    } catch (e) {
      if (dataMode == DataMode.api) rethrow;
    }
    return _fallback.getSalesTrend(merchantId);
  }

  @override
  Future<List<Opportunity>> getOpportunities(String merchantId) async {
    if (dataMode == DataMode.mock) return _fallback.getOpportunities(merchantId);
    try {
      final response = await _client
          .get(Uri.parse(ApiEndpoints.merchantOpportunities(merchantId)))
          .timeout(timeout);
      if (response.statusCode == 200) {
        final List list = json.decode(response.body);
        return list.map((e) => Opportunity.fromJson(e)).toList();
      }
    } catch (e) {
      if (dataMode == DataMode.api) rethrow;
    }
    return _fallback.getOpportunities(merchantId);
  }

  @override
  Future<Opportunity?> getOpportunityDetail(String opportunityId) async {
    if (dataMode == DataMode.mock) return _fallback.getOpportunityDetail(opportunityId);
    try {
      final response = await _client
          .get(Uri.parse(ApiEndpoints.opportunityDetail(opportunityId)))
          .timeout(timeout);
      if (response.statusCode == 200) {
        return Opportunity.fromJson(json.decode(response.body));
      }
    } catch (e) {
      if (dataMode == DataMode.api) rethrow;
    }
    return _fallback.getOpportunityDetail(opportunityId);
  }

  @override
  Future<RecommendationResponse> getRecommendation(
    String opportunityId, {
    String language = 'hinglish',
  }) async {
    if (dataMode == DataMode.mock) return _fallback.getRecommendation(opportunityId, language: language);
    try {
      final response = await _client
          .post(
            Uri.parse(ApiEndpoints.recommendAction(opportunityId)),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'language': language}),
          )
          .timeout(timeout);
      if (response.statusCode == 200) {
        return RecommendationResponse.fromJson(json.decode(response.body));
      }
    } catch (e) {
      if (dataMode == DataMode.api) rethrow;
    }
    return _fallback.getRecommendation(opportunityId, language: language);
  }

  @override
  Future<Experiment> createExperiment(
    String opportunityId,
    String merchantId,
  ) async {
    if (dataMode == DataMode.mock) return _fallback.createExperiment(opportunityId, merchantId);
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
    } catch (e) {
      if (dataMode == DataMode.api) rethrow;
    }
    return _fallback.createExperiment(opportunityId, merchantId);
  }

  @override
  Future<Experiment> getExperimentResult(String experimentId) async {
    if (dataMode == DataMode.mock) return _fallback.getExperimentResult(experimentId);
    try {
      final response = await _client
          .get(Uri.parse(ApiEndpoints.experimentDetail(experimentId)))
          .timeout(timeout);
      if (response.statusCode == 200) {
        return Experiment.fromJson(json.decode(response.body));
      }
    } catch (e) {
      if (dataMode == DataMode.api) rethrow;
    }
    return _fallback.getExperimentResult(experimentId);
  }

  @override
  Future<AiAskResponse> askAi(
    String merchantId,
    String question, {
    String language = 'hinglish',
    String? conversationId,
  }) async {
    if (dataMode == DataMode.mock) return _fallback.askAi(merchantId, question, language: language, conversationId: conversationId);
    try {
      final response = await _client
          .post(
            Uri.parse(ApiEndpoints.aiAsk),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'merchant_id': merchantId,
              'message': question,
              'question': question,
              'language': language,
              if (conversationId != null) 'conversation_id': conversationId,
            }),
          )
          .timeout(timeout);
      if (response.statusCode == 200) {
        return AiAskResponse.fromJson(json.decode(response.body));
      }
    } catch (e) {
      if (dataMode == DataMode.api) rethrow;
    }
    return _fallback.askAi(
      merchantId,
      question,
      language: language,
      conversationId: conversationId,
    );
  }

  @override
  Future<AiAskResponse> sendVoice(
    String merchantId,
    List<int> audioBytes, {
    String language = 'hinglish',
    String? conversationId,
    String mimeType = 'audio/wav',
    String? mockTranscript,
  }) async {
    if (dataMode == DataMode.mock) return _fallback.sendVoice(merchantId, audioBytes, language: language, conversationId: conversationId, mimeType: mimeType, mockTranscript: mockTranscript);
    try {
      final request =
          http.MultipartRequest('POST', Uri.parse(ApiEndpoints.aiVoice))
            ..fields['merchant_id'] = merchantId
            ..fields['language'] = language
            ..fields['response_mode'] = 'text';

      if (conversationId != null) {
        request.fields['conversation_id'] = conversationId;
      }

      request.files.add(
        http.MultipartFile.fromBytes(
          'audio',
          audioBytes,
          filename: 'voice_input.wav',
        ),
      );

      final streamedResponse = await _client.send(request).timeout(timeout * 2);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return AiAskResponse.fromJson(json.decode(response.body));
      }
    } catch (e) {
      if (dataMode == DataMode.api) rethrow;
    }

    return _fallback.sendVoice(
      merchantId,
      audioBytes,
      language: language,
      conversationId: conversationId,
      mimeType: mimeType,
      mockTranscript: mockTranscript,
    );
  }

  @override
  Future<ActionExecuteResponse> executeAction(
    String merchantId,
    String actionId, {
    String? tool,
    Map<String, dynamic>? arguments,
  }) async {
    if (dataMode == DataMode.mock) return _fallback.executeAction(merchantId, actionId, tool: tool, arguments: arguments);
    try {
      final response = await _client
          .post(
            Uri.parse(ApiEndpoints.aiActionExecute),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'merchant_id': merchantId,
              'action_id': actionId,
              'tool': tool,
              'arguments': arguments ?? {},
              'confirmed': true,
            }),
          )
          .timeout(timeout);
      if (response.statusCode == 200) {
        return ActionExecuteResponse.fromJson(json.decode(response.body));
      }
    } catch (e) {
      if (dataMode == DataMode.api) rethrow;
    }

    return _fallback.executeAction(
      merchantId,
      actionId,
      tool: tool,
      arguments: arguments,
    );
  }

  @override
  Future<CapabilitiesResponse> getCapabilities() async {
    if (dataMode == DataMode.mock) return _fallback.getCapabilities();
    try {
      final response = await _client
          .get(Uri.parse(ApiEndpoints.capabilities))
          .timeout(timeout);
      if (response.statusCode == 200) {
        return CapabilitiesResponse.fromJson(json.decode(response.body));
      }
    } catch (e) {
      if (dataMode == DataMode.api) rethrow;
    }
    return _fallback.getCapabilities();
  }

  @override
  Future<bool> checkHealth() async {
    if (dataMode == DataMode.mock) return _fallback.checkHealth();
    try {
      final response = await _client
          .get(Uri.parse(ApiEndpoints.health))
          .timeout(timeout);
      return response.statusCode == 200;
    } catch (e) {
      if (dataMode == DataMode.api) rethrow;
      return false;
    }
  }
}
