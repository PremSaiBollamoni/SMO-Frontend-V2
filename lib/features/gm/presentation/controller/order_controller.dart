import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../../data/api/order_api_service.dart';
import '../../data/repository/order_repository.dart';
import '../../domain/models/order_model.dart';

/// Controller for order management
class OrderController extends GetxController {
  late final OrderRepository _repository;

  final orders = <OrderModel>[].obs;
  final isLoading = false.obs;
  final isCreating = false.obs;
  final isActivating = false.obs;

  @override
  void onInit() {
    super.onInit();
    final apiService = OrderApiService(ApiClient().dio);
    _repository = OrderRepository(apiService);
  }

  /// Fetch active orders
  Future<void> fetchActiveOrders(String actorEmpId) async {
    try {
      isLoading.value = true;
      final fetchedOrders = await _repository.getActiveOrders(actorEmpId);
      orders.value = fetchedOrders;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Fetch orders by status
  Future<void> fetchOrdersByStatus(String status, String actorEmpId) async {
    try {
      isLoading.value = true;
      final fetchedOrders = await _repository.getOrdersByStatus(status, actorEmpId);
      orders.value = fetchedOrders;
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  /// Get order status with progress
  Future<OrderModel?> getOrderStatus(String orderNumber, String actorEmpId) async {
    try {
      return await _repository.getOrderStatus(orderNumber, actorEmpId);
    } catch (e) {
      rethrow;
    }
  }

  /// Create new order
  Future<OrderModel?> createOrder(OrderModel order, String actorEmpId) async {
    try {
      isCreating.value = true;
      final createdOrder = await _repository.createOrder(order, actorEmpId);
      
      // Add to list if it's active
      if (createdOrder.status == 'ACTIVE') {
        orders.add(createdOrder);
      }
      
      return createdOrder;
    } catch (e) {
      rethrow;
    } finally {
      isCreating.value = false;
    }
  }

  /// Activate order
  Future<bool> activateOrder(int orderId, String actorEmpId) async {
    try {
      isActivating.value = true;
      await _repository.activateOrder(orderId, actorEmpId);
      
      // Refresh orders list
      await fetchActiveOrders(actorEmpId);
      
      return true;
    } catch (e) {
      rethrow;
    } finally {
      isActivating.value = false;
    }
  }
}
