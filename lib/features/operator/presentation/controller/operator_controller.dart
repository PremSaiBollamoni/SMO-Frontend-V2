import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/repository/operator_repository.dart';
import '../../domain/models/task_model.dart';
import '../../domain/models/performance_model.dart';

/// Operator Controller - Manages operator workspace state
class OperatorController extends GetxController {
  final OperatorRepository _repository;

  OperatorController({OperatorRepository? repository})
    : _repository = repository ?? OperatorRepository();

  // Observable state
  final isLoading = false.obs;
  final employeeName = ''.obs;
  final empId = ''.obs;
  final role = ''.obs;

  // Tasks
  final tasks = <TaskModel>[].obs;
  final loadingTasks = false.obs;

  // Performance
  final performance = Rx<PerformanceModel?>(null);
  final loadingPerformance = false.obs;

  /// Initialize controller
  void initialize(String employeeId, String employeeName, String role) {
    empId.value = employeeId;
    this.employeeName.value = employeeName;
    this.role.value = role;
  }

  /// Start work
  Future<bool> startWork({
    String? trayQr,
    required int bundleId,
    required int operationId,
    required int machineId,
    int? qty,
  }) async {
    final operatorId = int.tryParse(empId.value);
    if (operatorId == null) return false;

    try {
      isLoading.value = true;
      await _repository.startWork(
        trayQr: trayQr,
        bundleId: bundleId,
        operationId: operationId,
        operatorId: operatorId,
        machineId: machineId,
        qty: qty,
      );
      await fetchTasks();
      await fetchPerformance();
      return true;
    } catch (e) {
      debugPrint('Error starting work: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Complete work
  Future<bool> completeWork({
    String? trayQr,
    required int bundleId,
    required int operationId,
    required int machineId,
    int? qty,
  }) async {
    final operatorId = int.tryParse(empId.value);
    if (operatorId == null) return false;

    try {
      isLoading.value = true;
      await _repository.completeWork(
        trayQr: trayQr,
        bundleId: bundleId,
        operationId: operationId,
        operatorId: operatorId,
        machineId: machineId,
        qty: qty,
      );
      await fetchTasks();
      await fetchPerformance();
      return true;
    } catch (e) {
      debugPrint('Error completing work: $e');
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch assigned tasks
  Future<void> fetchTasks() async {
    final operatorId = int.tryParse(empId.value);
    if (operatorId == null) return;

    try {
      loadingTasks.value = true;
      final data = await _repository.getAssignedTasks(operatorId);
      tasks.value = data;
    } catch (e) {
      debugPrint('Error fetching tasks: $e');
      rethrow;
    } finally {
      loadingTasks.value = false;
    }
  }

  /// Fetch operator performance
  Future<void> fetchPerformance() async {
    final operatorId = int.tryParse(empId.value);
    if (operatorId == null) return;

    try {
      loadingPerformance.value = true;
      final data = await _repository.getOperatorPerformance(operatorId);
      performance.value = data;
    } catch (e) {
      debugPrint('Error fetching performance: $e');
      rethrow;
    } finally {
      loadingPerformance.value = false;
    }
  }
}
