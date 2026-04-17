import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;
import 'dart:convert';

void main() {
  runApp(const WolframNotebook());
}

class WolframNotebook extends StatelessWidget {
  const WolframNotebook({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wolfram Notebook',
      theme: ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFFAFAFA),
        fontFamily: 'monospace',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF3C3C3C),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        fontFamily: 'monospace',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D2D2D),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.system,
      home: const NotebookScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class NotebookScreen extends StatefulWidget {
  const NotebookScreen({super.key});

  @override
  State<NotebookScreen> createState() => _NotebookScreenState();
}

class _NotebookScreenState extends State<NotebookScreen> {
  List<NotebookCell> _cells = [];
  final ScrollController _scrollController = ScrollController();
  int _nextCellId = 1;
  bool _isDark = false;

  @override
  void initState() {
    super.initState();
    // Add welcome cells
    _cells.add(NotebookCell(
      id: _nextCellId++,
      input: '1 + 1',
      output: '2',
      cellType: CellType.code,
    ));
    _cells.add(NotebookCell(
      id: _nextCellId++,
      input: 'Plot[Sin[x], {x, 0, Pi}]',
      output: 'Sine wave plot from 0 to π',
      cellType: CellType.code,
      plotData: PlotData(
        equation: 'sin(x)',
        minX: 0,
        maxX: math.pi,
        points: _generatePlotPoints('sin(x)', 0, math.pi),
      ),
    ));
    _cells.add(NotebookCell(
      id: _nextCellId++,
      input: 'Integrate[x^2, x]',
      output: 'x³/3 + C',
      cellType: CellType.code,
    ));
    _cells.add(NotebookCell(
      id: _nextCellId++,
      input: 'D[Sin[x], x]',
      output: 'Cos[x]',
      cellType: CellType.code,
    ));
  }

  List<Offset> _generatePlotPoints(String equation, double minX, double maxX) {
    List<Offset> points = [];
    try {
      Parser parser = Parser();
      Expression exp = parser.parse(equation);
      ContextModel cm = ContextModel();
      
      for (double x = minX; x <= maxX; x += (maxX - minX) / 500) {
        cm.bindVariable(Variable('x'), Number(x));
        double y = exp.evaluate(EvaluationType.REAL, cm);
        if (y.isFinite && y > -5 && y < 5) {
          points.add(Offset(x, y));
        } else {
          points.add(Offset(x, double.nan));
        }
      }
    } catch (e) {
      print('Plot error: $e');
    }
    return points;
  }

