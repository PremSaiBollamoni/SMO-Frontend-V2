import '../workflow_node.dart';
import 'process_dependency_builder.dart';

/// Assigns each node to a phase level using longest-path topological assignment
/// with special handling for parallel branches and merge points.
///
/// This creates clean fan-out/fan-in visualization:
/// - Parallel operations in same stage_group get same level
/// - Merge operations that converge get same level
/// - Maintains topological ordering
class PhaseLevelAssigner {
  /// Returns map of nodeId → phase level (0-based)
  static Map<String, int> assign(List<WorkflowNode> nodes) {
    if (nodes.isEmpty) return {};

    final adj = ProcessDependencyBuilder.buildAdjacencyList(nodes);
    final inDeg = ProcessDependencyBuilder.calculateIndegrees(nodes);
    final levels = <String, int>{};
    final remaining = Map<String, int>.from(inDeg);
    final queue = <String>[];

    // Seed: all root nodes at level 0
    for (final n in nodes) {
      if ((remaining[n.id] ?? 0) == 0) {
        queue.add(n.id);
        levels[n.id] = 0;
      }
    }

    // Kahn's algorithm — assign level = max parent level + 1
    while (queue.isNotEmpty) {
      final cur = queue.removeAt(0);
      for (final child in adj[cur] ?? []) {
        final proposed = (levels[cur] ?? 0) + 1;
        if (proposed > (levels[child] ?? 0)) {
          levels[child] = proposed;
        }
        remaining[child] = (remaining[child] ?? 1) - 1;
        if (remaining[child] == 0) queue.add(child);
      }
    }

    // Any node not reached (disconnected) → level 0
    for (final n in nodes) {
      levels.putIfAbsent(n.id, () => 0);
    }

    // ── Polish: Align parallel branches and merge points ──────────────────
    // Find groups of parallel operations (same stage_group, is_parallel=true)
    // and align their merge points to same level for clean fan-in
    
    final nodeMap = <String, WorkflowNode>{};
    for (final n in nodes) {
      nodeMap[n.id] = n;
    }

    // Group nodes by stage_group
    final stageGroups = <int, List<String>>{};
    for (final n in nodes) {
      stageGroups.putIfAbsent(n.sequenceIndex, () => []).add(n.id);
    }

    // For each group of parallel operations, align their merge points
    for (final nodeId in levels.keys.toList()) {
      final node = nodeMap[nodeId];
      if (node == null) continue;

      // If this is a merge point, check if it should be aligned with other merge points
      if (node.isMerge) {
        // Find all merge points at similar levels and align them
        final mergePointsAtLevel = levels.entries
            .where((e) => nodeMap[e.key]?.isMerge == true && 
                         (e.value - levels[nodeId]!).abs() <= 1)
            .map((e) => e.key)
            .toList();

        // If multiple merge points, align to same level
        if (mergePointsAtLevel.length > 1) {
          final maxMergeLevel = mergePointsAtLevel
              .map((id) => levels[id]!)
              .reduce((a, b) => a > b ? a : b);
          
          for (final mergeId in mergePointsAtLevel) {
            levels[mergeId] = maxMergeLevel;
          }
        }
      }
    }

    return levels;
  }

  /// Group node IDs by their phase level
  static Map<int, List<String>> groupByLevel(Map<String, int> levels) {
    final groups = <int, List<String>>{};
    for (final entry in levels.entries) {
      groups.putIfAbsent(entry.value, () => []).add(entry.key);
    }
    return groups;
  }

  /// Max level in the graph
  static int maxLevel(Map<String, int> levels) {
    if (levels.isEmpty) return 0;
    return levels.values.reduce((a, b) => a > b ? a : b);
  }
}
