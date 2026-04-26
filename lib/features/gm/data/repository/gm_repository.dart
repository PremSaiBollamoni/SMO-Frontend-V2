import '../api/gm_api_service.dart';
import '../../domain/models/pending_routing_model.dart';

/// GM repository for process plan approvals
class GmRepository {
  final GmApiService _apiService;

  GmRepository(this._apiService);

  Future<List<PendingRoutingModel>> getPendingRoutings() async {
    return await _apiService.fetchPendingRoutings();
  }

  Future<bool> approveProcessPlan({
    required int routingId,
    required String actorEmpId,
    required int approvedBy,
  }) async {
    return await _apiService.approveProcessPlan(
      routingId: routingId,
      actorEmpId: actorEmpId,
      approvedBy: approvedBy,
    );
  }

  Future<bool> rejectProcessPlan({
    required int routingId,
    required String actorEmpId,
    required int approvedBy,
  }) async {
    return await _apiService.rejectProcessPlan(
      routingId: routingId,
      actorEmpId: actorEmpId,
      approvedBy: approvedBy,
    );
  }
}
