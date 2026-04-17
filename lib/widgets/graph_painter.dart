import 'package:flutter/material.dart';
import '../screens/graph_screen.dart';

class GraphPainter extends CustomPainter {
  final List<GraphData> graphs;
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final bool showGrid;
  final bool showAxes;

  GraphPainter({
    required this.graphs,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.showGrid,
    required this.showAxes,
  });

  double _mapX(double x, Size size) => (x - minX) / (maxX - minX) * size.width;
  double _mapY(double y, Size size) => size.height - (y - minY) / (maxY - minY) * size.height;

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white,
    );

    // Draw grid
    if (showGrid) {
      Paint gridPaint = Paint()..color = Colors.grey.shade300..strokeWidth = 0.5;
      
      // Vertical lines
      double xStep = (maxX - minX) / 10;
      for (double x = (minX ~/ xStep) * xStep; x <= maxX; x += xStep) {
        double xPos = _mapX(x, size);
        canvas.drawLine(Offset(xPos, 0), Offset(xPos, size.height), gridPaint);
      }
      
      // Horizontal lines
      double yStep = (maxY - minY) / 10;
      for (double y = (minY ~/ yStep) * yStep; y <= maxY; y += yStep) {
        double yPos = _mapY(y, size);
        canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), gridPaint);
      }
    }

    // Draw axes
    if (showAxes) {
      Paint axisPaint = Paint()..color = Colors.black87..strokeWidth = 1.5;
      
      double xAxisY = _mapY(0, size);
      if (xAxisY >= 0 && xAxisY <= size.height) {
        canvas.drawLine(Offset(0, xAxisY), Offset(size.width, xAxisY), axisPaint);
      }
      
      double yAxisX = _mapX(0, size);
      if (yAxisX >= 0 && yAxisX <= size.width) {
        canvas.drawLine(Offset(yAxisX, 0), Offset(yAxisX, size.height), axisPaint);
      }
    }

    // Draw each graph
    for (var graph in graphs) {
      if (!graph.isVisible) continue;
      
      Paint linePaint = Paint()
        ..color = graph.color
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;
      
      Path path = Path();
      bool isFirstValid = true;
      
      for (int i = 0; i < graph.points.length; i++) {
        if (graph.points[i].dy.isNaN) {
          isFirstValid = true;
          continue;
        }
        
        double x = _mapX(graph.points[i].dx, size);
        double y = _mapY(graph.points[i].dy, size);
        
        if (x >= 0 && x <= size.width && y >= 0 && y <= size.height) {
          if (isFirstValid) {
            path.moveTo(x, y);
            isFirstValid = false;
          } else {
            path.lineTo(x, y);
          }
        } else {
          isFirstValid = true;
        }
      }
      
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
