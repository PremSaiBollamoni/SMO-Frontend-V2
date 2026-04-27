import 'package:flutter/material.dart';
import '../../domain/models/order_model.dart';
import '../../../../core/theme/app_theme.dart';

/// Reusable order summary card widget
class OrderSummaryCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final VoidCallback? onActivate;
  final VoidCallback? onViewDetails;

  const OrderSummaryCard({
    super.key,
    required this.order,
    this.onTap,
    this.onActivate,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.orderNumber,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.productName ?? 'Product #${order.productId}',
                          style: TextStyle(
                            fontSize: 14,
                            color: dark ? Colors.grey[400] : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(order.status, dark),
                ],
              ),
              
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),
              
              // Order details
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      icon: Icons.inventory_2_outlined,
                      label: 'Order Qty',
                      value: '${order.orderQty}',
                      dark: dark,
                    ),
                  ),
                  if (order.completed != null)
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.check_circle_outline,
                        label: 'Completed',
                        value: '${order.completed}',
                        dark: dark,
                      ),
                    ),
                  if (order.pending != null)
                    Expanded(
                      child: _buildInfoItem(
                        icon: Icons.pending_outlined,
                        label: 'Pending',
                        value: '${order.pending}',
                        dark: dark,
                      ),
                    ),
                ],
              ),
              
              if (order.progressPercent != null) ...[
                const SizedBox(height: 12),
                _buildProgressBar(order.progressPercent!, dark),
              ],
              
              if (order.customerName != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.business_outlined,
                      size: 16,
                      color: dark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      order.customerName!,
                      style: TextStyle(
                        fontSize: 13,
                        color: dark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              
              if (order.expectedCompletionDate != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: dark ? Colors.grey[400] : Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Expected: ${order.expectedCompletionDate}',
                      style: TextStyle(
                        fontSize: 13,
                        color: dark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              
              // Action buttons
              if (onActivate != null || onViewDetails != null) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onViewDetails != null)
                      TextButton.icon(
                        onPressed: onViewDetails,
                        icon: const Icon(Icons.visibility_outlined, size: 18),
                        label: const Text('View Details'),
                      ),
                    if (onActivate != null && order.status == 'DRAFT') ...[
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: onActivate,
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('Activate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool dark) {
    Color color;
    switch (status.toUpperCase()) {
      case 'ACTIVE':
        color = Colors.green;
        break;
      case 'DRAFT':
        color = Colors.orange;
        break;
      case 'COMPLETED':
        color = Colors.blue;
        break;
      case 'ON_HOLD':
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    required bool dark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: dark ? Colors.grey[400] : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: dark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(double progress, bool dark) {
    Color progressColor;
    if (progress <= 30) {
      progressColor = Colors.red;
    } else if (progress <= 60) {
      progressColor = Colors.orange;
    } else if (progress <= 80) {
      progressColor = Colors.cyan;
    } else {
      progressColor = Colors.green;
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 12,
                color: dark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            Text(
              '${progress.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: progressColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress / 100,
            minHeight: 8,
            backgroundColor: dark ? Colors.white12 : Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          ),
        ),
      ],
    );
  }
}
