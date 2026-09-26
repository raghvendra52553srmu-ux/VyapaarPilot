/// Sales trend data models for 7-day weekly performance.
class DailySalesPoint {
  final String label; // "Mon", "Tue", etc.
  final double sales; // e.g. 16200.0

  const DailySalesPoint({required this.label, required this.sales});

  factory DailySalesPoint.fromJson(Map<String, dynamic> json) {
    return DailySalesPoint(
      label: json['label'] ?? json['date'] ?? '',
      sales: (json['sales'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {'label': label, 'sales': sales};
}

class SalesTrend {
  final String period; // "7d"
  final List<DailySalesPoint> data;

  const SalesTrend({required this.period, required this.data});

  factory SalesTrend.fromJson(Map<String, dynamic> json) {
    final list = json['data'] as List<dynamic>? ?? json['daily_trends'] as List<dynamic>? ?? [];
    return SalesTrend(
      period: json['period'] ?? '7d',
      data: list
          .map((item) => DailySalesPoint.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'period': period,
    'data': data.map((d) => d.toJson()).toList(),
  };
}
