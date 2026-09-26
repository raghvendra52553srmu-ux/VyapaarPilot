class ApiEndpoints {
  ApiEndpoints._();

  static String baseUrl = 'http://localhost:8000/api';

  static String merchantSummary(String merchantId) =>
      '$baseUrl/merchants/$merchantId/summary';
  static String merchantTrends(String merchantId) =>
      '$baseUrl/merchants/$merchantId/trends';
  static String merchantOpportunities(String merchantId) =>
      '$baseUrl/merchants/$merchantId/opportunities';

  static String opportunityDetail(String opportunityId) =>
      '$baseUrl/opportunities/$opportunityId';
  static String recommendAction(String opportunityId) =>
      '$baseUrl/opportunities/$opportunityId/recommend';

  static String get experiments => '$baseUrl/experiments';
  static String experimentDetail(String experimentId) =>
      '$baseUrl/experiments/$experimentId';

  static String get aiAsk => '$baseUrl/ai/ask';
  static String get aiVoice => '$baseUrl/ai/voice';
  static String get aiActionExecute => '$baseUrl/ai/action/execute';
  static String get capabilities => '$baseUrl/capabilities';
  static String get health => '$baseUrl/health';
}
