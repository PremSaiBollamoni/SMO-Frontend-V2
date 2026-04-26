import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../data/api/gm_api_service.dart';
import '../../data/repository/gm_repository.dart';
import '../../domain/models/pending_routing_model.dart';

/// GM controller for managing process plan approvals
class GmController extends GetxController {
  late final GmRepository _repository;

  final pendingRoutings = <PendingRoutingModel>[].obs;
  final isLoading = false.obs;
  final isApproving = false.obs;
  final isRejecting = false.obs;

  @override
  void onInit() {
    super.onInit();
    final apiService = GmApiService(ApiClient().dio);
    _repository = GmRepository(apiService);
  }

  /// Fetch all pending process plans
  Future<void> fetchPendingRoutings() async {
    try {
      isLoading.value = true;
      final routings = await _repository.getPendingRoutings();
      pendingRoutings.value = routings;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Approve a process plan
  Future<bool> approveProcessPlan({
    required int routingId,
    required String actorEmpId,
  }) async {
    try {
      isApproving.value = true;

      final approvedBy = int.tryParse(actorEmpId) ?? 0;
      if (approvedBy <= 0) {
        throw Exception('Invalid employee ID');
      }

      final success = await _repository.approveProcessPlan(
        routingId: routingId,
        actorEmpId: actorEmpId,
        approvedBy: approvedBy,
      );

      if (success) {
        // Remove from pending list
        pendingRoutings.removeWhere((r) => r.routingId == routingId);
      }

      return success;
    } catch (e) {
      rethrow;
    } finally {
      isApproving.value = false;
    }
  }

  /// Reject a process plan
  Future<bool> rejectProcessPlan({
    required int routingId,
    required String actorEmpId,
  }) async {
    try {
      isRejecting.value = true;

      final approvedBy = int.tryParse(actorEmpId) ?? 0;
      if (approvedBy <= 0) {
        throw Exception('Invalid employee ID');
      }

      final success = await _repository.rejectProcessPlan(
        routingId: routingId,
        actorEmpId: actorEmpId,
        approvedBy: approvedBy,
      );

      if (success) {
        // Remove from pending list
        pendingRoutings.removeWhere((r) => r.routingId == routingId);
      }

      return success;
    } catch (e) {
      rethrow;
    } finally {
      isRejecting.value = false;
    }
  }
}
