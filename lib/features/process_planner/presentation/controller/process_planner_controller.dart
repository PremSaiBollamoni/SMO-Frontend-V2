import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/repository/process_planner_repository.dart';
import '../../domain/models/product_model.dart';
import '../../domain/models/operation_model.dart';
import '../../domain/models/routing_model.dart';
import '../../domain/models/routing_step_model.dart';

/// Process Planner Controller - Manages process planning state
class ProcessPlannerController extends GetxController {
  final ProcessPlannerRepository _repository;

  ProcessPlannerController({ProcessPlannerRepository? repository})
    : _repository = repository ?? ProcessPlannerRepository();

  // Observable state
  final isLoading = false.obs;
  final employeeName = ''.obs;
  final empId = ''.obs;

  // Products
  final products = <ProductModel>[].obs;
  final loadingProducts = false.obs;
  final selectedProductIds = <int>{}.obs;

  // Operations
  final operations = <OperationModel>[].obs;
  final loadingOperations = false.obs;
  final selectedOperationIds = <int>{}.obs;

  // Routings
  final routings = <RoutingModel>[].obs;
  final loadingRoutings = false.obs;
  final selectedRoutingIds = <int>{}.obs;

  // Routing Steps
  final routingSteps = <RoutingStepModel>[].obs;
  final loadingSteps = false.obs;
  final selectedStepIds = <int>{}.obs;

  // Excel data
  final tableHeaders = <String>[].obs;
  final tableRows = <List<dynamic>>[].obs;
  final isReadingFile = false.obs;

  /// Initialize controller
  void initialize(String employeeId, String employeeName) {
    empId.value = employeeId;
    this.employeeName.value = employeeName;
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    await Future.wait([fetchProducts(), fetchOperations(), fetchRoutings()]);
  }

  // ── Products ──────────────────────────────────────────────────────────────

  Future<void> fetchProducts() async {
    try {
      loadingProducts.value = true;
      final data = await _repository.getProducts();
      products.value = data;
    } catch (e) {
      debugPrint('Error fetching products: $e');
    } finally {
      loadingProducts.value = false;
    }
  }

