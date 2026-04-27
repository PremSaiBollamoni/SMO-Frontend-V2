import 'package:flutter/material.dart';
import '../workflow_node.dart';
import '../node_position.dart';
import 'phase_level_assigner.dart';

/// Layered DAG layout engine for process workflow graphs.
///
/// Pipeline:
///   1. Assign phase levels (topological, immutable)
///   2. Apply semantic node ordering within levels
///   3. Assign X/Y coordinates: X = level column, Y = centered within level
class LayeredLayoutEngine {
  // ── Layout constants ───────────────────────────────────────────────────────
  static const double levelSpacing = 200.0; // Standard horizontal spacing
  static const double mergeChainLevelSpacing = 160.0; // Tighter spacing for merge chains
  static const double nodeSpacing =
      85.0; // Reduced from 100 for tighter vertical spacing
  static const double startX = 60.0; // Left margin
  static const double startY = 60.0; // Top margin
  static const double nodeWidth = 140.0;
  static const double nodeHeight = 60.0;

  // ── Public API ─────────────────────────────────────────────────────────────

  static List<NodePosition> calculatePositions(List<WorkflowNode> nodes) {
    if (nodes.isEmpty) return [];

    // Step 1: Assign phase levels — IMMUTABLE after this point
    final levels = PhaseLevelAssigner.assign(nodes);
    final maxLevel = PhaseLevelAssigner.maxLevel(levels);
    final levelGroups = PhaseLevelAssigner.groupByLevel(levels);

    // Step 2: Crossing minimization disabled — level assignment is immutable
    // Correctness preserved: nodes stay in their assigned phase level

    // Step 3: Assign coordinates using immutable level groups
    return _assignCoordinates(nodes, levelGroups, maxLevel);
  }

  static List<NodePosition> _assignCoordinates(
    List<WorkflowNode> nodes,
    Map<int, List<String>> levelGroups,
    int maxLevel,
  ) {
    final positions = <NodePosition>[];

    // Calculate the maximum number of nodes in any level for canvas height
    final maxNodesInLevel = levelGroups.values
        .map((v) => v.length)
        .fold(0, (a, b) => a > b ? a : b);

    // Canvas center Y — anchor for symmetric fan-out
    final canvasCenterY = startY + (maxNodesInLevel * nodeSpacing) / 2 + 40;

    // Build node map for merge detection
    final nodeMap = <String, WorkflowNode>{};
    for (final n in nodes) {
      nodeMap[n.id] = n;
    }

    // Calculate X positions with adaptive spacing for merge chains
    double currentX = startX;
    final levelXPositions = <int, double>{};
    
    for (int level = 0; level <= maxLevel; level++) {
      levelXPositions[level] = currentX;
      
      final levelNodes = levelGroups[level] ?? [];
      if (levelNodes.isEmpty) continue;
      
      // Detect if this level is part of a merge chain (single merge node)
      final isMergeChainLevel = levelNodes.length == 1 && 
                                 nodeMap[levelNodes.first]?.isMerge == true;
      
      // Use tighter spacing for merge chain levels
      final spacing = isMergeChainLevel ? mergeChainLevelSpacing : levelSpacing;
      currentX += spacing;
    }

    for (int level = 0; level <= maxLevel; level++) {
      var levelNodes = List<String>.from(levelGroups[level] ?? []);
      if (levelNodes.isEmpty) continue;

      final x = levelXPositions[level]!;

      // ── Polish 1: Sort level 2 so BODY_LINE is central ──────────────────
      // Preferred semantic order when all 4 feeder lines are present:
      //   SLEEVE_LINE, COLLAR_CUFF_LINE, BODY_LINE (center), POCKET_PLACKET_LINE
      // Falls back to generic centering if not all nodes are present.
      if (levelNodes.length > 1) {
        const preferredOrder = [
          'SLEEVE_LINE',
          'COLLAR_CUFF_LINE',
          'POCKET_PLACKET_LINE',
          'BODY_LINE',
        ];

        // Check if all preferred nodes are present in this level
        final allPresent = preferredOrder.every(
          (name) => levelNodes.any((id) => id.toUpperCase().contains(name)),
        );

        if (allPresent) {
          // Apply preferred semantic order
          final ordered = <String>[];
          for (final name in preferredOrder) {
            final match = levelNodes.firstWhere(
              (id) => id.toUpperCase().contains(name),
              orElse: () => '',
            );
            if (match.isNotEmpty) ordered.add(match);
          }
          // Append any remaining nodes not in preferred list
          for (final id in levelNodes) {
            if (!ordered.contains(id)) ordered.add(id);
          }
          levelNodes = ordered;
        } else {
          // Generic fallback: center BODY_LINE if present
          final bodyId = levelNodes.firstWhere(
            (id) => id.toUpperCase().contains('BODY_LINE'),
            orElse: () => '',
          );
          if (bodyId.isNotEmpty) {
            levelNodes.remove(bodyId);
            levelNodes.insert(levelNodes.length ~/ 2, bodyId);
          }
        }
      }

      // ── Polish 2: Tighter spacing for merge chain level ────────────────────
      // Detect if this level contains merge-chain nodes (MERGE_COLLAR etc.)
      final isMergeChainLevel = levelNodes.any(
        (id) =>
            id.toUpperCase().contains('MERGE_COLLAR') ||
            id.toUpperCase().contains('MERGE_POCKET') ||
            id.toUpperCase().contains('MERGE_SLEEVE'),
      );
      final effectiveSpacing = isMergeChainLevel
          ? nodeSpacing * 1.2  // Reduced from 1.65 for tighter merge stack
          : nodeSpacing;

      // ── Polish 3: Symmetric fan-out — center all levels around canvasCenterY
      final totalHeight = (levelNodes.length - 1) * effectiveSpacing;
      final levelStartY = canvasCenterY - totalHeight / 2;

      for (int i = 0; i < levelNodes.length; i++) {
        final nodeId = levelNodes[i];
        final y = levelStartY + i * effectiveSpacing;

        positions.add(
          NodePosition(
            index: _indexOf(nodes, nodeId),
            x: x,
            y: y,
            width: nodeWidth,
            height: nodeHeight,
          ),
        );
      }
    }

    return positions;
  }

  /// Canvas size based on positions
  static Size calculateCanvasSize(List<NodePosition> positions) {
    if (positions.isEmpty) return const Size(600, 500);

    double maxX = 0, maxY = 0, minY = double.infinity;
    for (final p in positions) {
      if (p.x + p.width > maxX) maxX = p.x + p.width;
      if (p.y + p.height > maxY) maxY = p.y + p.height;
      if (p.y < minY) minY = p.y;
    }

    // Ensure top nodes are not clipped
    final topPad = minY < 40 ? (40 - minY) + 40 : 40;
    return Size(maxX + 80, maxY + topPad + 60);
  }

  static int _indexOf(List<WorkflowNode> nodes, String id) {
    for (int i = 0; i < nodes.length; i++) {
      if (nodes[i].id == id) return i;
    }
    return 0;
  }
}
