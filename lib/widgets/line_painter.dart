import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final List<int> visitedCells;
  final Offset Function(int) cellCenter;
  final Offset? currentDragPosition;
  final Color lineColor;

  LinePainter({
    required this.visitedCells,
    required this.cellCenter,
    this.currentDragPosition,
    this.lineColor = Colors.red,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (visitedCells.isEmpty) return;

    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < visitedCells.length - 1; i++) {
      final p1 = cellCenter(visitedCells[i]);
      final p2 = cellCenter(visitedCells[i + 1]);
      canvas.drawLine(p1, p2, paint);
    }

    if (currentDragPosition != null && visitedCells.isNotEmpty) {
      final lastCellCenter = cellCenter(visitedCells.last);
      canvas.drawLine(lastCellCenter, currentDragPosition!, paint);
    }
  }

  @override
  bool shouldRepaint(LinePainter oldDelegate) {
    return oldDelegate.visitedCells != visitedCells ||
        oldDelegate.currentDragPosition != currentDragPosition ||
        oldDelegate.lineColor != lineColor;
  }
}
