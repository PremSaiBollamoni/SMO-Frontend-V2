import 'package:flutter/material.dart';

/// Position and size of a rendered workflow node on the canvas.
/// Also defines Connection between two NodePositions.
class NodePosition {
  final int index;
  final double x;
  final double y;
  final double width;
  final double height;

  NodePosition({
    required this.index,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  Offset get center => Offset(x + width / 2, y + height / 2);
  Offset get rightCenter => Offset(x + width, y + height / 2);
  Offset get leftCenter => Offset(x, y + height / 2);
}

/// Connection between two nodes
class Connection {
  final NodePosition from;
  final NodePosition to;

  Connection({required this.from, required this.to});
}
