import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../data/repository/supervisor_repository.dart';
import '../../domain/models/floor_insights_model.dart';

/// Supervisor Controller - Manages supervisor workspace state
class SupervisorController extends GetxController {
  final SupervisorRepository _repository;

  SupervisorController({SupervisorRepository? repository})
    : _repository = repository ?? SupervisorRepository();

  // Observable state
  final isLoading = false.obs;
  final employeeName = ''.obs;
  final empId = ''.obs;
  final role = ''.obs;

  // Floor insights
  final Rx<FloorInsightsModel?> floorInsights = Rx<FloorInsightsModel?>(null);
  final loadingInsights = false.obs;

  // Merge bins
  final targetBundleController = TextEditingController();
  final sourceBundleController = TextEditingController();
  final mergingBins = false.obs;

  /// Initialize controller
  void initialize(String employeeId, String employeeName, String userRole) {
    empId.value = employeeId;
    this.employeeName.value = employeeName;
    role.value = userRole;
  }

  @override
  void onClose() {
    targetBundleController.dispose();
    sourceBundleController.dispose();
    super.onClose();
  }

  // ── Floor Insights ────────────────────────────────────────────────────────

  Future<void> fetchFloorInsights() async {
    try {
      loadingInsights.value = true;
      final insights = await _repository.getFloorInsights();
      floorInsights.value = insights;
    } catch (e) {
      debugPrint('Error fetching floor insights: $e');
      // Set default values instead of throwing
      floorInsights.value = null;
    } finally {
      loadingInsights.value = false;
    }
  }

  // ── Merge Bins ────────────────────────────────────────────────────────────

  Future<String> mergeBins() async {
    final targetId = int.tryParse(targetBundleController.text.trim());
    final sourceId = int.tryParse(sourceBundleController.text.trim());

    if (targetId == null || sourceId == null) {
      throw Exception('Both Target and Source Bundle IDs are required');
    }

    try {
      mergingBins.value = true;
      final message = await _repository.mergeBins(
        targetBundleId: targetId,
        sourceBundleId: sourceId,
      );

      // Clear inputs on success
      targetBundleController.clear();
      sourceBundleController.clear();

      return message;
    } catch (e) {
      debugPrint('Error merging bins: $e');
      rethrow;
    } finally {
      mergingBins.value = false;
    }
  }
}
