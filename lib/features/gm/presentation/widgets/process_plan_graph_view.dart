import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/models/pending_routing_model.dart';
import '../../../process_planner/presentation/widgets/workflow_graph/horizontal_workflow_graph.dart';
import '../../../process_planner/presentation/widgets/workflow_graph/workflow_node.dart';
import '../../../process_planner/presentation/widgets/workflow_graph/workflow_graph_builder.dart';
import '../../../process_planner/presentation/widgets/node_metrics_dialog.dart';
import '../controller/gm_controller.dart';

/// Dialog to view and approve/reject process plan with graph visualization
/// Reuses the EXACT same graph component as Process Planner (readonly mode)
/// Uses shared WorkflowGraphBuilder for single source of truth
class ProcessPlanGraphView extends StatelessWidget {
  final PendingRoutingModel routing;
  final String empId;
  final GmController controller;

  const ProcessPlanGraphView({
    super.key,
    required this.routing,
    required this.empId,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    debugPrint('[GM] Opening process plan graph for routing #${routing.routingId}');
    debugPrint('[GM] Product #${routing.productId}, ${routing.operations.length} operations');
    
    // Operations are already maps from JSON, just use them directly
    final operationMaps = routing.operations.cast<Map<String, dynamic>>();

    // Edges are already maps from JSON, just use them directly
    final edgeMaps = (routing.edges ?? []).cast<Map<String, dynamic>>();
    
    // Build nodes using SHARED builder (same as Process Planner)
    final nodes = WorkflowGraphBuilder.buildNodes(
      operations: operationMaps,
      edges: edgeMaps,
      routingId: routing.routingId,
    );

    debugPrint('[GM] Graph visualization ready: ${nodes.length} nodes');

    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header - EXACT same as Process Planner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_tree_outlined, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Routing #${routing.routingId} — Product #${routing.productId}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    debugPrint('[GM] Closing graph for routing #${routing.routingId}');
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          // Graph area - REUSE EXACT same component as Process Planner
          // Readonly mode: onNodeTap is null (no interactions)
          Expanded(
            child: ClipRect(
              child: HorizontalWorkflowGraph(
                nodes: nodes,
                onNodeTap: null, // Readonly during review - no node interactions
              ),
            ),
          ),

          // Action buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.grey.shade200,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed:
                      controller.isApproving.value ||
                          controller.isRejecting.value
                      ? null
                      : () => _handleReject(context),
                  icon: const Icon(Icons.close, size: 18),
                  label: const Text('Reject'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed:
                      controller.isApproving.value ||
                          controller.isRejecting.value
                      ? null
                      : () => _handleApprove(context),
                  icon: Obx(
                    () => controller.isApproving.value
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check, size: 18),
                  ),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.success,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleApprove(BuildContext context) async {
    debugPrint('[GM] Approve button clicked for routing #${routing.routingId}');
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Process Plan'),
        content: Text(
          'Are you sure you want to approve Routing #${routing.routingId}?\n\n'
          'This will activate the process plan and make it available for production.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('[GM] Approve cancelled for routing #${routing.routingId}');
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              debugPrint('[GM] Approve confirmed for routing #${routing.routingId}');
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.success),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        debugPrint('[GM] Sending approve request for routing #${routing.routingId}');
        final success = await controller.approveProcessPlan(
          routingId: routing.routingId,
          actorEmpId: empId,
        );

        if (success && context.mounted) {
          debugPrint('[GM] Approve successful for routing #${routing.routingId}');
          Navigator.pop(context);
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
        debugPrint('[GM] Approve failed for routing #${routing.routingId}: $e');
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

  Future<void> _handleReject(BuildContext context) async {
    debugPrint('[GM] Reject button clicked for routing #${routing.routingId}');
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Process Plan'),
        content: Text(
          'Are you sure you want to reject Routing #${routing.routingId}?\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('[GM] Reject cancelled for routing #${routing.routingId}');
              Navigator.pop(context, false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              debugPrint('[GM] Reject confirmed for routing #${routing.routingId}');
              Navigator.pop(context, true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        debugPrint('[GM] Sending reject request for routing #${routing.routingId}');
        final success = await controller.rejectProcessPlan(
          routingId: routing.routingId,
          actorEmpId: empId,
        );

        if (success && context.mounted) {
          debugPrint('[GM] Reject successful for routing #${routing.routingId}');
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Process plan #${routing.routingId} rejected'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } catch (e) {
        debugPrint('[GM] Reject failed for routing #${routing.routingId}: $e');
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
