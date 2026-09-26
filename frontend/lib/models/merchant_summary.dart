class MerchantSummary {
  final String merchantId;
  final String merchantName;
  final double todaySales;
  final double salesChangePercent;
  final int transactionCount;
  final double averageTransaction;
  final String currency;

  MerchantSummary({
    required this.merchantId,
    required this.merchantName,
    required this.todaySales,
    required this.salesChangePercent,
    required this.transactionCount,
    required this.averageTransaction,
    this.currency = 'INR',
  });

  factory MerchantSummary.fromJson(Map<String, dynamic> json) {
    return MerchantSummary(
      merchantId: json['merchant_id'] ?? '',
      merchantName: json['merchant_name'] ?? '',
      todaySales: (json['today_sales'] ?? 0.0).toDouble(),
      salesChangePercent: (json['sales_change_percent'] ?? 0.0).toDouble(),
      transactionCount: json['transaction_count'] ?? 0,
      averageTransaction: (json['average_transaction'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'INR',
    );
  }
}