  Future<bool> createProduct({
    required int productId,
    required String name,
    required String category,
    required String status,
  }) async {
    try {
      isLoading.value = true;
      await _repository.createProduct(
        productId: productId,
        name: name,
        category: category,
        status: status,
      );
      await fetchProducts();
      return true;
    } catch (e) {
      debugPrint('Error creating product: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteProduct(int productId) async {
    try {
      isLoading.value = true;
      await _repository.deleteProduct(productId);
      await fetchProducts();
      return true;
    } catch (e) {
      debugPrint('Error deleting product: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteProducts(List<int> productIds) async {
    try {
      isLoading.value = true;
      for (final id in productIds) {
        await _repository.deleteProduct(id);
      }
      clearProductSelections();
      await fetchProducts();
      return true;
    } catch (e) {
      debugPrint('Error deleting products: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void toggleProductSelection(int productId) {
    if (selectedProductIds.contains(productId)) {
      selectedProductIds.remove(productId);
    } else {
      selectedProductIds.add(productId);
    }
  }

  void clearProductSelections() {
    selectedProductIds.clear();
  }

  // ── Operations ────────────────────────────────────────────────────────────

  Future<void> fetchOperations() async {
    try {
      loadingOperations.value = true;
      final data = await _repository.getOperations();
      operations.value = data;
    } catch (e) {
      debugPrint('Error fetching operations: $e');
    } finally {
      loadingOperations.value = false;
    }
  }

  Future<bool> createOperation({
    required int operationId,
    required String name,
    required int sequence,
    required int standardTime,
    required bool isParallel,
    required bool mergePoint,
  }) async {
    try {
      isLoading.value = true;
      await _repository.createOperation(
        operationId: operationId,
        name: name,
        sequence: sequence,
        standardTime: standardTime,
        isParallel: isParallel,
        mergePoint: mergePoint,
      );
      await fetchOperations();
      return true;
    } catch (e) {
      debugPrint('Error creating operation: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteOperation(int operationId) async {
    try {
      isLoading.value = true;
      await _repository.deleteOperation(operationId);
      await fetchOperations();
      return true;
    } catch (e) {
      debugPrint('Error deleting operation: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteOperations(List<int> operationIds) async {
    try {
      isLoading.value = true;
      for (final id in operationIds) {
        await _repository.deleteOperation(id);
      }
      clearOperationSelections();
      await fetchOperations();
      return true;
    } catch (e) {
      debugPrint('Error deleting operations: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void toggleOperationSelection(int operationId) {
    if (selectedOperationIds.contains(operationId)) {
      selectedOperationIds.remove(operationId);
    } else {
      selectedOperationIds.add(operationId);
    }
  }

  void clearOperationSelections() {
    selectedOperationIds.clear();
  }

  // ── Routings ──────────────────────────────────────────────────────────────

  Future<void> fetchRoutings() async {
    try {
      loadingRoutings.value = true;
      final data = await _repository.getRoutings();
      routings.value = data;
    } catch (e) {
      debugPrint('Error fetching routings: $e');
    } finally {
      loadingRoutings.value = false;
    }
  }

  Future<bool> createRouting({
    required int routingId,
    required int productId,
    required int version,
    required String status,
    required String approvalStatus,
  }) async {
    try {
      isLoading.value = true;
      await _repository.createRouting(
        routingId: routingId,
        productId: productId,
        version: version,
        status: status,
        approvalStatus: approvalStatus,
      );
      await fetchRoutings();
      return true;
    } catch (e) {
      debugPrint('Error creating routing: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteRouting(int routingId) async {
    try {
      isLoading.value = true;
      await _repository.deleteRouting(routingId);
      await fetchRoutings();
      return true;
    } catch (e) {
      debugPrint('Error deleting routing: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteRoutings(List<int> routingIds) async {
    try {
      isLoading.value = true;
      for (final id in routingIds) {
        await _repository.deleteRouting(id);
      }
      clearRoutingSelections();
      await fetchRoutings();
      return true;
    } catch (e) {
      debugPrint('Error deleting routings: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void toggleRoutingSelection(int routingId) {
    if (selectedRoutingIds.contains(routingId)) {
      selectedRoutingIds.remove(routingId);
    } else {
      selectedRoutingIds.add(routingId);
    }
  }

  void clearRoutingSelections() {
    selectedRoutingIds.clear();
  }

  // ── Routing Steps ─────────────────────────────────────────────────────────

  Future<void> fetchRoutingSteps(int routingId) async {
    try {
      loadingSteps.value = true;
      final data = await _repository.getRoutingSteps(routingId);
      routingSteps.value = data;
    } catch (e) {
      debugPrint('Error fetching routing steps: $e');
    } finally {
      loadingSteps.value = false;
    }
  }

  Future<bool> createRoutingStep({
    required int routingStepId,
    required int routingId,
    required int operationId,
    required int stageGroup,
  }) async {
    try {
      isLoading.value = true;
      await _repository.createRoutingStep(
        routingStepId: routingStepId,
        routingId: routingId,
        operationId: operationId,
        stageGroup: stageGroup,
      );
      await fetchRoutingSteps(routingId);
      return true;
    } catch (e) {
      debugPrint('Error creating routing step: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> deleteRoutingStep(int routingStepId, int routingId) async {
    try {
      isLoading.value = true;
      await _repository.deleteRoutingStep(routingStepId);
      await fetchRoutingSteps(routingId);
      return true;
    } catch (e) {
      debugPrint('Error deleting routing step: $e');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void toggleStepSelection(int stepId) {
    if (selectedStepIds.contains(stepId)) {
      selectedStepIds.remove(stepId);
    } else {
      selectedStepIds.add(stepId);
    }
  }

  void clearStepSelections() {
    selectedStepIds.clear();
  }

  // ── Process Plan Draft ────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> submitProcessPlanDraft({
    required int productId,
    required List<Map<String, dynamic>> steps,
  }) async {
    try {
      isLoading.value = true;
      final result = await _repository.submitProcessPlanDraft(
        productId: productId,
        steps: steps,
      );
      await fetchRoutings();
      return result;
    } catch (e) {
      debugPrint('Error submitting process plan: $e');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  // ── Excel Data ────────────────────────────────────────────────────────────

  void setExcelData(List<String> headers, List<List<dynamic>> rows) {
    tableHeaders.value = headers;
    tableRows.value = rows;
  }

  void clearExcelData() {
    tableHeaders.clear();
    tableRows.clear();
  }

  void setReadingFile(bool reading) {
    isReadingFile.value = reading;
  }
}
