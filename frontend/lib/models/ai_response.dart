class RecommendationResponse {
  final String opportunityId;
  final String title;
  final String explanation;
  final String recommendation;
  final String experimentPeriod;
  final String estimatedUpliftRange;

  RecommendationResponse({
    required this.opportunityId,
    required this.title,
    required this.explanation,
    required this.recommendation,
    required this.experimentPeriod,
    this.estimatedUpliftRange = '+15% to +30%',
  });

  factory RecommendationResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationResponse(
      opportunityId: json['opportunity_id'] ?? '',
      title: json['title'] ?? '',
      explanation: json['explanation'] ?? '',
      recommendation: json['recommendation'] ?? '',
      experimentPeriod: json['experiment_period'] ?? '',
      estimatedUpliftRange: json['estimated_uplift_range'] ?? '+15% to +30%',
    );
  }
}
