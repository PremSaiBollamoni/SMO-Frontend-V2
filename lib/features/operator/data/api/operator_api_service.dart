import '../../../../core/network/api_client.dart';

/// Operator API Service - Handles all operator-related API calls
class OperatorApiService {
  final ApiClient _apiClient;

  OperatorApiService({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  /// Start work
  Future<Map<String, dynamic>> startWork(Map<String, dynamic> body) async {
    final response = await _apiClient.dio.post(
      '/api/production/start-work',
      data: body,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Complete work
  Future<Map<String, dynamic>> completeWork(Map<String, dynamic> body) async {
    final response = await _apiClient.dio.post(
      '/api/production/complete-work',
      data: body,
    );
    return response.data as Map<String, dynamic>;
  }

  /// Get assigned tasks
  Future<List<dynamic>> getAssignedTasks(int operatorId) async {
    final response = await _apiClient.dio.get(
      '/api/production/assigned-tasks/$operatorId',
    );
    return response.data as List<dynamic>;
  }

  /// Get operator performance
  Future<Map<String, dynamic>> getOperatorPerformance(int operatorId) async {
    final response = await _apiClient.dio.get(
      '/api/production/operator-performance/$operatorId',
    );
    return response.data as Map<String, dynamic>;
  }
}
