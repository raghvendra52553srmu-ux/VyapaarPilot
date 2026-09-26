/// Centralized API constants ready for Phase 2 FastAPI integration.
/// In Phase 1, no backend is called.
class ApiConstants {
  ApiConstants._();

  static const String defaultBaseUrl = 'http://localhost:8000/api';

  // Merchant Endpoints
  static String merchantSummary(String merchantId) =>
      '/merchants/$merchantId/summary';
  static String merchantTrends(String merchantId) =>
      '/merchants/$merchantId/trends';
  static String merchantOpportunities(String merchantId) =>
      '/merchants/$merchantId/opportunities';

  // Opportunity Endpoints
  static String opportunityDetail(String opportunityId) =>
      '/opportunities/$opportunityId';
  static String recommendAction(String opportunityId) =>
      '/opportunities/$opportunityId/recommend';

  // Experiment Endpoints
  static const String experiments = '/experiments';
  static String experimentDetail(String experimentId) =>
      '/experiments/$experimentId';

  // AI Endpoint
  static const String aiAsk = '/ai/ask';
}
