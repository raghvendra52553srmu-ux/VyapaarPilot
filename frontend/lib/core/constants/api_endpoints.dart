class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = 'http://localhost:8000/api';

  static String merchantSummary(String merchantId) => '$baseUrl/merchants/$merchantId/summary';
  static String merchantTrends(String merchantId) => '$baseUrl/merchants/$merchantId/trends';
  static String merchantOpportunities(String merchantId) => '$baseUrl/merchants/$merchantId/opportunities';

  static String opportunityDetail(String opportunityId) => '$baseUrl/opportunities/$opportunityId';
  static String recommendAction(String opportunityId) => '$baseUrl/opportunities/$opportunityId/recommend';

  static const String experiments = '$baseUrl/experiments';
  static String experimentDetail(String experimentId) => '$baseUrl/experiments/$experimentId';

  static const String aiAsk = '$baseUrl/ai/ask';
}
