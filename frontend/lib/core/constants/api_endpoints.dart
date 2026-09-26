class ApiEndpoints {
  ApiEndpoints._();

  static const String liveProductionUrl = 'https://vyapaarpilot.onrender.com';
  static const String defaultLocalUrl = 'http://localhost:8000';

  static String _formatBaseUrl(String url) {
    var trimmed = url.trim();
    if (trimmed.isEmpty) return '$liveProductionUrl/api';
    while (trimmed.endsWith('/')) {
      trimmed = trimmed.substring(0, trimmed.length - 1);
    }
    return trimmed.endsWith('/api') ? trimmed : '$trimmed/api';
  }

  /// Single source of truth for API Base URL.
  /// Configurable at compile-time via --dart-define=API_BASE_URL=...
  /// Defaults to the live production Render backend: https://vyapaarpilot.onrender.com/api
  static String baseUrl = _formatBaseUrl(
    const String.fromEnvironment('API_BASE_URL', defaultValue: '$liveProductionUrl/api'),
  );

  static void setBaseUrl(String url) {
    baseUrl = _formatBaseUrl(url);
  }

  // WebSocket URL for Realtime Multimodal Voice/Text
  static String get realtimeWsUrl {
    final httpUrl = baseUrl.replaceAll('/api', '');
    final wsBase = httpUrl.startsWith('https://')
        ? httpUrl.replaceFirst('https://', 'wss://')
        : httpUrl.replaceFirst('http://', 'ws://');
    return '$wsBase/api/ai/realtime';
  }

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
