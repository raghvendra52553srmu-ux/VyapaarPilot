import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/constants/api_endpoints.dart';
import '../models/experiment.dart';
import '../services/api/api_service.dart';

/// Data source interface for experiment creation and retrieval.
abstract class ExperimentDataSource {
  Future<ExperimentResult> createExperiment(ExperimentRequest request);
  Future<ExperimentResult> getExperimentResult(String experimentId);
}

/// Mock data source providing deterministic synthetic demo experiment outcomes.
class MockExperimentDataSource implements ExperimentDataSource {
  bool shouldFail;
  Duration delay;

  MockExperimentDataSource({
    this.shouldFail = false,
    this.delay = const Duration(milliseconds: 250),
  });

  @override
  Future<ExperimentResult> createExperiment(ExperimentRequest request) async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    if (shouldFail) {
      throw Exception("We couldn't run the experiment.");
    }
    return ExperimentResult(
      experimentId: 'EXP001',
      opportunityId: request.opportunityId,
      merchantId: request.merchantId,
      baseline: 13800.0,
      result: 17250.0,
      upliftPercent: 25.0,
      incrementalAmount: 3450.0,
      status: 'completed',
      isSynthetic: true,
    );
  }

  @override
  Future<ExperimentResult> getExperimentResult(String experimentId) async {
    if (delay > Duration.zero) {
      await Future.delayed(delay);
    }
    if (shouldFail) {
      throw Exception("Could not fetch experiment result");
    }
    return const ExperimentResult(
      experimentId: 'EXP001',
      opportunityId: 'OP001',
      merchantId: 'M001',
      baseline: 13800.0,
      result: 17250.0,
      upliftPercent: 25.0,
      incrementalAmount: 3450.0,
      status: 'completed',
      isSynthetic: true,
    );
  }
}

/// Live HTTP data source calling FastAPI endpoints with graceful fallback to demo mock data.
class ApiExperimentDataSource implements ExperimentDataSource {
  final http.Client _client;
  final Duration timeout;
  final MockExperimentDataSource? fallback;

  ApiExperimentDataSource({
    http.Client? client,
    this.timeout = const Duration(seconds: 4),
    this.fallback,
  }) : _client = client ?? http.Client();

  @override
  Future<ExperimentResult> createExperiment(ExperimentRequest request) async {
    try {
      final response = await _client
          .post(
            Uri.parse(ApiEndpoints.experiments),
            headers: {'Content-Type': 'application/json'},
            body: json.encode(request.toJson()),
          )
          .timeout(timeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ExperimentResult.fromJson(json.decode(response.body));
      }
    } catch (e) {
      if (fallback != null) {
        return fallback!.createExperiment(request);
      }
      rethrow;
    }

    if (fallback != null) {
      return fallback!.createExperiment(request);
    }
    throw Exception("Failed to create experiment");
  }

  @override
  Future<ExperimentResult> getExperimentResult(String experimentId) async {
    try {
      final response = await _client
          .get(Uri.parse(ApiEndpoints.experimentDetail(experimentId)))
          .timeout(timeout);

      if (response.statusCode == 200) {
        return ExperimentResult.fromJson(json.decode(response.body));
      }
    } catch (e) {
      if (fallback != null) {
        return fallback!.getExperimentResult(experimentId);
      }
      rethrow;
    }

    if (fallback != null) {
      return fallback!.getExperimentResult(experimentId);
    }
    throw Exception("Failed to fetch experiment");
  }
}

/// Abstract repository decoupling UI from whether data comes from Mock or FastAPI.
abstract class ExperimentRepository {
  Future<ExperimentResult> startExperiment(ExperimentRequest request);
  Future<ExperimentResult> getResult(String experimentId);
}

/// Standard production repository implementation.
class DefaultExperimentRepository implements ExperimentRepository {
  final ExperimentDataSource dataSource;

  DefaultExperimentRepository({ExperimentDataSource? dataSource})
    : dataSource =
          dataSource ??
          ApiExperimentDataSource(
            fallback:
                HttpApiService.isApiMode ? null : MockExperimentDataSource(),
          );

  @override
  Future<ExperimentResult> startExperiment(ExperimentRequest request) {
    return dataSource.createExperiment(request);
  }

  @override
  Future<ExperimentResult> getResult(String experimentId) {
    return dataSource.getExperimentResult(experimentId);
  }
}
