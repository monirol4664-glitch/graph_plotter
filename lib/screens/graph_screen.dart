import 'package:flutter/material.dart';
import '../widgets/equation_input.dart';
import '../widgets/graph_painter.dart';
import '../widgets/control_buttons.dart';
import '../utils/math_parser.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> {
  List<Offset> _points = [];
  double _minX = -5, _maxX = 5, _minY = -5, _maxY = 5;
  String _equation = 'x^2';
  String _error = '';

  void _plotGraph() {
    setState(() {
      try {
        _points = MathParser.plotEquation(_equation, _minX, _maxX, _minY, _maxY);
        _error = '';
      } catch (e) {
        _error = 'Invalid equation';
        _points = [];
      }
    });
  }

  void _zoom(double factor) {
    setState(() {
      double centerX = (_minX + _maxX) / 2;
      double rangeX = (_maxX - _minX) * factor;
      double centerY = (_minY + _maxY) / 2;
      double rangeY = (_maxY - _minY) * factor;
      _minX = centerX - rangeX / 2;
      _maxX = centerX + rangeX / 2;
      _minY = centerY - rangeY / 2;
      _maxY = centerY + rangeY / 2;
    });
    _plotGraph();
  }

  void _resetView() {
    setState(() {
      _minX = -5;
      _maxX = 5;
      _minY = -5;
      _maxY = 5;
    });
    _plotGraph();
  }

  @override
  void initState() {
    super.initState();
    _plotGraph();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Graph Plotter')),
      body: Column(
        children: [
          EquationInput(
            equation: _equation,
            onEquationChanged: (value) {
              setState(() => _equation = value);
              _plotGraph();
            },
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
          if (_error.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(_error, style: const TextStyle(color: Colors.red)),
            ),
          ControlButtons(
            onZoomIn: () => _zoom(0.8),
            onZoomOut: () => _zoom(1.2),
            onReset: _resetView,
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
