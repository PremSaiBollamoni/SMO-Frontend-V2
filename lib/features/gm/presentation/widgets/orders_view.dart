import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../domain/models/order_model.dart';
import '../controller/order_controller.dart';
import 'order_summary_card.dart';
import 'create_order_dialog.dart';
import 'strategic_monitor_modal.dart';
import '../../../process_planner/presentation/widgets/workflow_graph/workflow_node.dart';
import '../../../../core/network/api_client.dart';

/// Orders list view for GM workspace
class OrdersView extends StatefulWidget {
  final String empId;

  const OrdersView({super.key, required this.empId});

  @override
  State<OrdersView> createState() => _OrdersViewState();
}

class _OrdersViewState extends State<OrdersView> {
  String _selectedStatus = 'ACTIVE';
  
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrderController());
    
    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.orders.isEmpty) {
        if (_selectedStatus == 'ACTIVE') {
          controller.fetchActiveOrders(widget.empId);
        } else {
          controller.fetchOrdersByStatus(_selectedStatus, widget.empId);
        }
      }
    });
    
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(controller),
          _buildStatusFilter(controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.orders.isEmpty) {
                return _buildEmptyState();
              }
              
              return RefreshIndicator(
                onRefresh: () => _refreshOrders(controller),
                child: ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 16),
                  itemCount: controller.orders.length,
                  itemBuilder: (context, index) {
                    final order = controller.orders[index];
                    return OrderSummaryCard(
                      order: order,
                      onTap: () => _viewOrderDetails(order),
                      onActivate: order.status == 'DRAFT' 
                          ? () => _activateOrder(controller, order)
                          : null,
                      onViewDetails: () => _viewOrderDetails(order),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOrderDialog(controller),
        icon: const Icon(Icons.add),
        label: const Text('New Order'),
      ),
    );
  }

  Widget _buildHeader(OrderController controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.grey[900]
            : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Production Orders',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Obx(() => Text(
                '${controller.orders.length} orders',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              )),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshOrders(controller),
            tooltip: 'Refresh',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(OrderController controller) {
    final statuses = ['ACTIVE', 'DRAFT', 'COMPLETED', 'ON_HOLD'];
    
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = _selectedStatus == status;
          
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(status),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedStatus = status);
                  if (status == 'ACTIVE') {
                    controller.fetchActiveOrders(widget.empId);
                  } else {
                    controller.fetchOrdersByStatus(status, widget.empId);
                  }
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No $_selectedStatus orders',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create a new order to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshOrders(OrderController controller) async {
    if (_selectedStatus == 'ACTIVE') {
      await controller.fetchActiveOrders(widget.empId);
    } else {
      await controller.fetchOrdersByStatus(_selectedStatus, widget.empId);
    }
  }

  void _showCreateOrderDialog(OrderController controller) {
    showDialog(
      context: context,
      builder: (context) => CreateOrderDialog(
        empId: widget.empId,
        onOrderCreated: () {
          _refreshOrders(controller);
        },
      ),
    );
  }

  void _activateOrder(OrderController controller, OrderModel order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Activate Order'),
        content: Text(
          'Activate order ${order.orderNumber}?\n\n'
          'This will start production tracking for this order.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Activate'),
          ),
        ],
      ),
    );
    
    if (confirmed == true && order.orderId != null) {
      try {
        await controller.activateOrder(order.orderId!, widget.empId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Order ${order.orderNumber} activated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to activate order: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _viewOrderDetails(OrderModel order) async {
    // Fetch latest order status with progress
    try {
      final controller = Get.find<OrderController>();
      final orderStatus = await controller.getOrderStatus(order.orderNumber, widget.empId);
      
      if (orderStatus != null && mounted) {
        // Fetch graph nodes for this routing
        final response = await ApiClient().dio.get(
          '/api/process-plans/${order.routingId}/graph',
          queryParameters: {'actorEmpId': widget.empId},
        );
        
        if (response.statusCode == 200 && response.data != null) {
          final nodes = (response.data['nodes'] as List)
              .map((n) => WorkflowNode(
                    id: n['id']?.toString() ?? '',
                    displayName: n['displayName'] ?? '',
                    description: n['description'] ?? '',
                    isMerge: n['isMerge'] ?? false,
                    connections: (n['connections'] as List?)?.cast<int>() ?? [],
                    sequenceIndex: n['sequenceIndex'] ?? 0,
                    operationId: n['operationId'] ?? 0,
                    routingId: n['routingId'] ?? 0,
                  ))
              .toList();
          
          if (mounted) {
            showDialog(
              context: context,
              builder: (context) => StrategicMonitorModal(
                empId: widget.empId,
                nodes: nodes,
                routingId: order.routingId,
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load order details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
