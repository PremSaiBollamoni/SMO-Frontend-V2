import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../process_planner/data/models/process_plan_view_model.dart';
import '../../../process_planner/presentation/widgets/workflow_graph/workflow_node.dart';
import '../../../process_planner/presentation/widgets/workflow_graph/horizontal_workflow_graph.dart';
import '../../../process_planner/presentation/widgets/workflow_graph/workflow_graph_builder.dart';
import '../../../process_planner/presentation/widgets/node_metrics_dialog.dart';

/// Supervisor workflow monitoring view - shows approved process plans with clickable nodes
/// for real-time production monitoring and floor-level insights
class WorkflowMonitoringView extends StatefulWidget {
  final String empId;

  const WorkflowMonitoringView({
    super.key,
    required this.empId,
  });

  @override
  State<WorkflowMonitoringView> createState() => _WorkflowMonitoringViewState();
}

class _WorkflowMonitoringViewState extends State<WorkflowMonitoringView> {
  bool _loading = true;
  String? _error;
  List<ProcessPlanViewModel> _plans = [];

  @override
  void initState() {
    super.initState();
    _fetchPlans();
  }

  Future<void> _fetchPlans() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await ApiClient().dio.get(
        '/api/processplan/approved',
        queryParameters: {'actorEmpId': widget.empId},
      );
      if (!mounted) return;
      final list = res.data as List<dynamic>;
      setState(() {
        _plans = list
            .map((e) => ProcessPlanViewModel.fromJson(e as Map<String, dynamic>))
            .toList();
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.response?.data?['message']?.toString() ?? 'Failed to load plans';
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load plans';
        _loading = false;
      });
    }
  }

  void _openWorkflowMonitor(ProcessPlanViewModel plan) {
    final nodes = _buildNodes(plan);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Theme.of(ctx).scaffoldBackgroundColor,
        insetPadding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: AppTheme.secondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.monitor_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Workflow Monitor - Routing #${plan.routingId}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ClipRect(
                child: HorizontalWorkflowGraph(
                  nodes: nodes,
                  onNodeTap: (routingId, operationId, operationName) {
                    showDialog(
                      context: ctx,
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
      ),
    );
  }

  List<WorkflowNode> _buildNodes(ProcessPlanViewModel plan) {
    // Use shared builder for single source of truth
    // Convert ProcessPlanViewModel operations to map format
    final operationMaps = plan.operations.map((op) {
      return {
        'operation_id': op.operationId,
        'name': op.name,
        'description': op.description,
        'sequence': op.sequence,
        'stage_group': op.stageGroup,
        'operation_type': op.operationType,
      };
    }).toList();

    // Convert edges to map format
    final edgeMaps = (plan.edges ?? []).map((edge) {
      return {
        'from_operation_id': edge.fromOperationId,
        'to_operation_id': edge.toOperationId,
        'from_name': edge.fromName,
        'to_name': edge.toName,
        'edge_type': edge.edgeType,
      };
    }).toList();

    return WorkflowGraphBuilder.buildNodes(
      operations: operationMaps,
      edges: edgeMaps,
      routingId: plan.routingId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
            const SizedBox(height: 12),
            Text(_error!, style: AppTheme.bodyMedium, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _fetchPlans,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_plans.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.monitor_outlined, size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text('No process plans to monitor', style: AppTheme.bodyLarge.copyWith(color: AppTheme.onSurfaceVariant)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchPlans,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _plans.length,
        itemBuilder: (_, i) => _WorkflowPlanCard(
          plan: _plans[i],
          dark: dark,
          onTap: () => _openWorkflowMonitor(_plans[i]),
        ),
      ),
    );
  }
}

class _WorkflowPlanCard extends StatelessWidget {
  final ProcessPlanViewModel plan;
  final bool dark;
  final VoidCallback onTap;

  const _WorkflowPlanCard({required this.plan, required this.dark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: dark ? AppTheme.darkCardDecoration : AppTheme.cardDecoration,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.monitor_outlined, color: AppTheme.secondary, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Routing #${plan.routingId}',
                      style: AppTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Product #${plan.productId} • ${plan.operations.length} operations • Click nodes for metrics',
                      style: AppTheme.bodySmall.copyWith(color: AppTheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'MONITORING',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: AppTheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}