import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/floor_insights_response.dart';
import '../models/merge_bins_request.dart';

/// Supervisor API Service - Handles all supervisor-related API calls
class SupervisorApiService {
  final Dio _dio;

  SupervisorApiService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  // ── Floor Insights ────────────────────────────────────────────────────────

  Future<FloorInsightsResponse> fetchFloorInsights() async {
    try {
      final response = await _dio.get('/api/insights/supervisor');
      if (response.statusCode == 200) {
        return FloorInsightsResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
      }
      throw Exception('Failed to fetch floor insights: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }

  // ── Merge Bins ────────────────────────────────────────────────────────────

  Future<String> mergeBins(MergeBinsRequest request) async {
    try {
      final response = await _dio.post(
        '/api/production/merge-bins',
        data: request.toJson(),
      );
      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        return data['message']?.toString() ?? 'Bins merged successfully';
      }
      throw Exception('Failed to merge bins: ${response.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
