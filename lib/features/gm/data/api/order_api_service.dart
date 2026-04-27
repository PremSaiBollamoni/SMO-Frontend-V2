import 'package:dio/dio.dart';
import '../../domain/models/order_model.dart';

/// API service for order management
class OrderApiService {
  final Dio _dio;

  OrderApiService(this._dio);

  /// Get all active orders
  Future<List<OrderModel>> getActiveOrders(String actorEmpId) async {
    final response = await _dio.get(
      '/api/orders/active',
      queryParameters: {'actorEmpId': actorEmpId},
    );
    
    if (response.statusCode == 200 && response.data != null) {
      return (response.data as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    }
    return [];
  }

  /// Get orders by status
  Future<List<OrderModel>> getOrdersByStatus(String status, String actorEmpId) async {
    final response = await _dio.get(
      '/api/orders',
      queryParameters: {
        'status': status,
        'actorEmpId': actorEmpId,
      },
    );
    
    if (response.statusCode == 200 && response.data != null) {
      return (response.data as List)
          .map((json) => OrderModel.fromJson(json))
          .toList();
    }
    return [];
  }

  /// Get order status with progress
  Future<OrderModel?> getOrderStatus(String orderNumber, String actorEmpId) async {
    final response = await _dio.get(
      '/api/orders/status/$orderNumber',
      queryParameters: {'actorEmpId': actorEmpId},
    );
    
    if (response.statusCode == 200 && response.data != null) {
      return OrderModel.fromJson(response.data);
    }
    return null;
  }

  /// Create new order
  Future<OrderModel> createOrder(OrderModel order, String actorEmpId) async {
    print('[ORDER_API] Creating order with data: ${order.toJson()}');
    print('[ORDER_API] Actor EmpId: $actorEmpId');
    
    final response = await _dio.post(
      '/api/orders',
      data: order.toJson(),
      queryParameters: {'actorEmpId': actorEmpId},
    );
    
    print('[ORDER_API] Response status: ${response.statusCode}');
    print('[ORDER_API] Response data: ${response.data}');
    
    if (response.statusCode == 201 && response.data != null) {
      return OrderModel.fromJson(response.data);
    }
    throw Exception('Failed to create order');
  }

  /// Activate order
  Future<Map<String, dynamic>> activateOrder(int orderId, String actorEmpId) async {
    final response = await _dio.post(
      '/api/orders/$orderId/activate',
      queryParameters: {'actorEmpId': actorEmpId},
    );
    
    if (response.statusCode == 200 && response.data != null) {
      return response.data;
    }
    throw Exception('Failed to activate order');
  }
}
