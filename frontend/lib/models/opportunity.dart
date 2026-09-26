/// Business Opportunity model representing detected anomalies, evidence, and recommendations.
class Opportunity {
  final String opportunityId;
  final String merchantId;
  final String type;
  final String title;
  final String day;
  final String period;
  final double declinePercent;
  final double baseline;
  final double current;
  final int weeksObserved;
  final List<String> evidence;
  final String explanation;
  final String recommendation;

  const Opportunity({
    required this.opportunityId,
    required this.merchantId,
    required this.type,
    required this.title,
    required this.day,
    required this.period,
    required this.declinePercent,
    required this.baseline,
    required this.current,
    required this.weeksObserved,
    this.evidence = const [],
    this.explanation = '',
    this.recommendation = '',
  });

  /// Difference between current and baseline
  double get difference => current - baseline;

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    final evidenceList = json['evidence'] as List<dynamic>? ?? [];
    return Opportunity(
      opportunityId: json['opportunity_id'] ?? json['id'] ?? '',
      merchantId: json['merchant_id'] ?? '',
      type: json['type'] ?? 'slow_period',
      title: json['title'] ?? '',
      day: json['day'] ?? 'Tuesday',
      period: json['period'] ?? '4 PM – 7 PM',
      declinePercent: (json['decline_percent'] ?? 0.0).toDouble(),
      baseline: (json['baseline'] ?? 0.0).toDouble(),
      current: (json['current'] ?? 0.0).toDouble(),
      weeksObserved: json['weeks_observed'] ?? 4,
      evidence: evidenceList.map((e) => e.toString()).toList(),
      explanation: json['explanation'] ?? '',
      recommendation: json['recommendation'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': opportunityId,
    'opportunity_id': opportunityId,
    'merchant_id': merchantId,
    'type': type,
    'title': title,
    'day': day,
    'period': period,
    'decline_percent': declinePercent,
    'baseline': baseline,
    'current': current,
    'weeks_observed': weeksObserved,
    'evidence': evidence,
    'explanation': explanation,
    'recommendation': recommendation,
  };
}
