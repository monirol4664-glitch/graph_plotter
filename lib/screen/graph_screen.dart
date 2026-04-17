import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../widgets/equation_input.dart';
import '../widgets/graph_painter.dart';
import '../widgets/example_chips.dart';
import '../widgets/control_buttons.dart';
import '../utils/math_parser.dart';

class GraphScreen extends StatefulWidget {
  const GraphScreen({super.key});

  @override
  State<GraphScreen> createState() => _GraphScreenState();
}

class _GraphScreenState extends State<GraphScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Graph state
  List<GraphData> _graphs = [];
  int _selectedGraphIndex = 0;
  double _minX = -5;
  double _maxX = 5;
  double _minY = -5;
  double _maxY = 5;
  String _errorMessage = '';
  bool _showGrid = true;
  bool _showAxes = true;
  
  // Touch state
  Offset? _dragStart;
  Offset? _dragOffset;
  double _scale = 1.0;
  double _initialScale = 1.0;
  
  // Saved equations
  final List<Map<String, String>> _savedEquations = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _graphs.add(GraphData(equation: 'x^2', color: Colors.blue, isVisible: true));
    _loadSavedEquations();
    _plotGraph();
  }

  void _loadSavedEquations() {
    // Load from shared_preferences in real app
    _savedEquations.addAll([
      {'name': 'Quadratic', 'equation': 'x^2'},
      {'name': 'Cubic', 'equation': 'x^3'},
      {'name': 'Sine Wave', 'equation': 'sin(x)'},
    ]);
  }

  void _plotGraph() {
    setState(() {
      _errorMessage = '';
      for (var graph in _graphs) {
        if (graph.isVisible) {
          try {
            graph.points = MathParser.plotEquation(graph.equation, _minX, _maxX, _minY, _maxY);
            graph.error = null;
          } catch (e) {
            graph.error = e.toString();
            _errorMessage = graph.error!;
          }
        }
      }
    });
  }

  void _addGraph() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Graph'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Equation (use x)'),
              onSubmitted: (value) {
                setState(() {
                  _graphs.add(GraphData(
                    equation: value,
                    color: Colors.primaries[_graphs.length % Colors.primaries.length],
                    isVisible: true,
                  ));
                });
                _plotGraph();
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _removeGraph(int index) {
    setState(() {
      _graphs.removeAt(index);
      if (_selectedGraphIndex >= _graphs.length) _selectedGraphIndex = _graphs.length - 1;
    });
    _plotGraph();
  }

  void _zoom(double factor) {
    double centerX = (_minX + _maxX) / 2;
    double rangeX = (_maxX - _minX) * factor;
    double centerY = (_minY + _maxY) / 2;
    double rangeY = (_maxY - _minY) * factor;
    
    setState(() {
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
      _scale = 1.0;
    });
    _plotGraph();
  }

  void _toggleGraphVisibility(int index) {
    setState(() {
      _graphs[index].isVisible = !_graphs[index].isVisible;
    });
    _plotGraph();
  }

  void _updateEquation(int index, String newEquation) {
    setState(() {
      _graphs[index].equation = newEquation;
    });
    _plotGraph();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graph Plotter'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.show_chart), text: 'Graph'),
            Tab(icon: Icon(Icons.format_list_bulleted), text: 'Equations'),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.add_chart), onPressed: _addGraph),
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(child: Text('Export as PNG'), value: 'export'),
              const PopupMenuItem(child: Text('Share Equation'), value: 'share'),
              const PopupMenuItem(child: Text('Clear All'), value: 'clear'),
            ],
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Graph Tab
          Column(
            children: [
              // Equation input for selected graph
              EquationInput(
                equation: _graphs.isNotEmpty ? _graphs[_selectedGraphIndex].equation : 'x^2',
                onEquationChanged: (value) {
                  if (_graphs.isNotEmpty) {
                    _updateEquation(_selectedGraphIndex, value);
                  }
                },
                onPlot: _plotGraph,
              ),
              
              // Graph area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: GestureDetector(
                      onScaleStart: (details) {
                        _initialScale = _scale;
                      },
                      onScaleUpdate: (details) {
                        setState(() {
                          _scale = (_initialScale * details.scale).clamp(0.5, 4.0);
                          double factor = 1 / _scale;
                          _zoom(factor);
                        });
                      },
                      onPanStart: (details) {
                        _dragStart = details.localPosition;
                      },
                      onPanUpdate: (details) {
                        if (_dragStart != null) {
                          setState(() {
                            double dx = (details.localPosition.dx - _dragStart!.dx) / 20;
                            double dy = (details.localPosition.dy - _dragStart!.dy) / 20;
                            _minX -= dx;
                            _maxX -= dx;
                            _minY += dy;
                            _maxY += dy;
                            _dragStart = details.localPosition;
                          });
                          _plotGraph();
                        }
                      },
                      child: CustomPaint(
                        painter: GraphPainter(
                          graphs: _graphs,
                          minX: _minX,
                          maxX: _maxX,
                          minY: _minY,
                          maxY: _maxY,
                          showGrid: _showGrid,
                          showAxes: _showAxes,
                        ),
                        size: Size.infinite,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Control buttons
              ControlButtons(
                onZoomIn: () => _zoom(0.8),
                onZoomOut: () => _zoom(1.2),
                onReset: _resetView,
                onToggleGrid: () => setState(() => _showGrid = !_showGrid),
                onToggleAxes: () => setState(() => _showAxes = !_showAxes),
                showGrid: _showGrid,
                showAxes: _showAxes,
              ),
              
              // Graph selector chips
              if (_graphs.length > 1)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: Row(
                    children: List.generate(_graphs.length, (index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: FilterChip(
                          label: Text(_graphs[index].equation),
                          selected: _selectedGraphIndex == index,
                          selectedColor: _graphs[index].color.withOpacity(0.2),
                          onSelected: (_) => setState(() => _selectedGraphIndex = index),
                          avatar: CircleAvatar(
                            radius: 8,
                            backgroundColor: _graphs[index].color,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              
              // Error message
              if (_errorMessage.isNotEmpty)
                Container(
                  margin: const EdgeInsets.all(8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error, color: Colors.red.shade400, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red.shade700, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 8),
            ],
          ),
          
          // Equations Library Tab
          Column(
            children: [
              ExampleChips(onEquationSelected: (equation) {
                if (_graphs.isNotEmpty) {
                  _updateEquation(_selectedGraphIndex, equation);
                  _tabController.animateTo(0);
                }
              }),
              Expanded(
                child: ListView.builder(
                  itemCount: _savedEquations.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: ListTile(
                        leading: const Icon(Icons.functions),
                        title: Text(_savedEquations[index]['name']!),
                        subtitle: Text(_savedEquations[index]['equation']!),
                        trailing: IconButton(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: () {
                            _updateEquation(_selectedGraphIndex, _savedEquations[index]['equation']!);
                            _tabController.animateTo(0);
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGraph,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GraphData {
  String equation;
  Color color;
  bool isVisible;
  List<Offset> points;
  String? error;

  GraphData({
    required this.equation,
    required this.color,
    required this.isVisible,
    this.points = const [],
    this.error,
  });
}
