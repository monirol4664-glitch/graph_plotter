import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

void main() {
  runApp(const GraphPlotterApp());
}

class GraphPlotterApp extends StatelessWidget {
  const GraphPlotterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graph Plotter',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const GraphScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  final TextEditingController _controller = TextEditingController(text: 'x^2');
  List<Offset> _points = [];
  double _minX = -5, _maxX = 5, _minY = -5, _maxY = 5;
  String _error = '';

  void _plot() {
    setState(() {
      _error = '';
      _points = [];
      try {
        Parser parser = Parser();
        Expression exp = parser.parse(_controller.text);
        ContextModel cm = ContextModel();
        
        for (double x = _minX; x <= _maxX; x += 0.02) {
          cm.bindVariable(Variable('x'), Number(x));
          double y = exp.evaluate(EvaluationType.REAL, cm);
          if (y.isFinite && y > -10 && y < 10) {
            _points.add(Offset(x, y));
          } else {
            _points.add(Offset(x, double.nan));
          }
        }
      } catch (e) {
        _error = 'Invalid equation';
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _plot();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graph Plotter'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'Equation (e.g., x^2, sin(x))',
                      errorText: _error.isNotEmpty ? _error : null,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(onPressed: _plot, child: const Text('Plot')),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 4)],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CustomPaint(
                  painter: GraphPainter(_points, _minX, _maxX, _minY, _maxY),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _minX *= 0.8;
                    _maxX *= 0.8;
                    _minY *= 0.8;
                    _maxY *= 0.8;
                  });
                  _plot();
                },
                icon: const Icon(Icons.zoom_in),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _minX *= 1.2;
                    _maxX *= 1.2;
                    _minY *= 1.2;
                    _maxY *= 1.2;
                  });
                  _plot();
                },
                icon: const Icon(Icons.zoom_out),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _minX = -5;
                    _maxX = 5;
                    _minY = -5;
                    _maxY = 5;
                  });
                  _plot();
                },
                icon: const Icon(Icons.refresh),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final List<Offset> points;
  final double minX, maxX, minY, maxY;

  GraphPainter(this.points, this.minX, this.maxX, this.minY, this.maxY);

  double _mapX(double x, Size size) => (x - minX) / (maxX - minX) * size.width;
  double _mapY(double y, Size size) => size.height - (y - minY) / (maxY - minY) * size.height;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);
    
    Paint grid = Paint()..color = Colors.grey.shade300..strokeWidth = 0.5;
    for (double x = -5; x <= 5; x += 1) {
      double xPos = _mapX(x, size);
      canvas.drawLine(Offset(xPos, 0), Offset(xPos, size.height), grid);
    }
    for (double y = -5; y <= 5; y += 1) {
      double yPos = _mapY(y, size);
      canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), grid);
    }
    
    Paint axis = Paint()..color = Colors.black..strokeWidth = 1.5;
    double xAxis = _mapY(0, size);
    if (xAxis >= 0 && xAxis <= size.height) {
      canvas.drawLine(Offset(0, xAxis), Offset(size.width, xAxis), axis);
    }
    double yAxis = _mapX(0, size);
    if (yAxis >= 0 && yAxis <= size.width) {
      canvas.drawLine(Offset(yAxis, 0), Offset(yAxis, size.height), axis);
    }
    
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