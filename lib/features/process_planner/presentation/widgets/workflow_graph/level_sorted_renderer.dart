import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'workflow_node.dart';
import 'node_position.dart';
import 'straight_edge_painter.dart';
import 'engines/layered_layout_engine.dart';
import 'engines/phase_level_assigner.dart';

/// Layered DAG renderer — approved production renderer.
/// Phase levels = columns (left → right). Nodes in same phase share a column.
/// Straight directed edges with lane separation at merge nodes.
class LevelSortedRenderer extends StatefulWidget {
  final List<WorkflowNode> nodes;

  /// Optional callback fired when a node is tapped.
  /// Receives routingId, operationId, and operationName.
  final void Function(int routingId, int operationId, String operationName)? onNodeTap;

  const LevelSortedRenderer({super.key, required this.nodes, this.onNodeTap});

  @override
  State<LevelSortedRenderer> createState() => _LevelSortedRendererState();
}

class _LevelSortedRendererState extends State<LevelSortedRenderer> {
  late List<NodePosition> _nodePositions;
  late List<Connection> _connections;
  late Map<String, int> _levels; // nodeId → phase level (for debug overlay)

  bool _showDebugOverlay = false;

  @override
  void initState() {
    super.initState();
    _calculateLayout();
  }

  @override
  void didUpdateWidget(LevelSortedRenderer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nodes != widget.nodes) _calculateLayout();
  }

  void _calculateLayout() {
    if (widget.nodes.isEmpty) {
      _nodePositions = [];
      _connections = [];
      _levels = {};
      return;
    }

    _levels = PhaseLevelAssigner.assign(widget.nodes);
    _nodePositions = LayeredLayoutEngine.calculatePositions(widget.nodes);
    _connections = _buildConnections();
  }

  List<Connection> _buildConnections() {
    final idx2pos = <int, NodePosition>{
      for (final p in _nodePositions) p.index: p,
    };
    final out = <Connection>[];
    for (int i = 0; i < widget.nodes.length; i++) {
      final from = idx2pos[i];
      if (from == null) continue;
      for (final t in widget.nodes[i].connections) {
        final to = idx2pos[t];
        if (to != null) out.add(Connection(from: from, to: to));
      }
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nodes.isEmpty) {
      return const Center(
        child: Text('No workflow data', style: TextStyle(color: Colors.grey)),
      );
    }

    final canvasSize = LayeredLayoutEngine.calculateCanvasSize(_nodePositions);

    return Stack(
      children: [
        Container(
          width: canvasSize.width,
          height: canvasSize.height,
          color: Colors.grey.shade50,
          child: Stack(
            children: [
              // Straight directed edges with lane separation at merge nodes
              CustomPaint(
                size: canvasSize,
                painter: StraightEdgePainter(connections: _connections),
              ),
              // Nodes
              ..._nodePositions.map((pos) {
                final node = widget.nodes[pos.index];
                return Positioned(
                  left: pos.x,
                  top: pos.y,
                  child: GestureDetector(
                    onTap: () {
                      if (widget.onNodeTap != null && node.operationId != 0) {
                        widget.onNodeTap!(node.routingId, node.operationId, node.displayName);
                      } else {
                        debugPrint('Tapped: ${node.displayName}');
                      }
                    },
                    child: WorkflowNodeWidget(
                      node: node,
                      width: pos.width,
                      height: pos.height,
                    ),
                  ),
                );
              }),
              // Debug overlay — phase level labels (dev-only)
              if (_showDebugOverlay && kDebugMode)
                ..._nodePositions.map((pos) => _debugLabel(pos)),
            ],
          ),
        ),
        // Debug toggle (dev-only, zero production impact)
        if (kDebugMode)
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () =>
                  setState(() => _showDebugOverlay = !_showDebugOverlay),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _showDebugOverlay
                      ? Colors.deepPurple.shade700
                      : Colors.grey.shade700,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _showDebugOverlay ? 'DBG ON' : 'DBG',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Debug label showing phase level index
  Widget _debugLabel(NodePosition pos) {
    final node = widget.nodes[pos.index];
    final level = _levels[node.id] ?? 0;

    return Positioned(
      left: pos.x,
      top: pos.y - 16,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
        decoration: BoxDecoration(
          color: Colors.blueGrey.shade700.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(3),
        ),
        child: Text(
          'L$level',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
