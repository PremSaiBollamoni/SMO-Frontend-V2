import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../controller/gm_controller.dart';
import '../../domain/models/pending_routing_model.dart';
import 'process_plan_graph_view.dart';

/// Pending approvals view for GM workspace
class PendingApprovalsView extends StatelessWidget {
  final String empId;

  const PendingApprovalsView({super.key, required this.empId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(GmController());

    // Load data on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.pendingRoutings.isEmpty && !controller.isLoading.value) {
        controller.fetchPendingRoutings();
      }
    });

    return RefreshIndicator(
      onRefresh: () => controller.fetchPendingRoutings(),
      child: Obx(() {
        if (controller.isLoading.value && controller.pendingRoutings.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.pendingRoutings.isEmpty) {
          return _buildEmptyState(controller);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHeader(controller),
            const SizedBox(height: 16),
            ...controller.pendingRoutings.map((routing) {
              return _buildRoutingCard(context, routing, controller);
            }),
          ],
        );
      }),
    );
  }

  Widget _buildHeader(GmController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pending Approvals', style: AppTheme.headlineMedium),
            const SizedBox(height: 4),
            Obx(
              () => Text(
                '${controller.pendingRoutings.length} process plan(s) awaiting review',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: controller.isLoading.value
              ? null
              : controller.fetchPendingRoutings,
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh',
        ),
      ],
    );
  }

  Widget _buildEmptyState(GmController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No Pending Approvals',
            style: AppTheme.titleLarge.copyWith(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'All process plans have been reviewed',
            style: AppTheme.bodyMedium.copyWith(color: Colors.grey.shade500),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.fetchPendingRoutings,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutingCard(
    BuildContext context,
    PendingRoutingModel routing,
    GmController controller,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.warning.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'PENDING REVIEW',
                    style: TextStyle(
                      color: AppTheme.warning,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'Routing #${routing.routingId}',
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.inventory_2_outlined,
              'Product',
              routing.productName,
            ),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.tag, 'Product ID', '#${routing.productId}'),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.numbers, 'Version', 'v${routing.version}'),
            const SizedBox(height: 8),
            _buildInfoRow(
              Icons.list_alt,
              'Steps',
              '${routing.stepsCount} operation(s)',
            ),
            if (routing.createdAt != null) ...[
              const SizedBox(height: 8),
              _buildInfoRow(
                Icons.calendar_today,
                'Created',
                routing.createdAt!,
              ),
            ],
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleViewGraph(context, routing, controller),
                    icon: const Icon(Icons.account_tree, size: 18),
                    label: const Text('View Graph'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Reject button - simple X icon
                IconButton(
                  onPressed:
                      controller.isApproving.value ||
                          controller.isRejecting.value
                          ? null
                          : () => _handleReject(context, routing, controller),
                  icon: const Icon(Icons.close, size: 24),
                  color: Colors.red,
                  tooltip: 'Reject',
                ),
                const SizedBox(width: 8),
                // Approve button - simple checkmark icon
                IconButton(
                  onPressed:
                      controller.isApproving.value ||
                          controller.isRejecting.value
                          ? null
                          : () => _handleApprove(context, routing, controller),
                  icon: controller.isApproving.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.success),
                          ),
                        )
                      : const Icon(Icons.check, size: 24),
                  color: AppTheme.success,
                  tooltip: 'Approve',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  void _handleViewGraph(
    BuildContext context,
    PendingRoutingModel routing,
    GmController controller,
  ) {
    showDialog(
      context: context,
      builder: (context) => ProcessPlanGraphView(
        routing: routing,
        empId: empId,
        controller: controller,
      ),
    );
  }

  Future<void> _handleApprove(
    BuildContext context,
    PendingRoutingModel routing,
    GmController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Process Plan'),
        content: Text(
          'Are you sure you want to approve Routing #${routing.routingId} for ${routing.productName}?\n\n'
          'This will activate the process plan and make it available for production.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await controller.approveProcessPlan(
          routingId: routing.routingId,
          actorEmpId: empId,
        );

        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Process plan #${routing.routingId} approved successfully',
              ),
              backgroundColor: AppTheme.success,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to approve: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _handleReject(
    BuildContext context,
    PendingRoutingModel routing,
    GmController controller,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Process Plan'),
        content: Text(
          'Are you sure you want to reject Routing #${routing.routingId} for ${routing.productName}?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await controller.rejectProcessPlan(
          routingId: routing.routingId,
          actorEmpId: empId,
        );

        if (success && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Process plan #${routing.routingId} rejected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reject: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
