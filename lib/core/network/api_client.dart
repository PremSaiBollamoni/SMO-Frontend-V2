import 'package:dio/dio.dart';
import 'dio_setup.dart';

/// Centralized API Client - Singleton pattern
class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  late Dio _dio;

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    _dio = DioSetup.createDio();
  }

  Dio get dio => _dio;

  /// Set employee ID for all subsequent requests
  void setEmpId(String empId) {
    _dio.options.headers['X-EMP-ID'] = empId;
  }

  /// Clear employee ID
  void clearEmpId() {
    _dio.options.headers.remove('X-EMP-ID');
  }

  /// Get current employee ID
  String? getEmpId() {
    return _dio.options.headers['X-EMP-ID'] as String?;
  }
}