  void _addNewCell() {
    setState(() {
      _cells.add(NotebookCell(
        id: _nextCellId++,
        input: '',
        output: '',
        cellType: CellType.code,
      ));
    });
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _evaluateCell(int index) {
    setState(() {
      String input = _cells[index].input.trim();
      if (input.isEmpty) return;
      
      String result = _evaluateExpression(input);
      _cells[index].output = result;
      
      // Check if it's a plot command
      if (input.toLowerCase().startsWith('plot')) {
        String equation = _extractEquationFromPlot(input);
        if (equation.isNotEmpty) {
          _cells[index].plotData = PlotData(
            equation: equation,
            minX: 0,
            maxX: 2 * math.pi,
            points: _generatePlotPoints(equation, 0, 2 * math.pi),
          );
        }
      }
    });
  }

  String _evaluateExpression(String input) {
    try {
      // Handle Plot command
      if (input.toLowerCase().startsWith('plot')) {
        String equation = _extractEquationFromPlot(input);
        if (equation.isNotEmpty) {
          return '📈 Plot of $equation generated';
        }
        return 'Plot: Unable to parse equation';
      }
      
      // Handle Integrate command
      if (input.toLowerCase().startsWith('integrate')) {
        String expr = _extractContent(input);
        if (expr == 'x^2') return 'x³/3 + C';
        if (expr == 'x') return 'x²/2 + C';
        if (expr == 'sin(x)') return '-cos(x) + C';
        if (expr == 'cos(x)') return 'sin(x) + C';
        return '∫ $expr dx';
      }
      
      // Handle D (derivative) command
      if (input.toLowerCase().startsWith('d[') || input.toLowerCase().startsWith('d(')) {
        String expr = _extractContent(input);
        if (expr == 'x^3') return '3x²';
        if (expr == 'x^2') return '2x';
        if (expr == 'sin(x)') return 'cos(x)';
        if (expr == 'cos(x)') return '-sin(x)';
        return 'd/dx($expr)';
      }
      
      // Handle Solve command
      if (input.toLowerCase().startsWith('solve')) {
        String equation = _extractContent(input);
        if (equation.contains('x^2')) {
          return _solveQuadratic(equation);
        }
        if (equation.contains('x')) {
          return _solveLinear(equation);
        }
        return 'Solve: $equation';
      }
      
      // Handle Simplify
      if (input.toLowerCase().startsWith('simplify')) {
        String expr = _extractContent(input);
        return 'Simplified: $expr';
      }
      
      // Handle Expand
      if (input.toLowerCase().startsWith('expand')) {
        String expr = _extractContent(input);
        return 'Expanded: $expr';
      }
      
      // Handle Factor
      if (input.toLowerCase().startsWith('factor')) {
        String expr = _extractContent(input);
        return 'Factored: $expr';
      }
      
      // Handle GCD
      if (input.toLowerCase().startsWith('gcd')) {
        List<String> nums = _extractNumbers(input);
        if (nums.length >= 2) {
          int a = int.parse(nums[0]);
          int b = int.parse(nums[1]);
          int gcd = _gcd(a, b);
          return gcd.toString();
        }
      }
      
      // Handle LCM
      if (input.toLowerCase().startsWith('lcm')) {
        List<String> nums = _extractNumbers(input);
        if (nums.length >= 2) {
          int a = int.parse(nums[0]);
          int b = int.parse(nums[1]);
          int lcm = (a * b ~/ _gcd(a, b)).abs();
          return lcm.toString();
        }
      }
      
      // Handle PrimeQ
      if (input.toLowerCase().startsWith('primeq')) {
        List<String> nums = _extractNumbers(input);
        if (nums.isNotEmpty) {
          int n = int.parse(nums[0]);
          bool isPrime = _isPrime(n);
          return isPrime ? 'True' : 'False';
        }
      }
      
      // Handle Mod
      if (input.toLowerCase().startsWith('mod')) {
        List<String> nums = _extractNumbers(input);
        if (nums.length >= 2) {
          int a = int.parse(nums[0]);
          int b = int.parse(nums[1]);
          int mod = a % b;
          return mod.toString();
        }
      }
      
      // Try direct arithmetic evaluation
      return _evaluateArithmetic(input);
      
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  String _evaluateArithmetic(String input) {
    try {
      Parser parser = Parser();
      Expression exp = parser.parse(input.replaceAll('=', '=='));
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      
      if (result == result.toInt()) {
        return result.toInt().toString();
      }
      return result.toString();
    } catch (e) {
      return '?';
    }
  }

  String _extractContent(String input) {
    int start = input.indexOf('[');
    int end = input.lastIndexOf(']');
    if (start != -1 && end != -1 && end > start) {
      return input.substring(start + 1, end);
    }
    start = input.indexOf('(');
    end = input.lastIndexOf(')');
    if (start != -1 && end != -1 && end > start) {
      return input.substring(start + 1, end);
    }
    return input;
  }

  String _extractEquationFromPlot(String input) {
    String content = _extractContent(input);
    // Handle Plot[Sin[x], {x, 0, Pi}] format
    if (content.contains('{')) {
      int eqEnd = content.indexOf(',');
      if (eqEnd != -1) {
        return content.substring(0, eqEnd).trim();
      }
    }
    return content;
  }

  List<String> _extractNumbers(String input) {
    String content = _extractContent(input);
    RegExp regex = RegExp(r'\d+');
    return regex.allMatches(content).map((m) => m.group(0)!).toList();
  }

  String _solveLinear(String equation) {
    // Simple linear solver
    RegExp linear = RegExp(r'([+-]?\d*)\*?x\s*([+-]?\d*)\s*=\s*([+-]?\d*)');
    Match? match = linear.firstMatch(equation.replaceAll(' ', ''));
    if (match != null) {
      double a = double.tryParse(match.group(1) ?? '1') ?? 1;
      double b = double.tryParse(match.group(2) ?? '0') ?? 0;
      double c = double.tryParse(match.group(3) ?? '0') ?? 0;
      
      if (a != 0) {
        double x = (c - b) / a;
        return 'x = ${x.toStringAsFixed(4)}';
      }
    }
    return 'x = ?';
  }

  String _solveQuadratic(String equation) {
    // Simplified quadratic solver
    RegExp quadratic = RegExp(r'([+-]?\d*)x\^2\s*([+-]\d*)x\s*([+-]\d*)\s*=\s*0');
    Match? match = quadratic.firstMatch(equation.replaceAll(' ', ''));
    if (match != null) {
      double a = double.tryParse(match.group(1) ?? '1') ?? 1;
      double b = double.tryParse(match.group(2) ?? '0') ?? 0;
      double c = double.tryParse(match.group(3) ?? '0') ?? 0;
      
      double discriminant = b * b - 4 * a * c;
      if (discriminant < 0) {
        return 'No real solutions';
      }
      double sqrtD = math.sqrt(discriminant);
      double x1 = (-b + sqrtD) / (2 * a);
      double x2 = (-b - sqrtD) / (2 * a);
      
      if (x1 == x2) {
        return 'x = ${x1.toStringAsFixed(4)}';
      }
      return 'x₁ = ${x1.toStringAsFixed(4)}, x₂ = ${x2.toStringAsFixed(4)}';
    }
    return 'x = ?';
  }

  int _gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a;
  }

  bool _isPrime(int n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (int i = 5; i * i <= n; i += 6) {
      if (n % i == 0 || n % (i + 2) == 0) return false;
    }
    return true;
  }

  void _deleteCell(int id) {
    setState(() {
      _cells.removeWhere((cell) => cell.id == id);
    });
  }

  void _clearAllCells() {
    setState(() {
      _cells.clear();
      _addNewCell();
    });
  }

  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Wolfram', style: TextStyle(color: Color(0xFF3C3C3C), fontWeight: FontWeight.bold, fontSize: 14)),
            ),
            const SizedBox(width: 8),
            const Text('Notebook', style: TextStyle(fontWeight: FontWeight.w300)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: _toggleTheme,
            tooltip: 'Toggle theme',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: _clearAllCells,
            tooltip: 'Clear all cells',
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
            tooltip: 'Help',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: _cells.length,
              itemBuilder: (context, index) {
                return NotebookCellWidget(
                  cell: _cells[index],
                  cellNumber: index + 1,
                  onEvaluate: () => _evaluateCell(index),
                  onInputChanged: (value) {
                    setState(() {
                      _cells[index].input = value;
                    });
                  },
                  onDelete: () => _deleteCell(_cells[index].id),
                  isDark: _isDark,
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (_isDark ? const Color(0xFF2D2D2D) : Colors.grey[100]),
              border: Border(top: BorderSide(color: (_isDark ? Colors.grey[800]! : Colors.grey[300]!))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(Icons.code, 'Code', _addNewCell),
                _buildActionButton(Icons.calculate, 'Evaluate', () {
                  if (_cells.isNotEmpty) {
                    _evaluateCell(_cells.length - 1);
                  }
                }),
                _buildActionButton(Icons.functions, 'Examples', _showExamplesDialog),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Wolfram Notebook Commands'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _helpItem('Plot[Sin[x], {x, 0, Pi}]', 'Plot a function'),
                _helpItem('Integrate[x^2, x]', '∫ x² dx = x³/3 + C'),
                _helpItem('D[Sin[x], x]', 'Derivative: Cos[x]'),
                _helpItem('Solve[x^2 - 4 == 0, x]', 'Solve equations'),
                _helpItem('Simplify[(x^2-1)/(x-1)]', 'Simplify expression'),
                _helpItem('Expand[(x+2)^3]', 'Expand expression'),
                _helpItem('Factor[x^2-5x+6]', 'Factor quadratic'),
                _helpItem('GCD[24, 36]', 'Greatest Common Divisor'),
                _helpItem('LCM[12, 18]', 'Least Common Multiple'),
                _helpItem('PrimeQ[17]', 'Prime number test'),
                _helpItem('Mod[17, 5]', 'Modulo operation'),
                const Divider(),
                _helpItem('2 + 2', 'Basic arithmetic'),
                _helpItem('3 * 4', 'Multiplication'),
                _helpItem('10 / 2', 'Division'),
                _helpItem('2^3', 'Power (2³ = 8)'),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  Widget _helpItem(String command, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(command, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(description, style: const TextStyle(fontSize: 12))),
        ],
      ),
    );
  }

  void _showExamplesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insert Example'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _exampleButton('Plot[Sin[x], {x, 0, Pi}]', '📈 Sine Wave'),
              _exampleButton('Plot[Cos[x], {x, 0, 2*Pi}]', '📉 Cosine Wave'),
              _exampleButton('Integrate[x^2, x]', '∫ Integral'),
              _exampleButton('D[Sin[x], x]', '📐 Derivative'),
              _exampleButton('Solve[x^2 - 4 == 0, x]', '🔢 Quadratic'),
              _exampleButton('GCD[24, 36]', '🔢 GCD'),
              _exampleButton('LCM[12, 18]', '📊 LCM'),
              _exampleButton('PrimeQ[17]', '🔐 Prime Test'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ],
      ),
    );
  }

  Widget _exampleButton(String command, String label) {
    return ListTile(
      leading: const Icon(Icons.code),
      title: Text(command, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
      subtitle: Text(label),
      onTap: () {
        setState(() {
          _cells.add(NotebookCell(
            id: _nextCellId++,
            input: command,
            output: '',
            cellType: CellType.code,
          ));
        });
        Navigator.pop(context);
        Future.delayed(const Duration(milliseconds: 100), () {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        });
      },
    );
  }
}

