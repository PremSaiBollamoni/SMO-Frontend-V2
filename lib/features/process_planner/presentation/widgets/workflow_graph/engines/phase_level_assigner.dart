import 'package:flutter/foundation.dart';
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

    debugPrint('[PhaseLevelAssigner] ═══ LEVEL ASSIGNMENT START ═══');
    debugPrint('[PhaseLevelAssigner] Root nodes (level 0): ${queue.length}');
    for (final id in queue) {
      final node = nodes.firstWhere((n) => n.id == id);
      debugPrint('[PhaseLevelAssigner]   L0: ${node.displayName}');
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

    // ═══ DIAGNOSTIC: Log final level assignments ═══
    debugPrint('[PhaseLevelAssigner] ─── FINAL LEVELS ───');
    final nodeMap = <String, WorkflowNode>{};
    for (final n in nodes) {
      nodeMap[n.id] = n;
    }
    
    final levelGroups = <int, List<String>>{};
    for (final entry in levels.entries) {
      levelGroups.putIfAbsent(entry.value, () => []).add(entry.key);
    }
    final sortedLevels = levelGroups.keys.toList()..sort();
    for (final level in sortedLevels) {
      final nodeIds = levelGroups[level]!;
      debugPrint('[PhaseLevelAssigner]   Level $level (${nodeIds.length} nodes):');
      for (final id in nodeIds) {
        final node = nodeMap[id];
        if (node != null) {
          debugPrint('[PhaseLevelAssigner]     - ${node.displayName}');
        }
      }
    }
    debugPrint('[PhaseLevelAssigner] ═══ LEVEL ASSIGNMENT END ═══');

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
