// View models for displaying approved process plans.

class OperationViewModel {
  final int operationId;
  final String name;
  final String description;
  final int sequence;
  final String operationType; // NEW: enum value (sequential, parallel_branch, merge)
  final int stageGroup;

  const OperationViewModel({
    required this.operationId,
    required this.name,
    required this.description,
    required this.sequence,
    required this.operationType,
    required this.stageGroup,
  });

  factory OperationViewModel.fromJson(Map<String, dynamic> json) {
    return OperationViewModel(
      operationId: (json['operation_id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      sequence: (json['sequence'] as num?)?.toInt() ?? 0,
      operationType: json['operation_type'] as String? ?? 'sequential',
      stageGroup: (json['stage_group'] as num?)?.toInt() ?? 1,
    );
  }
}

class WorkflowEdgeViewModel {
  final int fromOperationId;
  final int toOperationId;
  final String fromName;
  final String toName;
  final String edgeType;

  const WorkflowEdgeViewModel({
    required this.fromOperationId,
    required this.toOperationId,
    required this.fromName,
    required this.toName,
    required this.edgeType,
  });

  factory WorkflowEdgeViewModel.fromJson(Map<String, dynamic> json) {
    return WorkflowEdgeViewModel(
      fromOperationId: (json['from_operation_id'] as num).toInt(),
      toOperationId: (json['to_operation_id'] as num).toInt(),
      fromName: json['from_name'] as String? ?? '',
      toName: json['to_name'] as String? ?? '',
      edgeType: json['edge_type'] as String? ?? 'sequential',
    );
  }
}

class ProcessPlanViewModel {
  final int routingId;
  final int productId;
  final String status;
  final List<OperationViewModel> operations;
  final List<WorkflowEdgeViewModel> edges; // NEW: explicit edges from routing table

  const ProcessPlanViewModel({
    required this.routingId,
    required this.productId,
    required this.status,
    required this.operations,
    required this.edges,
  });

  factory ProcessPlanViewModel.fromJson(Map<String, dynamic> json) {
    final ops = (json['operations'] as List<dynamic>? ?? [])
        .map((e) => OperationViewModel.fromJson(e as Map<String, dynamic>))
        .toList();
    final edgesList = (json['edges'] as List<dynamic>? ?? [])
        .map((e) => WorkflowEdgeViewModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return ProcessPlanViewModel(
      routingId: (json['routing_id'] as num).toInt(),
      productId: (json['product_id'] as num).toInt(),
      status: json['status'] as String? ?? '',
      operations: ops,
      edges: edgesList,
    );
  }
}
