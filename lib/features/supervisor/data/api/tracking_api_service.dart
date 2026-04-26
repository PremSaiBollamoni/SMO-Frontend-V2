import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/models/tracking_model.dart';

class TrackingApiService {
  final Dio _dio = ApiClient().dio;

  // Submit tracking data with enhanced two-phase workflow
  Future<Map<String, dynamic>> submitTracking(TrackingModel tracking) async {
    try {
      final response = await _dio.post(
        '/api/supervisor/tracking',
        data: tracking.toJson(),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': response.data};
      } else {
        return {
          'success': false,
          'message': 'Unexpected response code: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Failed to submit tracking: $e'};
    }
  }
}
