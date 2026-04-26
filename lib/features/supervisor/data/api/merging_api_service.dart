import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/merging_model.dart';

class MergingApiService {
  final Dio _dio = ApiClient().dio;

  // Submit merging data with enhanced response handling
  Future<Map<String, dynamic>> submitMerging(MergingModel merging) async {
    try {
      final response = await _dio.post(
        '/api/supervisor/merging',
        data: merging.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Return the full response data for enhanced error handling
        return response.data as Map<String, dynamic>;
      } else {
        return {
          'success': false,
          'message': 'Server returned status: ${response.statusCode}',
          'errorType': 'HTTP_ERROR',
        };
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        // Try to extract error details from server response
        try {
          final errorData = e.response!.data as Map<String, dynamic>;
          return {
            'success': false,
            'message': errorData['message'] ?? 'Server error occurred',
            'errorType': errorData['errorType'] ?? 'SERVER_ERROR',
          };
        } catch (_) {
          return {
            'success': false,
            'message': 'Server error: ${e.response!.statusCode}',
            'errorType': 'SERVER_ERROR',
          };
        }
      }

      return {
        'success': false,
        'message': 'Network error: $e',
        'errorType': 'NETWORK_ERROR',
      };
    }
  }
}
