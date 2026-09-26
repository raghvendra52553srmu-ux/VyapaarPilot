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
    List<String> parsedEvidence = [];
    if (json['evidence'] is List) {
      parsedEvidence = (json['evidence'] as List).map((e) => e.toString()).toList();
    } else if (json['evidence'] is Map) {
      parsedEvidence = (json['evidence'] as Map).entries.map((e) => '${e.key}: ${e.value}').toList();
    }

    double decline = 0.0;
    if (json['decline_percent'] != null) {
      decline = (json['decline_percent'] as num).toDouble();
    } else if (json['change_percent'] != null) {
      decline = (json['change_percent'] as num).toDouble().abs();
    }

    String parsedPeriod = json['period'] as String? ?? '';
    if (parsedPeriod.isEmpty && json['period_start'] != null && json['period_end'] != null) {
      parsedPeriod = '${json['period_start']} – ${json['period_end']}';
    }
    if (parsedPeriod.isEmpty) {
      parsedPeriod = '4 PM – 7 PM';
    }

    return Opportunity(
      opportunityId: json['opportunity_id'] ?? json['id'] ?? '',
      merchantId: json['merchant_id'] ?? '',
      type: json['type'] ?? 'slow_period',
      title: json['title'] ?? '',
      day: json['day'] ?? json['day_of_week'] ?? 'Tuesday',
      period: parsedPeriod,
      declinePercent: decline,
      baseline: (json['baseline'] ?? json['baseline_amount'] ?? 0.0).toDouble(),
      current: (json['current'] ?? json['current_amount'] ?? 0.0).toDouble(),
      weeksObserved: json['weeks_observed'] ?? 4,
      evidence: parsedEvidence,
      explanation: json['explanation'] ?? '',
      recommendation: json['recommendation'] ?? json['recommended_action'] ?? '',
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
