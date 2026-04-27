import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../process_planner/presentation/widgets/workflow_graph/horizontal_workflow_graph.dart';
import '../../../process_planner/presentation/widgets/workflow_graph/workflow_node.dart';
import '../../../process_planner/presentation/widgets/node_metrics_dialog.dart';

/// Strategic Monitoring Dashboard Modal
/// Wraps existing graph with order selector, KPI header, and progress panel
class StrategicMonitorModal extends StatefulWidget {
  final String empId;
  final List<WorkflowNode> nodes;
  final int routingId;

  const StrategicMonitorModal({
    super.key,
    required this.empId,
    required this.nodes,
    required this.routingId,
  });

  @override
  State<StrategicMonitorModal> createState() => _StrategicMonitorModalState();
}

class _StrategicMonitorModalState extends State<StrategicMonitorModal> {
  Timer? _refreshTimer;
  List<Map<String, dynamic>> _orders = [];
  Map<String, dynamic>? _selectedOrder;
  Map<String, dynamic>? _orderStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApprovedOrders();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (_selectedOrder != null) {
        _loadOrderStatus(_selectedOrder!['routing_id']);
      }
    });
  }

  Future<void> _loadApprovedOrders() async {
    try {
      final response = await ApiClient().dio.get(
        '/api/orders/active',
        queryParameters: {'actorEmpId': widget.empId},
      );

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _orders = List<Map<String, dynamic>>.from(response.data);
          if (_orders.isNotEmpty) {
            _selectedOrder = _orders.first;
            _loadOrderStatus(_selectedOrder!['order_id']);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadOrderStatus(String orderNumber) async {
    try {
      final response = await ApiClient().dio.get(
        '/api/orders/status/$orderNumber',
        queryParameters: {'actorEmpId': widget.empId},
      );

      if (response.statusCode == 200 && response.data != null) {
        setState(() {
          _orderStatus = response.data;
        });
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _onOrderChanged(Map<String, dynamic>? order) {
    if (order != null) {
      setState(() {
        _selectedOrder = order;
        _orderStatus = null;
      });
      _loadOrderStatus(order['order_id']);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Strategic Monitor',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // 1. Order Selector Bar
          _buildOrderSelector(),

          // 2. KPI Summary Header
          if (_orderStatus != null) _buildKPISummary(),

          // 3. Progress Status Strip
          if (_orderStatus != null) _buildProgressStrip(),

          // Existing Graph (unchanged)
          Expanded(
            child: ClipRect(
              child: HorizontalWorkflowGraph(
                nodes: widget.nodes,
                onNodeTap: (routingId, operationId, operationName) {
                  showDialog(
                    context: context,
                    builder: (_) => NodeMetricsDialog(
                      routingId: routingId,
                      operationId: operationId,
                      operationName: operationName,
                      empId: widget.empId,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkSurface
            : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white12
                : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          const Text(
            'Order:',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _isLoading
                ? const SizedBox(
                    height: 40,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : DropdownButton<Map<String, dynamic>>(
                    value: _selectedOrder,
                    isExpanded: true,
                    items: _orders.map((order) {
                      return DropdownMenuItem(
                        value: order,
                        child: Text(
                          '${order['order_id']} (${order['product_name']})',
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: _onOrderChanged,
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKPISummary() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final orderId = _orderStatus!['order_id'] ?? 'N/A';
    final orderQty = _orderStatus!['order_qty'] ?? 0;
    final completed = _orderStatus!['completed'] ?? 0;
    final pending = _orderStatus!['pending'] ?? 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildKPICard('Order ID', orderId.toString(), dark),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildKPICard('Order Qty', orderQty.toString(), dark),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildKPICard('Completed', completed.toString(), dark),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildKPICard('Pending', pending.toString(), dark),
          ),
        ],
      ),
    );
  }

  Widget _buildKPICard(String label, String value, bool dark) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStrip() {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final progressPercent = (_orderStatus!['progress_percent'] ?? 0.0) as num;
    final expectedDate = _orderStatus!['expected_completion_date'] ?? 'N/A';
    final avgTime = _orderStatus!['avg_time_per_unit'] ?? 'N/A';

    // Determine progress color
    Color progressColor;
    if (progressPercent <= 30) {
      progressColor = Colors.red;
    } else if (progressPercent <= 60) {
      progressColor = Colors.yellow.shade700;
    } else if (progressPercent <= 80) {
      progressColor = Colors.cyan;
    } else {
      progressColor = Colors.green;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? AppTheme.darkSurface : Colors.grey.shade50,
        border: Border(
          bottom: BorderSide(
            color: dark ? Colors.white12 : Colors.grey.shade200,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progress: ${progressPercent.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: progressColor,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Expected: $expectedDate',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.timer, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Avg: $avgTime',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progressPercent / 100,
              minHeight: 8,
              backgroundColor: dark ? Colors.white12 : Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
        ],
      ),
    );
  }
}
