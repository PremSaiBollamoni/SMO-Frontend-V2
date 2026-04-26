import 'package:flutter/material.dart';
import 'workflow_node.dart';
import 'level_sorted_renderer.dart';

/// Entry point for the workflow graph widget.
/// Wraps LevelSortedRenderer in an InteractiveViewer for pan/zoom support.
class HorizontalWorkflowGraph extends StatefulWidget {
  final List<WorkflowNode> nodes;

  /// Optional callback fired when a node is tapped.
  final void Function(int routingId, int operationId, String operationName)? onNodeTap;

  const HorizontalWorkflowGraph({super.key, required this.nodes, this.onNodeTap});

  @override
  State<HorizontalWorkflowGraph> createState() =>
      _HorizontalWorkflowGraphState();
}

class _HorizontalWorkflowGraphState extends State<HorizontalWorkflowGraph> {
  final TransformationController _transformationController =
      TransformationController();

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: _transformationController,
      boundaryMargin: const EdgeInsets.all(100),
      minScale: 0.5,
      maxScale: 3.0,
      constrained: false,
      clipBehavior: Clip.none,
      child: LevelSortedRenderer(nodes: widget.nodes, onNodeTap: widget.onNodeTap),
    );
  }
}
