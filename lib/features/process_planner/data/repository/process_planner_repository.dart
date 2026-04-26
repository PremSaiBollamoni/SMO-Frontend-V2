import '../api/process_planner_api_service.dart';
import '../models/create_product_request.dart';
import '../models/create_operation_request.dart';
import '../models/create_routing_request.dart';
import '../models/create_routing_step_request.dart';
import '../../domain/models/product_model.dart';
import '../../domain/models/operation_model.dart';
import '../../domain/models/routing_model.dart';
import '../../domain/models/routing_step_model.dart';

/// Process Planner Repository - Business logic and data access
class ProcessPlannerRepository {
  final ProcessPlannerApiService _apiService;

  ProcessPlannerRepository({ProcessPlannerApiService? apiService})
    : _apiService = apiService ?? ProcessPlannerApiService();

  // ── Products ──────────────────────────────────────────────────────────────

  Future<List<ProductModel>> getProducts() async {
    return await _apiService.fetchProducts();
  }

  Future<void> createProduct({
    required int productId,
    required String name,
    required String category,
    required String status,
  }) async {
    final request = CreateProductRequest(
      productId: productId,
      name: name,
      category: category,
      status: status,
    );
    return await _apiService.createProduct(request);
  }

  Future<void> deleteProduct(int productId) async {
    return await _apiService.deleteProduct(productId);
  }

  // ── Operations ────────────────────────────────────────────────────────────

  Future<List<OperationModel>> getOperations() async {
    return await _apiService.fetchOperations();
  }

  Future<void> createOperation({
    required int operationId,
    required String name,
    required int sequence,
    required int standardTime,
    required bool isParallel,
    required bool mergePoint,
  }) async {
    final request = CreateOperationRequest(
      operationId: operationId,
      name: name,
      sequence: sequence,
      standardTime: standardTime,
      isParallel: isParallel,
      mergePoint: mergePoint,
    );
    return await _apiService.createOperation(request);
  }

  Future<void> deleteOperation(int operationId) async {
    return await _apiService.deleteOperation(operationId);
  }

  // ── Routings ──────────────────────────────────────────────────────────────

  Future<List<RoutingModel>> getRoutings() async {
    return await _apiService.fetchRoutings();
  }

  Future<void> createRouting({
    required int routingId,
    required int productId,
    required int version,
    required String status,
    required String approvalStatus,
  }) async {
    final request = CreateRoutingRequest(
      routingId: routingId,
      productId: productId,
      version: version,
      status: status,
      approvalStatus: approvalStatus,
    );
    return await _apiService.createRouting(request);
  }

  Future<void> deleteRouting(int routingId) async {
    return await _apiService.deleteRouting(routingId);
  }

  // ── Routing Steps ─────────────────────────────────────────────────────────

  Future<List<RoutingStepModel>> getRoutingSteps(int routingId) async {
    return await _apiService.fetchRoutingSteps(routingId);
  }

  Future<void> createRoutingStep({
    required int routingStepId,
    required int routingId,
    required int operationId,
    required int stageGroup,
  }) async {
    final request = CreateRoutingStepRequest(
      routingStepId: routingStepId,
      routingId: routingId,
      operationId: operationId,
      stageGroup: stageGroup,
    );
    return await _apiService.createRoutingStep(request);
  }

  Future<void> deleteRoutingStep(int routingStepId) async {
    return await _apiService.deleteRoutingStep(routingStepId);
  }

  // ── Process Plan Draft ────────────────────────────────────────────────────

  Future<Map<String, dynamic>> submitProcessPlanDraft({
    required int productId,
    required List<Map<String, dynamic>> steps,
  }) async {
    return await _apiService.submitProcessPlanDraft(productId, steps);
  }
}
