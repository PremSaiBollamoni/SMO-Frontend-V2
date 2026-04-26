import 'package:flutter/foundation.dart';
import 'workflow_node.dart';

/// Shared utility for building workflow nodes from operations and explicit edges.
/// Uses routing table as source of truth - no inference or heuristics.
/// 
/// Graph Architecture:
/// - Explicit edges from routing table relationships
/// - No topology inference
/// - No level assignment heuristics
/// - Direct DAG rendering from routing definitions
class WorkflowGraphBuilder {
  /// Build workflow nodes from operations and explicit edges
  /// 
  /// Parameters:
  /// - operations: List of operation maps with keys: operation_id, name, description, sequence, stage_group, operation_type
  /// - edges: List of explicit edge maps with keys: from_operation_id, to_operation_id, from_name, to_name, edge_type
  /// - routingId: The routing ID for these operations
  /// 
  /// Returns: List of WorkflowNode objects with explicit connections from routing table
  static List<WorkflowNode> buildNodes({
    required List<Map<String, dynamic>> operations,
    required List<Map<String, dynamic>> edges,
    required int routingId,
  }) {
    if (operations.isEmpty) {
      debugPrint('[WorkflowGraphBuilder] No operations provided for routing $routingId');
      return [];
    }

    debugPrint('[WorkflowGraphBuilder] Building graph for routing $routingId');
    debugPrint('[WorkflowGraphBuilder] Operations: ${operations.length}, Explicit edges: ${edges.length}');

    // Convert operations to indexed list sorted by sequence
    final ops = operations.map((op) {
      var opType = op['operation_type'];
      if (opType == null) {
        opType = 'sequential';
      } else if (opType is! String) {
        opType = opType.toString().toLowerCase();
      } else {
        opType = (opType as String).toLowerCase();
      }
      
      return {
        'operation_id': op['operation_id'] ?? 0,
        'name': op['name'] ?? 'Operation',
        'description': op['description'] ?? '',
        'sequence': op['sequence'] ?? 0,
        'stage_group': op['stage_group'] ?? 1,
        'operation_type': opType,
      };
    }).toList();

    // Sort by sequence to establish order
    ops.sort((a, b) => (a['sequence'] as int).compareTo(b['sequence'] as int));

    debugPrint('[WorkflowGraphBuilder] Operations sorted by sequence:');
    for (final op in ops) {
      debugPrint('  [${op['sequence']}] ${op['name']} (type=${op['operation_type']}, stage=${op['stage_group']})');
    }

    // Build connections from explicit edges (routing table)
    final connections = List<List<int>>.generate(ops.length, (_) => []);
    
    // Create a map of operation_id to index for quick lookup
    final opIdToIndex = <int, int>{};
    for (int i = 0; i < ops.length; i++) {
      opIdToIndex[ops[i]['operation_id'] as int] = i;
    }

    debugPrint('[WorkflowGraphBuilder] === EDGE CONSTRUCTION FROM ROUTING TABLE ===');

    // Process explicit edges from routing table
    for (final edge in edges) {
      final fromOpId = edge['from_operation_id'] as int;
      final toOpId = edge['to_operation_id'] as int;
      final fromName = edge['from_name'] as String;
      final toName = edge['to_name'] as String;
      final edgeType = edge['edge_type'] as String;

      final fromIdx = opIdToIndex[fromOpId];
      final toIdx = opIdToIndex[toOpId];

      if (fromIdx != null && toIdx != null) {
        connections[fromIdx].add(toIdx);
        debugPrint('[WorkflowGraphBuilder] ✓ EDGE: $fromName → $toName (type=$edgeType)');
      } else {
        debugPrint('[WorkflowGraphBuilder] ⚠ WARNING: Edge $fromName → $toName not found in operations');
      }
    }

    debugPrint('[WorkflowGraphBuilder] === EDGE CONSTRUCTION END ===');

    // Create WorkflowNode objects
    final nodes = List.generate(ops.length, (i) {
      final op = ops[i];
      final opType = op['operation_type'] as String;
      return WorkflowNode(
        id: '${op['operation_id']}',
        displayName: op['name'] as String,
        description: op['description'] as String,
        isMerge: opType == 'merge',
        connections: connections[i],
        sequenceIndex: i,
        operationId: op['operation_id'] as int,
        routingId: routingId,
      );
    });

    final totalEdges = connections.fold<int>(0, (sum, c) => sum + c.length);
    debugPrint('[WorkflowGraphBuilder] Graph built: ${nodes.length} nodes, $totalEdges edges');
    
    // Log all edges for verification
    debugPrint('[WorkflowGraphBuilder] Edge summary:');
    for (int i = 0; i < nodes.length; i++) {
      if (connections[i].isNotEmpty) {
        for (final targetIdx in connections[i]) {
          debugPrint('[WorkflowGraphBuilder]   ${ops[i]['name']} → ${ops[targetIdx]['name']}');
        }
      }
    }
    
    return nodes;
  }
}
