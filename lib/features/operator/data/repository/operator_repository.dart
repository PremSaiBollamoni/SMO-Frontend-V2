import '../../domain/models/task_model.dart';
import '../../domain/models/performance_model.dart';
import '../api/operator_api_service.dart';

/// Operator Repository - Business logic layer for operator operations
class OperatorRepository {
  final OperatorApiService _apiService;

  OperatorRepository({OperatorApiService? apiService})
    : _apiService = apiService ?? OperatorApiService();

  /// Start work
  Future<String> startWork({
    String? trayQr,
    required int bundleId,
    required int operationId,
    required int operatorId,
    required int machineId,
    int? qty,
  }) async {
    final body = {
      'trayQr': trayQr,
      'bundleId': bundleId,
      'operationId': operationId,
      'operatorId': operatorId,
      'machineId': machineId,
      'qty': qty,
    };

    final response = await _apiService.startWork(body);
    return response['message']?.toString() ?? 'Work started';
  }

  /// Complete work
  Future<String> completeWork({
    String? trayQr,
    required int bundleId,
    required int operationId,
    required int operatorId,
    required int machineId,
    int? qty,
  }) async {
    final body = {
      'trayQr': trayQr,
      'bundleId': bundleId,
      'operationId': operationId,
      'operatorId': operatorId,
      'machineId': machineId,
      'qty': qty,
    };

    final response = await _apiService.completeWork(body);
    return response['message']?.toString() ?? 'Work completed';
  }

  /// Get assigned tasks
  Future<List<TaskModel>> getAssignedTasks(int operatorId) async {
    final data = await _apiService.getAssignedTasks(operatorId);
    return data
        .whereType<Map>()
        .map((e) => TaskModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  /// Get operator performance
  Future<PerformanceModel?> getOperatorPerformance(int operatorId) async {
    final data = await _apiService.getOperatorPerformance(operatorId);
    return PerformanceModel.fromJson(data);
  }
}
