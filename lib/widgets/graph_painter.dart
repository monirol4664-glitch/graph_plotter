import 'package:flutter/material.dart';

class GraphPainter extends CustomPainter {
  final List<Offset> points;
  final double minX, maxX, minY, maxY;

  const GraphPainter(this.points, this.minX, this.maxX, this.minY, this.maxY);

  double _mapX(double x, Size size) => (x - minX) / (maxX - minX) * size.width;
  double _mapY(double y, Size size) => size.height - (y - minY) / (maxY - minY) * size.height;

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);
    
    // Grid
    Paint grid = Paint()..color = Colors.grey.shade300..strokeWidth = 0.5;
    for (double x = -5; x <= 5; x += 1) {
      double xPos = _mapX(x, size);
      canvas.drawLine(Offset(xPos, 0), Offset(xPos, size.height), grid);
    }
    for (double y = -5; y <= 5; y += 1) {
      double yPos = _mapY(y, size);
      canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), grid);
    }
    
    // Axes
    Paint axis = Paint()..color = Colors.black..strokeWidth = 1.5;
    double xAxis = _mapY(0, size);
    if (xAxis >= 0 && xAxis <= size.height) {
      canvas.drawLine(Offset(0, xAxis), Offset(size.width, xAxis), axis);
    }
    double yAxis = _mapX(0, size);
    if (yAxis >= 0 && yAxis <= size.width) {
      canvas.drawLine(Offset(yAxis, 0), Offset(yAxis, size.height), axis);
    }
    
    // Graph line
    Paint line = Paint()..color = Colors.blue..strokeWidth = 2.5;
    Path path = Path();
    bool first = true;
    for (var p in points) {
      if (p.dy.isNaN) {
        first = true;
        continue;
      }
      double x = _mapX(p.dx, size);
      double y = _mapY(p.dy, size);
      if (x >= 0 && x <= size.width && y >= 0 && y <= size.height) {
        if (first) {
          path.moveTo(x, y);
          first = false;
        } else {
          path.lineTo(x, y);
        }
      } else {
        first = true;
      }
    }
    canvas.drawPath(path, line);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
