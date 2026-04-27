import '../../domain/models/order_model.dart';
import '../api/order_api_service.dart';

/// Repository for order management
class OrderRepository {
  final OrderApiService _apiService;

  OrderRepository(this._apiService);

  Future<List<OrderModel>> getActiveOrders(String actorEmpId) async {
    return await _apiService.getActiveOrders(actorEmpId);
  }

  Future<List<OrderModel>> getOrdersByStatus(String status, String actorEmpId) async {
    return await _apiService.getOrdersByStatus(status, actorEmpId);
  }

  Future<OrderModel?> getOrderStatus(String orderNumber, String actorEmpId) async {
    return await _apiService.getOrderStatus(orderNumber, actorEmpId);
  }

  Future<OrderModel> createOrder(OrderModel order, String actorEmpId) async {
    return await _apiService.createOrder(order, actorEmpId);
  }

  Future<Map<String, dynamic>> activateOrder(int orderId, String actorEmpId) async {
    return await _apiService.activateOrder(orderId, actorEmpId);
  }
}
