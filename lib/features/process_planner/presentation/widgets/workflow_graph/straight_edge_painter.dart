import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'node_position.dart';

/// Paints straight directed edges with lane separation at merge nodes.
/// Multiple incoming edges to the same target are fanned with small
/// vertical offsets so they never share identical trajectories.
/// Straight diagonal lines only — no elbows, no stepped routing.
/// Shared junction circles at branch split points for visual clarity.
class StraightEdgePainter extends CustomPainter {
  final List<Connection> connections;

  static const double _laneOffset = 12.0; // Vertical offset per lane
  static const double _arrowSize = 8.0;
  static const double _junctionRadius = 4.0; // Shared branch junction circle

  StraightEdgePainter({required this.connections});

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.grey.shade600
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final arrowPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;

    final junctionPaint = Paint()
      ..color = Colors.grey.shade600
      ..style = PaintingStyle.fill;

    // Group connections by target node index to detect merge nodes
    final byTarget = <int, List<Connection>>{};
    for (final conn in connections) {
      byTarget.putIfAbsent(conn.to.index, () => []).add(conn);
    }

    // Group connections by source node index to detect branch splits
    final bySource = <int, List<Connection>>{};
    for (final conn in connections) {
      bySource.putIfAbsent(conn.from.index, () => []).add(conn);
    }

    // Build lane assignment: for each (from, to) pair → vertical offset
    final laneOffsets = <String, double>{};
    for (final entry in byTarget.entries) {
      final incoming = entry.value;
      if (incoming.length <= 1) {
        // Single edge — no offset needed
        laneOffsets[_key(incoming.first)] = 0.0;
        continue;
      }

      // Multiple incoming edges — sort by source Y (top→bottom) for stable lanes
      // Upper source → upper lane, lower source → lower lane
      incoming.sort(
        (a, b) => a.from.rightCenter.dy.compareTo(b.from.rightCenter.dy),
      );

      final count = incoming.length;
      final totalSpread = (count - 1) * _laneOffset;
      final startOffset = -totalSpread / 2;

      for (int i = 0; i < count; i++) {
        laneOffsets[_key(incoming[i])] = startOffset + i * _laneOffset;
      }
    }

    // Draw all edges with their lane offsets
    for (final conn in connections) {
      final offset = laneOffsets[_key(conn)] ?? 0.0;
      _drawEdge(canvas, conn, offset, linePaint, arrowPaint);
    }

    // Draw junction circles at branch split points (multiple outgoing edges)
    for (final entry in bySource.entries) {
      if (entry.value.length > 1) {
        // This node has multiple outgoing edges — draw junction circle
        final sourceNode = entry.value.first.from;
        final junctionPoint = sourceNode.rightCenter;
        canvas.drawCircle(junctionPoint, _junctionRadius, junctionPaint);
      }
    }
  }

  void _drawEdge(
    Canvas canvas,
    Connection conn,
    double laneOffset,
    Paint linePaint,
    Paint arrowPaint,
  ) {
    final start = conn.from.rightCenter;

    // Apply lane offset to the target approach point only
    // Source stays at rightCenter — only the arrival point shifts
    final rawEnd = conn.to.leftCenter;
    final end = Offset(rawEnd.dx, rawEnd.dy + laneOffset);

    canvas.drawLine(start, end, linePaint);
    _drawArrowhead(canvas, arrowPaint, start, end);
  }

  void _drawArrowhead(Canvas canvas, Paint paint, Offset start, Offset end) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final angle = math.atan2(dy, dx);

    final path = Path()
      ..moveTo(end.dx, end.dy)
      ..lineTo(
        end.dx - _arrowSize * math.cos(angle - math.pi / 6),
        end.dy - _arrowSize * math.sin(angle - math.pi / 6),
      )
      ..lineTo(
        end.dx - _arrowSize * math.cos(angle + math.pi / 6),
        end.dy - _arrowSize * math.sin(angle + math.pi / 6),
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  /// Unique key for a connection
  static String _key(Connection c) => '${c.from.index}->${c.to.index}';

  @override
  bool shouldRepaint(StraightEdgePainter oldDelegate) =>
      oldDelegate.connections != connections;
}
