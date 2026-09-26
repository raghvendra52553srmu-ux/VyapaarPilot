/// Request model for starting a synthetic experiment.
class ExperimentRequest {
  final String merchantId;
  final String opportunityId;

  const ExperimentRequest({
    required this.merchantId,
    required this.opportunityId,
  });

  Map<String, dynamic> toJson() => {
        'merchant_id': merchantId,
        'opportunity_id': opportunityId,
      };

  factory ExperimentRequest.fromJson(Map<String, dynamic> json) {
    return ExperimentRequest(
      merchantId: json['merchant_id'] ?? 'M001',
      opportunityId: json['opportunity_id'] ?? 'OP001',
    );
  }
}

/// Unified model representing the measured result of an experiment.
/// Single source of truth for baseline, outcome, uplift percentage,
/// and incremental revenue across Phase 3.
class ExperimentResult {
  final String experimentId;
  final String opportunityId;
  final String merchantId;
  final double baseline;
  final double result;
  final double upliftPercent;
  final double incrementalAmount;
  final String status;
  final bool isSynthetic;

  const ExperimentResult({
    required this.experimentId,
    required this.opportunityId,
    this.merchantId = 'M001',
    required this.baseline,
    required this.result,
    required this.upliftPercent,
    double? incrementalAmount,
    this.status = 'completed',
    this.isSynthetic = true,
  }) : incrementalAmount = incrementalAmount ?? (result - baseline);

  /// Backwards compatibility getter for Phase 1/2 widgets
  bool get isSyntheticDemo => isSynthetic;

  factory ExperimentResult.fromJson(Map<String, dynamic> json) {
    final b = (json['baseline'] ?? json['baseline_amount'] ?? 13800.0).toDouble();
    final r = (json['result'] ?? json['experiment_amount'] ?? 17250.0).toDouble();
    final u = (json['uplift_percent'] ?? 25.0).toDouble();
    final inc = json['incremental_amount'] != null
        ? (json['incremental_amount'] as num).toDouble()
        : (r - b);
    final synth = json['is_synthetic'] ?? json['is_synthetic_demo'] ?? true;

    return ExperimentResult(
      experimentId: json['experiment_id'] ?? 'EXP001',
      opportunityId: json['opportunity_id'] ?? 'OP001',
      merchantId: json['merchant_id'] ?? 'M001',
      baseline: b,
      result: r,
      upliftPercent: u,
      incrementalAmount: inc,
      status: json['status'] ?? 'completed',
      isSynthetic: synth is bool ? synth : true,
    );
  }

  Map<String, dynamic> toJson() => {
        'experiment_id': experimentId,
        'opportunity_id': opportunityId,
        'merchant_id': merchantId,
        'baseline': baseline,
        'result': result,
        'uplift_percent': upliftPercent,
        'incremental_amount': incrementalAmount,
        'status': status,
        'is_synthetic': isSynthetic,
      };
}

/// Backward compatibility typedef
typedef Experiment = ExperimentResult;
