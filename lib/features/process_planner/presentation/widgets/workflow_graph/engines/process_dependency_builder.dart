import 'package:flutter/foundation.dart';
import '../workflow_node.dart';

/// Builds process dependency structures from WorkflowNode lists.
/// Provides adjacency list, reverse adjacency, indegree calculation,
/// and cycle detection for DAG construction.
class ProcessDependencyBuilder {
  /// Build adjacency list representation of the process graph
  static Map<String, List<String>> buildAdjacencyList(
    List<WorkflowNode> nodes,
  ) {
    final adjacencyList = <String, List<String>>{};

    // Initialize adjacency list
    for (var node in nodes) {
      if (node.id.isNotEmpty) {
        adjacencyList[node.id] = [];
      }
    }

    // Build connections with null safety and bounds checking
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node.id.isEmpty) {
        debugPrint('Warning: Node at index $i has empty ID');
        continue;
      }

      for (var connIndex in node.connections) {
        if (connIndex >= 0 && connIndex < nodes.length) {
          final targetNode = nodes[connIndex];
          if (targetNode.id.isNotEmpty) {
            adjacencyList[node.id]?.add(targetNode.id);
          } else {
            debugPrint('Warning: Target node at index $connIndex has empty ID');
          }
        } else {
          debugPrint(
            'Warning: Invalid connection index $connIndex (nodes.length=${nodes.length})',
          );
        }
      }
    }

    return adjacencyList;
  }

  /// Build reverse adjacency list (dependencies -> dependents)
  static Map<String, List<String>> buildReverseAdjacencyList(
    List<WorkflowNode> nodes,
  ) {
    final reverseAdjList = <String, List<String>>{};

    // Initialize reverse adjacency list
    for (var node in nodes) {
      if (node.id.isNotEmpty) {
        reverseAdjList[node.id] = [];
      }
    }

    // Build reverse connections
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node.id.isEmpty) continue;

      for (var connIndex in node.connections) {
        if (connIndex >= 0 && connIndex < nodes.length) {
          final targetNode = nodes[connIndex];
          if (targetNode.id.isNotEmpty) {
            reverseAdjList[targetNode.id]?.add(node.id);
          }
        }
      }
    }

    return reverseAdjList;
  }

  /// Calculate indegree for each node (number of incoming connections)
  static Map<String, int> calculateIndegrees(List<WorkflowNode> nodes) {
    final indegrees = <String, int>{};

    // Initialize indegrees
    for (var node in nodes) {
      if (node.id.isNotEmpty) {
        indegrees[node.id] = 0;
      }
    }

    // Count incoming connections
    for (int i = 0; i < nodes.length; i++) {
      final node = nodes[i];
      if (node.id.isEmpty) continue;

      for (var connIndex in node.connections) {
        if (connIndex >= 0 && connIndex < nodes.length) {
          final targetNode = nodes[connIndex];
          if (targetNode.id.isNotEmpty) {
            indegrees[targetNode.id] = (indegrees[targetNode.id] ?? 0) + 1;
          }
        }
      }
    }

    return indegrees;
  }

  /// Validate DAG structure (detect cycles)
  static bool isValidDAG(List<WorkflowNode> nodes) {
    final adjacencyList = buildAdjacencyList(nodes);
    final visited = <String, bool>{};
    final recursionStack = <String, bool>{};

    // Initialize visited and recursion stack
    for (var nodeId in adjacencyList.keys) {
      visited[nodeId] = false;
      recursionStack[nodeId] = false;
    }

    // Check for cycles using DFS
    for (var nodeId in adjacencyList.keys) {
      if (!visited[nodeId]! &&
          _hasCycleDFS(nodeId, adjacencyList, visited, recursionStack)) {
        return false; // Cycle detected
      }
    }

    return true; // Valid DAG
  }

  /// DFS helper for cycle detection
  static bool _hasCycleDFS(
    String nodeId,
    Map<String, List<String>> adjacencyList,
    Map<String, bool> visited,
    Map<String, bool> recursionStack,
  ) {
    visited[nodeId] = true;
    recursionStack[nodeId] = true;

    for (var neighbor in adjacencyList[nodeId] ?? []) {
      if (!visited[neighbor]! &&
          _hasCycleDFS(neighbor, adjacencyList, visited, recursionStack)) {
        return true;
      } else if (recursionStack[neighbor]!) {
        return true; // Back edge found - cycle detected
      }
    }

    recursionStack[nodeId] = false;
    return false;
  }
}