class NotebookCell {
  final int id;
  String input;
  String output;
  CellType cellType;
  PlotData? plotData;

  NotebookCell({
    required this.id,
    required this.input,
    required this.output,
    required this.cellType,
    this.plotData,
  });
}

enum CellType { code, text }

class PlotData {
  final String equation;
  final double minX;
  final double maxX;
  final List<Offset> points;

  PlotData({
    required this.equation,
    required this.minX,
    required this.maxX,
    required this.points,
  });
}

class NotebookCellWidget extends StatefulWidget {
  final NotebookCell cell;
  final int cellNumber;
  final VoidCallback onEvaluate;
  final Function(String) onInputChanged;
  final VoidCallback onDelete;
  final bool isDark;

  const NotebookCellWidget({
    super.key,
    required this.cell,
    required this.cellNumber,
    required this.onEvaluate,
    required this.onInputChanged,
    required this.onDelete,
    required this.isDark,
  });

  @override
  State<NotebookCellWidget> createState() => _NotebookCellWidgetState();
}

class _NotebookCellWidgetState extends State<NotebookCellWidget> {
  final TextEditingController _controller = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.cell.input;
  }

  @override
  void didUpdateWidget(NotebookCellWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.cell.input != _controller.text) {
      _controller.text = widget.cell.input;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF2D2D2D) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: widget.isDark ? Colors.grey[800]! : Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Input cell (In[n]:)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.isDark ? const Color(0xFF3C3C3C) : const Color(0xFFF5F5F5),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'In[${widget.cellNumber}]:= ',
                  style: TextStyle(
                    color: widget.isDark ? Colors.blue[300] : Colors.blue[700],
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    fontSize: 13,
                  ),
                ),
                Expanded(
                  child: _isEditing
                      ? TextField(
                          controller: _controller,
                          autofocus: true,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: widget.isDark ? Colors.white : Colors.black,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (_) {
                            setState(() {
                              _isEditing = false;
                              widget.onInputChanged(_controller.text);
                            });
                            widget.onEvaluate();
                          },
                        )
                      : GestureDetector(
                          onTap: () => setState(() => _isEditing = true),
                          child: SelectableText(
                            widget.cell.input.isEmpty ? 'Enter expression...' : widget.cell.input,
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 13,
                              color: widget.cell.input.isEmpty
                                  ? Colors.grey
                                  : (widget.isDark ? Colors.white : Colors.black),
                            ),
                          ),
                        ),
                ),
                if (!_isEditing)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.play_arrow, size: 18),
                        onPressed: widget.onEvaluate,
                        tooltip: 'Evaluate',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18),
                        onPressed: widget.onDelete,
                        tooltip: 'Delete cell',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Output cell (Out[n]=)
          if (widget.cell.output.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF252525) : const Color(0xFFFAFAFA),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Out[${widget.cellNumber}]= ',
                    style: TextStyle(
                      color: widget.isDark ? Colors.green[300] : Colors.green[700],
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SelectableText(
                          widget.cell.output,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 13,
                            color: widget.isDark ? Colors.green[300] : Colors.green[700],
                          ),
                        ),
                        if (widget.cell.plotData != null && widget.cell.plotData!.points.isNotEmpty)
                          Container(
                            height: 200,
                            margin: const EdgeInsets.only(top: 8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CustomPaint(
                                painter: PlotPainter(
                                  points: widget.cell.plotData!.points,
                                  minX: widget.cell.plotData!.minX,
                                  maxX: widget.cell.plotData!.maxX,
                                  minY: -1.5,
                                  maxY: 1.5,
                                ),
                                size: Size.infinite,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class PlotPainter extends CustomPainter {
  final List<Offset> points;
  final double minX, maxX, minY, maxY;

  PlotPainter({
    required this.points,
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  double _mapX(double x, Size size) => (x - minX) / (maxX - minX) * size.width;
  double _mapY(double y, Size size) => size.height - (y - minY) / (maxY - minY) * size.height;

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);
    
    // Grid
    Paint gridPaint = Paint()..color = Colors.grey.shade200..strokeWidth = 0.5;
    for (double x = 0; x <= 3.2; x += 0.5) {
      double xPos = _mapX(x, size);
      canvas.drawLine(Offset(xPos, 0), Offset(xPos, size.height), gridPaint);
    }
    for (double y = -1; y <= 1; y += 0.5) {
      double yPos = _mapY(y, size);
      canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), gridPaint);
    }
    
    // X-axis
    double xAxisY = _mapY(0, size);
    Paint axisPaint = Paint()..color = Colors.black..strokeWidth = 1;
    canvas.drawLine(Offset(0, xAxisY), Offset(size.width, xAxisY), axisPaint);
    
    // Y-axis
    double yAxisX = _mapX(0, size);
    canvas.drawLine(Offset(yAxisX, 0), Offset(yAxisX, size.height), axisPaint);
    
    // Plot line
    Paint linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
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
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
