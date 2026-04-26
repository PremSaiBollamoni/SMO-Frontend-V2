import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/qr_assignment_model.dart';

class QrAssignmentApiService {
  final Dio _dio = ApiClient().dio;

  // Get process plan numbers (dropdown data)
  Future<List<String>> getProcessPlanNumbers() async {
    try {
      final response = await _dio.get('/api/supervisor/process-plans');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch process plan numbers: $e');
    }
  }

  // Get styles (dropdown data)
  Future<List<String>> getStyles() async {
    try {
      final response = await _dio.get('/api/supervisor/styles');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch styles: $e');
    }
  }

  // Get sizes (dropdown data)
  Future<List<String>> getSizes() async {
    try {
      final response = await _dio.get('/api/supervisor/sizes');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch sizes: $e');
    }
  }

  // Get GTG numbers (dropdown data)
  Future<List<String>> getGtgNumbers() async {
    try {
      final response = await _dio.get('/api/supervisor/gtg-numbers');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch GTG numbers: $e');
    }
  }

  // Get BTN numbers (dropdown data)
  Future<List<String>> getBtnNumbers() async {
    try {
      final response = await _dio.get('/api/supervisor/btn-numbers');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch BTN numbers: $e');
    }
  }

  // Get labels (dropdown data)
  Future<List<String>> getLabels() async {
    try {
      final response = await _dio.get('/api/supervisor/labels');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((e) => e.toString()).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to fetch labels: $e');
    }
  }

  // Submit QR assignment with enhanced response handling
  Future<Map<String, dynamic>> submitQrAssignment(
    QrAssignmentModel assignment,
  ) async {
    try {
      final response = await _dio.post(
        '/api/supervisor/qr-assignment',
        data: assignment.toJson(),
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
