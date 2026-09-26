import '../../core/constants/api_constants.dart';
import '../../models/merchant_summary.dart';
import '../../models/opportunity.dart';
import '../../models/experiment.dart';

/// Abstract API Service contract for VyapaarPilot.
/// Prepares frontend for Phase 2 FastAPI REST integration.
/// In Phase 1, strictly uses mock/placeholder data without calling any live backend.
abstract class ApiService {
  Future<MerchantSummary> getMerchantSummary(String merchantId);
  Future<List<Opportunity>> getOpportunities(String merchantId);
  Future<Experiment> createExperiment(String opportunityId, String merchantId);
  Future<Experiment> getExperimentResult(String experimentId);
}

/// Phase 1 Mock Implementation - Completely decoupled from network & backend
class MockApiService implements ApiService {
  final String baseUrl;

  MockApiService({this.baseUrl = ApiConstants.defaultBaseUrl});

  @override
  Future<MerchantSummary> getMerchantSummary(String merchantId) async {
    return MerchantSummary(
      merchantId: merchantId,
      merchantName: 'Sharma General Store',
      todaySales: 18420.0,
      salesChangePercent: -12.0,
      transactionCount: 73,
      averageTransaction: 252.0,
      currency: 'INR',
    );
  }

  @override
  Future<List<Opportunity>> getOpportunities(String merchantId) async {
    return [
      Opportunity(
        opportunityId: 'OP001',
        merchantId: merchantId,
        type: 'slow_period',
        title: 'Tuesday evening slowdown',
        day: 'Tuesday',
        period: '16:00-19:00',
        declinePercent: 24.0,
        baseline: 13800.0,
        current: 10488.0,
        weeksObserved: 4,
      ),
    ];
  }

  @override
  Future<Experiment> createExperiment(
    String opportunityId,
    String merchantId,
  ) async {
    return Experiment(
      experimentId: 'EXP001',
      opportunityId: opportunityId,
      merchantId: merchantId,
      baseline: 13800.0,
      result: 17250.0,
      upliftPercent: 25.0,
      status: 'completed',
      isSyntheticDemo: true,
    );
  }

  @override
  Future<Experiment> getExperimentResult(String experimentId) async {
    return Experiment(
      experimentId: experimentId,
      opportunityId: 'OP001',
      merchantId: 'M001',
      baseline: 13800.0,
      result: 17250.0,
      upliftPercent: 25.0,
      status: 'completed',
      isSyntheticDemo: true,
    );
  }
}
