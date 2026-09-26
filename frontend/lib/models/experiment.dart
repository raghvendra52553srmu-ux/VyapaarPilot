class Experiment {
  final String experimentId;
  final String opportunityId;
  final String merchantId;
  final double baseline;
  final double result;
  final double upliftPercent;
  final String status;
  final bool isSyntheticDemo;

  Experiment({
    required this.experimentId,
    required this.opportunityId,
    required this.merchantId,
    required this.baseline,
    required this.result,
    required this.upliftPercent,
    required this.status,
    this.isSyntheticDemo = true,
  });

  factory Experiment.fromJson(Map<String, dynamic> json) {
    return Experiment(
      experimentId: json['experiment_id'] ?? '',
      opportunityId: json['opportunity_id'] ?? '',
      merchantId: json['merchant_id'] ?? '',
      baseline: (json['baseline'] ?? 0.0).toDouble(),
      result: (json['result'] ?? 0.0).toDouble(),
      upliftPercent: (json['uplift_percent'] ?? 0.0).toDouble(),
      status: json['status'] ?? 'completed',
      isSyntheticDemo: json['is_synthetic_demo'] ?? true,
    );
  }
}
