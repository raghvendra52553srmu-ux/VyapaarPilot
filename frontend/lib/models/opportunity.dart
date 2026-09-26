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

  Opportunity({
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
  });

  factory Opportunity.fromJson(Map<String, dynamic> json) {
    return Opportunity(
      opportunityId: json['opportunity_id'] ?? json['id'] ?? '',
      merchantId: json['merchant_id'] ?? '',
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      day: json['day'] ?? '',
      period: json['period'] ?? '',
      declinePercent: (json['decline_percent'] ?? 0.0).toDouble(),
      baseline: (json['baseline'] ?? 0.0).toDouble(),
      current: (json['current'] ?? 0.0).toDouble(),
      weeksObserved: json['weeks_observed'] ?? 4,
    );
  }
}
