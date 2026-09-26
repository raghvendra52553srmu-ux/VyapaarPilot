/// Merchant summary model for top-level financial metrics and store details.
class MerchantSummary {
  final String merchantId;
  final String merchantName;
  final String city;
  final String businessType;
  final double todaySales;
  final double salesChangePercent;
  final int transactionCount;
  final double averageTransaction;
  final String currency;

  const MerchantSummary({
    required this.merchantId,
    required this.merchantName,
    this.city = 'Lucknow',
    this.businessType = 'Retail',
    required this.todaySales,
    required this.salesChangePercent,
    required this.transactionCount,
    required this.averageTransaction,
    this.currency = 'INR',
  });

  factory MerchantSummary.fromJson(Map<String, dynamic> json) {
    return MerchantSummary(
      merchantId: json['merchant_id'] ?? '',
      merchantName: json['merchant_name'] ?? 'Sharma General Store',
      city: json['city'] ?? 'Lucknow',
      businessType: json['business_type'] ?? json['category'] ?? 'Retail',
      todaySales: (json['today_sales'] ?? 0.0).toDouble(),
      salesChangePercent: (json['sales_change_percent'] ?? 0.0).toDouble(),
      transactionCount: json['transaction_count'] ?? 0,
      averageTransaction: (json['average_transaction'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'INR',
    );
  }

  Map<String, dynamic> toJson() => {
    'merchant_id': merchantId,
    'merchant_name': merchantName,
    'city': city,
    'business_type': businessType,
    'today_sales': todaySales,
    'sales_change_percent': salesChangePercent,
    'transaction_count': transactionCount,
    'average_transaction': averageTransaction,
    'currency': currency,
  };
}
