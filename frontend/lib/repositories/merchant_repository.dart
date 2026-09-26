import '../models/merchant_summary.dart';
import '../models/opportunity.dart';
import '../models/sales_trend.dart';
import '../services/api/api_service.dart';

/// Data source interface for merchant intelligence and analytics.
abstract class MerchantDataSource {
  Future<MerchantSummary> getMerchantSummary(String merchantId);
  Future<SalesTrend> getSalesTrend(String merchantId);
  Future<List<Opportunity>> getOpportunities(String merchantId);
  Future<Opportunity?> getOpportunityDetail(String opportunityId);
}

/// Mock data source providing deterministic synthetic demo data.
class MockMerchantDataSource implements MerchantDataSource {
  final MockApiService _mockApiService;

  MockMerchantDataSource({MockApiService? mockApiService})
    : _mockApiService = mockApiService ?? MockApiService();

  @override
  Future<MerchantSummary> getMerchantSummary(String merchantId) {
    return _mockApiService.getMerchantSummary(merchantId);
  }

  @override
  Future<SalesTrend> getSalesTrend(String merchantId) {
    return _mockApiService.getSalesTrend(merchantId);
  }

  @override
  Future<List<Opportunity>> getOpportunities(String merchantId) {
    return _mockApiService.getOpportunities(merchantId);
  }

  @override
  Future<Opportunity?> getOpportunityDetail(String opportunityId) {
    return _mockApiService.getOpportunityDetail(opportunityId);
  }
}

/// Live HTTP data source calling FastAPI endpoints with graceful fallback.
class ApiMerchantDataSource implements MerchantDataSource {
  final HttpApiService _httpApiService;

  ApiMerchantDataSource({HttpApiService? httpApiService})
    : _httpApiService = httpApiService ?? HttpApiService();

  @override
  Future<MerchantSummary> getMerchantSummary(String merchantId) {
    return _httpApiService.getMerchantSummary(merchantId);
  }

  @override
  Future<SalesTrend> getSalesTrend(String merchantId) {
    return _httpApiService.getSalesTrend(merchantId);
  }

  @override
  Future<List<Opportunity>> getOpportunities(String merchantId) {
    return _httpApiService.getOpportunities(merchantId);
  }

  @override
  Future<Opportunity?> getOpportunityDetail(String opportunityId) {
    return _httpApiService.getOpportunityDetail(opportunityId);
  }
}

/// Abstract repository decoupling UI from whether data comes from Mock or FastAPI.
abstract class MerchantRepository {
  Future<MerchantSummary> getSummary(String merchantId);
  Future<SalesTrend> getTrend(String merchantId);
  Future<List<Opportunity>> getOpportunities(String merchantId);
  Future<Opportunity?> getOpportunity(String opportunityId);
}

/// Standard production repository implementation.
class DefaultMerchantRepository implements MerchantRepository {
  final MerchantDataSource dataSource;

  DefaultMerchantRepository({MerchantDataSource? dataSource})
    : dataSource = dataSource ?? ApiMerchantDataSource();

  @override
  Future<MerchantSummary> getSummary(String merchantId) {
    return dataSource.getMerchantSummary(merchantId);
  }

  @override
  Future<SalesTrend> getTrend(String merchantId) {
    return dataSource.getSalesTrend(merchantId);
  }

  @override
  Future<List<Opportunity>> getOpportunities(String merchantId) {
    return dataSource.getOpportunities(merchantId);
  }

  @override
  Future<Opportunity?> getOpportunity(String opportunityId) {
    return dataSource.getOpportunityDetail(opportunityId);
  }
}
