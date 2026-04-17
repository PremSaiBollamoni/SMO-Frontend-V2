import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'dart:developer' as dev;
import '../config/app_config.dart';

/// Centralized Dio setup and configuration
class DioSetup {
  static Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: Duration(seconds: Timeouts.connectionTimeout),
        receiveTimeout: Duration(seconds: Timeouts.receiveTimeout),
        sendTimeout: Duration(seconds: Timeouts.sendTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add Logging Interceptor
    dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90,
        logPrint: (object) => dev.log(
          object.toString(),
          name: 'API_LOG',
        ),
      ),
    );

    // Add Actor ID Interceptor
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final empId = dio.options.headers['X-EMP-ID'];
          if (empId != null) {
            options.queryParameters[QueryParams.actorEmpId] = empId;
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          final errorMessage = _handleError(e);
          dev.log(
            'API_ERROR: $errorMessage',
            name: 'API_ERROR',
            error: e,
          );
          return handler.next(e);
        },
      ),
    );

    return dio;
  }

  static String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return "Connection timed out. Please check your internet.";
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;
        if (statusCode == 400) return "Bad Request: ${data ?? 'Invalid input'}";
        if (statusCode == 401) return "Unauthorized: Please login again.";
        if (statusCode == 403) return "Forbidden: Access denied.";
        if (statusCode == 404) return "Not Found: Server resource missing.";
        if (statusCode == 500) return "Server Error: Please try again later.";
        return "HTTP Error $statusCode: ${data ?? 'Unknown error'}";
      case DioExceptionType.cancel:
        return "Request cancelled.";
      case DioExceptionType.connectionError:
        return "No internet connection.";
      default:
        return "Something went wrong. Please try again.";
    }
  }
}
