import 'package:dio/dio.dart';
import '../../domain/models/pending_routing_model.dart';

/// GM API service for process plan approvals
class GmApiService {
  final Dio _dio;

  GmApiService(this._dio);

  /// Fetch all pending process plans (routings with UNDER_REVIEW status)
  Future<List<PendingRoutingModel>> fetchPendingRoutings() async {
    try {
      final empId = _dio.options.headers['X-Employee-ID'] ?? 'SYSTEM';
      final response = await _dio.get(
        '/api/processplan/pending',
        queryParameters: {'actorEmpId': empId},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data as List<dynamic>;

        final pendingRoutings = data
            .map(
              (json) =>
                  PendingRoutingModel.fromJson(json as Map<String, dynamic>),
            )
            .toList();

        return pendingRoutings;
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to fetch pending routings',
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Approve a process plan
  Future<bool> approveProcessPlan({
    required int routingId,
    required String actorEmpId,
    required int approvedBy,
  }) async {
    try {
      final response = await _dio.post(
        '/api/processplan/$routingId/approve',
        queryParameters: {'actorEmpId': actorEmpId, 'approvedBy': approvedBy},
      );

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  /// Reject a process plan
  Future<bool> rejectProcessPlan({
    required int routingId,
    required String actorEmpId,
    required int approvedBy,
  }) async {
    try {
      final response = await _dio.post(
        '/api/processplan/$routingId/reject',
        queryParameters: {'actorEmpId': actorEmpId, 'approvedBy': approvedBy},
      );

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}
