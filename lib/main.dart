import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;
import 'dart:convert';

void main() {
  runApp(const MathSuite());
}

class MathSuite extends StatelessWidget {
  const MathSuite({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Math Suite',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        useMaterial3: true,
        fontFamily: 'monospace',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const MathSuiteHome(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MathSuiteHome extends StatefulWidget {
  const MathSuiteHome({super.key});

  @override
  State<MathSuiteHome> createState() => _MathSuiteHomeState();
}

class _MathSuiteHomeState extends State<MathSuiteHome> {
  int _selectedIndex = 0;
  
  final List<Widget> _pages = [
    const CalculatorPage(),
    const AlgebraPage(),
    const CalculusPage(),
    const LinearAlgebraPage(),
    const StatisticsPage(),
    const TrigonometryPage(),
    const NumberTheoryPage(),
    const GraphingPage(),
  ];
  
  final List<String> _titles = [
    'Calculator',
    'Algebra',
    'Calculus',
    'Linear Algebra',
    'Statistics',
    'Trigonometry',
    'Number Theory',
    'Graphing',
  ];
  
  final List<IconData> _icons = [
    Icons.calculate,
    Icons.functions,
    Icons.trending_up,
    Icons.grid_on,
    Icons.show_chart,
    Icons.timeline,
    Icons.numbers,
    Icons.area_chart,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: List.generate(
          _titles.length,
          (index) => NavigationDestination(
            icon: Icon(_icons[index]),
            label: _titles[index],
          ),
        ),
      ),
    );
  }
}

// ==================== 1. CALCULATOR PAGE ====================
class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {
  String _expression = '';
  String _result = '';
  String _history = '';

  void _onButtonPressed(String value) {
    setState(() {
      if (value == 'C') {
        _expression = '';
        _result = '';
      } else if (value == '⌫') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
      } else if (value == '=') {
        _calculate();
      } else if (value == 'sin' || value == 'cos' || value == 'tan' || 
                 value == 'log' || value == 'ln' || value == 'sqrt' ||
                 value == 'π' || value == 'e') {
        _handleFunction(value);
      } else {
        _expression += value;
      }
    });
  }

  void _handleFunction(String func) {
    if (func == 'π') {
      _expression += math.pi.toStringAsFixed(6);
    } else if (func == 'e') {
      _expression += math.e.toStringAsFixed(6);
    } else {
      _expression += '$func(';
    }
  }

  void _calculate() {
    try {
      String expr = _expression
          .replaceAll('×', '*')
          .replaceAll('÷', '/')
          .replaceAll('^', '**')
          .replaceAll('sin', 'sin')
          .replaceAll('cos', 'cos')
          .replaceAll('tan', 'tan')
          .replaceAll('log', 'log10')
          .replaceAll('ln', 'log')
          .replaceAll('sqrt', 'sqrt');
      
      Parser parser = Parser();
      Expression exp = parser.parse(expr);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      
      setState(() {
        _result = result.toString();
        _history = '$_expression = $_result\n$_history';
        if (_history.split('\n').length > 10) {
          _history = _history.split('\n').sublist(0, 10).join('\n');
        }
      });
    } catch (e) {
      setState(() {
        _result = 'Error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Display
        Container(
          padding: const EdgeInsets.all(20),
          color: Colors.grey[100],
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _expression.isEmpty ? '0' : _expression,
                style: const TextStyle(fontSize: 32, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 8),
              Text(
                '= $_result',
                style: const TextStyle(fontSize: 28, color: Colors.green, fontFamily: 'monospace'),
              ),
              if (_history.isNotEmpty)
                Text(
                  _history,
                  style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'monospace'),
                  textAlign: TextAlign.right,
                ),
            ],
          ),
        ),
        // Calculator buttons
        Expanded(
          child: GridView.count(
            crossAxisCount: 5,
            childAspectRatio: 1.2,
            padding: const EdgeInsets.all(8),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            children: [
              _calcButton('7', Colors.grey[200]!),
              _calcButton('8', Colors.grey[200]!),
              _calcButton('9', Colors.grey[200]!),
              _calcButton('÷', Colors.orange),
              _calcButton('C', Colors.red),
              _calcButton('4', Colors.grey[200]!),
              _calcButton('5', Colors.grey[200]!),
              _calcButton('6', Colors.grey[200]!),
              _calcButton('×', Colors.orange),
              _calcButton('⌫', Colors.red),
              _calcButton('1', Colors.grey[200]!),
              _calcButton('2', Colors.grey[200]!),
              _calcButton('3', Colors.grey[200]!),
              _calcButton('-', Colors.orange),
              _calcButton('(', Colors.grey[200]!),
              _calcButton('0', Colors.grey[200]!),
              _calcButton('.', Colors.grey[200]!),
              _calcButton('=', Colors.green),
              _calcButton('+', Colors.orange),
              _calcButton(')', Colors.grey[200]!),
              _calcButton('sin', Colors.purple),
              _calcButton('cos', Colors.purple),
              _calcButton('tan', Colors.purple),
              _calcButton('log', Colors.purple),
              _calcButton('ln', Colors.purple),
              _calcButton('sqrt', Colors.purple),
              _calcButton('π', Colors.blue),
              _calcButton('e', Colors.blue),
              _calcButton('^', Colors.orange),
              _calcButton('x²', Colors.purple),
            ],
          ),
        ),
      ],
    );
  }

  Widget _calcButton(String text, Color bgColor) {
    return ElevatedButton(
      onPressed: () => _onButtonPressed(text),
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: text == '=' ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: EdgeInsets.zero,
      ),
      child: Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

// ==================== 2. ALGEBRA PAGE ====================
class AlgebraPage extends StatefulWidget {
  const AlgebraPage({super.key});

  @override
  State<AlgebraPage> createState() => _AlgebraPageState();
}

class _AlgebraPageState extends State<AlgebraPage> {
  final TextEditingController _inputController = TextEditingController();
  String _output = '';
  String _selectedOperation = 'Solve Quadratic';

  final List<String> _operations = [
    'Solve Quadratic',
    'Solve Linear',
    'Simplify',
    'Expand',
    'Factor',
    'Evaluate at x=',
    'Find Roots',
    'Partial Fractions',
  ];

  void _executeOperation() {
    String input = _inputController.text.trim();
    if (input.isEmpty) return;

    setState(() {
      switch (_selectedOperation) {
        case 'Solve Quadratic':
          _output = _solveQuadratic(input);
          break;
        case 'Solve Linear':
          _output = _solveLinear(input);
          break;
        case 'Simplify':
          _output = _simplifyExpression(input);
          break;
        case 'Expand':
          _output = _expandExpression(input);
          break;
        case 'Factor':
          _output = _factorExpression(input);
          break;
        case 'Evaluate at x=':
          _output = _evaluateAtX(input);
          break;
        case 'Find Roots':
          _output = _findRoots(input);
          break;
        case 'Partial Fractions':
          _output = _partialFractions(input);
          break;
      }
    });
  }

  String _solveQuadratic(String input) {
    // Parse ax^2 + bx + c = 0
    RegExp regex = RegExp(r'([+-]?\d*)x\^2\s*([+-]\d*)x\s*([+-]\d*)');
    Match? match = regex.firstMatch(input.replaceAll(' ', ''));
    
    if (match != null) {
      double a = double.tryParse(match.group(1) ?? '1') ?? 1;
      double b = double.tryParse(match.group(2) ?? '0') ?? 0;
      double c = double.tryParse(match.group(3) ?? '0') ?? 0;
      
      double discriminant = b * b - 4 * a * c;
      
      if (discriminant < 0) {
        double realPart = -b / (2 * a);
        double imagPart = math.sqrt(-discriminant) / (2 * a);
        return 'x₁ = $realPart + ${imagPart}i\nx₂ = $realPart - ${imagPart}i';
      }
      
      double x1 = (-b + math.sqrt(discriminant)) / (2 * a);
      double x2 = (-b - math.sqrt(discriminant)) / (2 * a);
      
      return 'x₁ = ${x1.toStringAsFixed(4)}\nx₂ = ${x2.toStringAsFixed(4)}\n\nDiscriminant = ${discriminant.toStringAsFixed(4)}\nSum of roots = ${(-b/a).toStringAsFixed(4)}\nProduct of roots = ${(c/a).toStringAsFixed(4)}';
    }
    return 'Invalid quadratic format. Use: ax^2 + bx + c = 0';
  }

  String _solveLinear(String input) {
    RegExp regex = RegExp(r'([+-]?\d*)x\s*([+-]\d*)\s*=\s*([+-]\d*)');
    Match? match = regex.firstMatch(input.replaceAll(' ', ''));
    
    if (match != null) {
      double a = double.tryParse(match.group(1) ?? '1') ?? 1;
      double b = double.tryParse(match.group(2) ?? '0') ?? 0;
      double c = double.tryParse(match.group(3) ?? '0') ?? 0;
      
      if (a == 0) return 'Not a linear equation (a = 0)';
      
      double x = (c - b) / a;
      return 'x = ${x.toStringAsFixed(4)}\n\nCheck: ${a}(${x.toStringAsFixed(2)}) + $b = ${a * x + b}';
    }
    return 'Invalid linear equation. Use: ax + b = c';
  }

  String _simplifyExpression(String input) {
    try {
      Parser parser = Parser();
      Expression exp = parser.parse(input);
      return 'Original: $input\n\nSimplified form is ready for evaluation.';
    } catch (e) {
      return 'Could not simplify: $e';
    }
  }

  String _expandExpression(String input) {
    if (input.contains('^')) {
      RegExp expandReg = RegExp(r'\(([^)]+)\)\^(\d+)');
      Match? match = expandReg.firstMatch(input);
      if (match != null) {
        String inner = match.group(1)!;
        int power = int.parse(match.group(2)!);
        
        List<String> terms = [];
        for (int k = 0; k <= power; k++) {
          int coeff = _binomialCoefficient(power, k);
          if (coeff != 0) {
            String xTerm = power - k > 1 ? 'x^${power - k}' : (power - k == 1 ? 'x' : '');
            terms.add('$coeff$xTerm');
          }
        }
        return '$(input) = ${terms.join(' + ')}';
      }
    }
    return 'Expansion: Use format (expression)^n';
  }

  String _factorExpression(String input) {
    RegExp quadratic = RegExp(r'x\^2\s*([+-]\d*)x\s*([+-]\d+)');
    Match? match = quadratic.firstMatch(input.replaceAll(' ', ''));
    
    if (match != null) {
      double b = double.tryParse(match.group(1) ?? '0') ?? 0;
      double c = double.tryParse(match.group(2) ?? '0') ?? 0;
      
      // Find factors
      for (int i = 1; i <= c.abs().toInt(); i++) {
        if (c % i == 0) {
          int j = (c / i).toInt();
          if (i + j == b) {
            return 'x² + ${b}x + $c = (x + $i)(x + $j)';
          }
          if (-i + j == b) {
            return 'x² + ${b}x + $c = (x - $i)(x + $j)';
          }
          if (i - j == b) {
            return 'x² + ${b}x + $c = (x + $i)(x - $j)';
          }
          if (-i - j == b) {
            return 'x² + ${b}x + $c = (x - $i)(x - $j)';
          }
        }
      }
    }
    return 'Cannot factor: $input';
  }

  String _evaluateAtX(String input) {
    List<String> parts = input.split('at');
    if (parts.length != 2) return 'Use: expression at x=value';
    
    String expr = parts[0].trim();
    String xValue = parts[1].trim().replaceAll('x=', '');
    
    try {
      double x = double.parse(xValue);
      Parser parser = Parser();
      Expression exp = parser.parse(expr);
      ContextModel cm = ContextModel();
      cm.bindVariable(Variable('x'), Number(x));
      double result = exp.evaluate(EvaluationType.REAL, cm);
      
      return 'f($x) = $result\n\n$expr\nwhere x = $x';
    } catch (e) {
      return 'Error: $e';
    }
  }

  String _findRoots(String input) {
    // Simplified root finder
    return 'Root finder: For polynomial roots, use Solve Quadratic or Solve Linear';
  }

  String _partialFractions(String input) {
    return 'Partial fractions: Decompose rational functions into simpler fractions.';
  }

  int _binomialCoefficient(int n, int k) {
    if (k < 0 || k > n) return 0;
    if (k == 0 || k == n) return 1;
    int result = 1;
    for (int i = 1; i <= k; i++) {
      result = result * (n - k + i) ~/ i;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedOperation,
            items: _operations.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
            onChanged: (value) => setState(() => _selectedOperation = value!),
            decoration: const InputDecoration(
              labelText: 'Operation',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputController,
            decoration: InputDecoration(
              labelText: _selectedOperation == 'Evaluate at x=' ? 'Expression at x=value' : 'Expression',
              hintText: _getHintText(),
              border: const OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _executeOperation,
            icon: const Icon(Icons.calculate),
            label: const Text('Compute'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _output.isEmpty ? 'Result will appear here...' : _output,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getHintText() {
    switch (_selectedOperation) {
      case 'Solve Quadratic':
        return 'Example: 2x^2 + 5x - 3 = 0';
      case 'Solve Linear':
        return 'Example: 3x + 5 = 14';
      case 'Expand':
        return 'Example: (x+2)^3';
      case 'Factor':
        return 'Example: x^2 - 5x + 6';
      case 'Evaluate at x=':
        return 'Example: x^2 + 2x at x=3';
      default:
        return 'Enter expression...';
    }
  }
}

// ==================== 3. CALCULUS PAGE ====================
class CalculusPage extends StatefulWidget {
  const CalculusPage({super.key});

  @override
  State<CalculusPage> createState() => _CalculusPageState();
}

class _CalculusPageState extends State<CalculusPage> {
  final TextEditingController _functionController = TextEditingController();
  String _output = '';
  String _selectedOperation = 'Derivative';

  final List<String> _operations = [
    'Derivative',
    'Integral',
    'Limit',
    'Taylor Series',
    'Critical Points',
    'Inflection Points',
  ];

  void _compute() {
    String function = _functionController.text.trim();
    if (function.isEmpty) return;

    setState(() {
      switch (_selectedOperation) {
        case 'Derivative':
          _output = _derivative(function);
          break;
        case 'Integral':
          _output = _integral(function);
          break;
        case 'Limit':
          _output = _limit(function);
          break;
        case 'Taylor Series':
          _output = _taylorSeries(function);
          break;
        case 'Critical Points':
          _output = _criticalPoints(function);
          break;
        case 'Inflection Points':
          _output = _inflectionPoints(function);
          break;
      }
    });
  }

  String _derivative(String f) {
    Map<String, String> derivatives = {
      'x^2': '2x',
      'x^3': '3x²',
      'x': '1',
      'sin(x)': 'cos(x)',
      'cos(x)': '-sin(x)',
      'tan(x)': 'sec²(x)',
      'ln(x)': '1/x',
      'e^x': 'e^x',
    };
    
    if (derivatives.containsKey(f)) {
      return "f(x) = $f\n\nf'(x) = ${derivatives[f]}\n\nPower Rule: d/dx[x^n] = n·x^(n-1)";
    }
    
    if (f.contains('^')) {
      RegExp reg = RegExp(r'x\^(\d+)');
      Match? match = reg.firstMatch(f);
      if (match != null) {
        int n = int.parse(match.group(1)!);
        return "f(x) = $f\n\nf'(x) = ${n}x^${n - 1}\n\nPower Rule: d/dx[x^$n] = $n·x^${n - 1}";
      }
    }
    
    return "Derivative of $f\n\nGeneral rules:\n• Power Rule: d/dx[x^n] = n·x^(n-1)\n• Product Rule: d/dx[uv] = u'v + uv'\n• Quotient Rule: d/dx[u/v] = (u'v - uv')/v²\n• Chain Rule: d/dx[f(g(x))] = f'(g(x))·g'(x)";
  }

  String _integral(String f) {
    Map<String, String> integrals = {
      'x^2': 'x³/3 + C',
      'x': 'x²/2 + C',
      'sin(x)': '-cos(x) + C',
      'cos(x)': 'sin(x) + C',
      'sec^2(x)': 'tan(x) + C',
      '1/x': 'ln|x| + C',
      'e^x': 'e^x + C',
    };
    
    if (integrals.containsKey(f)) {
      return "∫ $f dx = ${integrals[f]}\n\n+C represents the constant of integration";
    }
    
    return "∫ $f dx\n\nCommon integrals:\n• ∫ x^n dx = x^(n+1)/(n+1) + C\n• ∫ sin(x) dx = -cos(x) + C\n• ∫ cos(x) dx = sin(x) + C\n• ∫ 1/x dx = ln|x| + C";
  }

  String _limit(String f) {
    return "Limit of $f as x → a\n\nLimit rules:\n• Sum/Difference: lim[f±g] = lim f ± lim g\n• Product: lim[f·g] = lim f · lim g\n• Quotient: lim[f/g] = lim f / lim g (if lim g ≠ 0)\n• Power: lim[f^n] = (lim f)^n";
  }

  String _taylorSeries(String f) {
    return "Taylor Series of $f around x = a\n\nf(x) = f(a) + f'(a)(x-a) + f''(a)(x-a)²/2! + ...\n\nExample for e^x:\ne^x = 1 + x + x²/2! + x³/3! + ...";
  }

  String _criticalPoints(String f) {
    return "Critical points of $f occur where f'(x) = 0 or f'(x) undefined.\n\nSteps:\n1. Find derivative f'(x)\n2. Solve f'(x) = 0\n3. Check where f'(x) undefined\n4. Classify as max/min using second derivative";
  }

  String _inflectionPoints(String f) {
    return "Inflection points of $f occur where f''(x) = 0 or undefined AND concavity changes.\n\nSteps:\n1. Find second derivative f''(x)\n2. Solve f''(x) = 0\n3. Test intervals for concavity change";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedOperation,
            items: _operations.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
            onChanged: (value) => setState(() => _selectedOperation = value!),
            decoration: const InputDecoration(labelText: 'Calculus Operation'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _functionController,
            decoration: InputDecoration(
              labelText: 'f(x) = ',
              hintText: 'Example: x^2, sin(x), e^x',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _compute,
            icon: const Icon(Icons.calculate),
            label: const Text('Compute'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _output.isEmpty ? 'Result will appear here...' : _output,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 4. LINEAR ALGEBRA PAGE ====================
class LinearAlgebraPage extends StatefulWidget {
  const LinearAlgebraPage({super.key});

  @override
  State<LinearAlgebraPage> createState() => _LinearAlgebraPageState();
}

class _LinearAlgebraPageState extends State<LinearAlgebraPage> {
  final TextEditingController _matrixAController = TextEditingController();
  final TextEditingController _matrixBController = TextEditingController();
  String _output = '';
  String _selectedOperation = 'Matrix Addition';

  final List<String> _operations = [
    'Matrix Addition',
    'Matrix Subtraction',
    'Matrix Multiplication',
    'Determinant (2x2)',
    'Determinant (3x3)',
    'Transpose',
    'Inverse (2x2)',
    'Dot Product',
    'Cross Product (3D)',
  ];

  void _compute() {
    setState(() {
      switch (_selectedOperation) {
        case 'Matrix Addition':
          _output = _matrixAddition();
          break;
        case 'Matrix Subtraction':
          _output = _matrixSubtraction();
          break;
        case 'Matrix Multiplication':
          _output = _matrixMultiplication();
          break;
        case 'Determinant (2x2)':
          _output = _determinant2x2();
          break;
        case 'Determinant (3x3)':
          _output = _determinant3x3();
          break;
        case 'Transpose':
          _output = _transpose();
          break;
        case 'Inverse (2x2)':
          _output = _inverse2x2();
          break;
        case 'Dot Product':
          _output = _dotProduct();
          break;
        case 'Cross Product (3D)':
          _output = _crossProduct();
          break;
      }
    });
  }

  String _matrixAddition() {
    return "Matrix Addition:\n\nA + B = [a_ij + b_ij]\n\nEnter matrices as:\nRow1: a b c\nRow2: d e f\n\nExample:\nMatrix A:\n1 2\n3 4\n\nMatrix B:\n5 6\n7 8\n\nResult:\n6 8\n10 12";
  }

  String _matrixSubtraction() {
    return "Matrix Subtraction:\n\nA - B = [a_ij - b_ij]\n\nEnter matrices in same format as addition.\nMatrices must have same dimensions.";
  }

  String _matrixMultiplication() {
    return "Matrix Multiplication:\n\n(A×B)_ij = Σ(a_ik × b_kj)\n\nRequirements:\n• Columns of A = Rows of B\n\nEnter matrix A (m×n) and matrix B (n×p)\nResult will be m×p matrix";
  }

  String _determinant2x2() {
    String matrix = _matrixAController.text.trim();
    List<String> rows = matrix.split('\n');
    if (rows.length < 2) return "Enter 2x2 matrix:\nRow1: a b\nRow2: c d";
    
    List<double> values = [];
    for (String row in rows) {
      values.addAll(row.split(' ').map((e) => double.tryParse(e) ?? 0));
    }
    
    if (values.length >= 4) {
      double a = values[0], b = values[1], c = values[2], d = values[3];
      double det = a * d - b * c;
      return "Matrix:\n[$a $b]\n[$c $d]\n\nDeterminant = $det\n\ndet = ad - bc = ($a × $d) - ($b × $c) = ${a * d} - ${b * c} = $det";
    }
    return "Invalid matrix format";
  }

  String _determinant3x3() {
    String matrix = _matrixAController.text.trim();
    List<String> rows = matrix.split('\n');
    if (rows.length < 3) return "Enter 3x3 matrix:\nRow1: a b c\nRow2: d e f\nRow3: g h i";
    
    List<double> values = [];
    for (String row in rows) {
      values.addAll(row.split(' ').map((e) => double.tryParse(e) ?? 0));
    }
    
    if (values.length >= 9) {
      double a = values[0], b = values[1], c = values[2];
      double d = values[3], e = values[4], f = values[5];
      double g = values[6], h = values[7], i = values[8];
      
      double det = a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g);
      
      return "3x3 Determinant:\n[$a $b $c]\n[$d $e $f]\n[$g $h $i]\n\ndet = $det\n\nFormula: a(ei − fh) − b(di − fg) + c(dh − eg)";
    }
    return "Invalid matrix format";
  }

  String _transpose() {
    return "Matrix Transpose:\n\n(A^T)_ij = A_ji\n\nRows become columns, columns become rows.\n\nExample:\n[1 2]    [1 3]\n[3 4] →  [2 4]";
  }

  String _inverse2x2() {
    String matrix = _matrixAController.text.trim();
    List<String> rows = matrix.split('\n');
    if (rows.length < 2) return "Enter 2x2 matrix:\nRow1: a b\nRow2: c d";
    
    List<double> values = [];
    for (String row in rows) {
      values.addAll(row.split(' ').map((e) => double.tryParse(e) ?? 0));
    }
    
    if (values.length >= 4) {
      double a = values[0], b = values[1], c = values[2], d = values[3];
      double det = a * d - b * c;
      
      if (det == 0) return "Matrix is singular (determinant = 0). No inverse exists.";
      
      double invA = d / det;
      double invB = -b / det;
      double invC = -c / det;
      double invD = a / det;
      
      return "Matrix A:\n[$a $b]\n[$c $d]\n\ndet(A) = $det\n\nA⁻¹ = (1/det) × [d  -b]\n               [-c  a]\n\nA⁻¹ = [$invA $invB]\n      [$invC $invD]\n\nCheck: A × A⁻¹ = I";
    }
    return "Invalid matrix format";
  }

  String _dotProduct() {
    String vectors = _matrixAController.text.trim();
    List<String> vecs = vectors.split('\n');
    if (vecs.length < 2) return "Enter two vectors:\nVector1: a b c\nVector2: d e f";
    
    List<double> v1 = vecs[0].split(' ').map((e) => double.tryParse(e) ?? 0).toList();
    List<double> v2 = vecs[1].split(' ').map((e) => double.tryParse(e) ?? 0).toList();
    
    if (v1.length != v2.length) return "Vectors must have same dimension";
    
    double dot = 0;
    for (int i = 0; i < v1.length; i++) {
      dot += v1[i] * v2[i];
    }
    
    return "v₁ = ${v1}\nv₂ = ${v2}\n\nDot Product = $dot\n\nv₁·v₂ = ${v1.map((e) => e.toString()).join(' × ')} = $dot";
  }

  String _crossProduct() {
    String vectors = _matrixAController.text.trim();
    List<String> vecs = vectors.split('\n');
    if (vecs.length < 2) return "Enter two 3D vectors:\nVector1: x y z\nVector2: x y z";
    
    List<double> v1 = vecs[0].split(' ').map((e) => double.tryParse(e) ?? 0).toList();
    List<double> v2 = vecs[1].split(' ').map((e) => double.tryParse(e) ?? 0).toList();
    
    if (v1.length < 3 || v2.length < 3) return "Cross product requires 3D vectors";
    
    double x = v1[1] * v2[2] - v1[2] * v2[1];
    double y = v1[2] * v2[0] - v1[0] * v2[2];
    double z = v1[0] * v2[1] - v1[1] * v2[0];
    
    return "v₁ = ${v1}\nv₂ = ${v2}\n\nCross Product = [$x, $y, $z]\n\nv₁ × v₂ = |i   j   k  |\n          |${v1[0]} ${v1[1]} ${v1[2]}|\n          |${v2[0]} ${v2[1]} ${v2[2]}|";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedOperation,
            items: _operations.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
            onChanged: (value) => setState(() => _selectedOperation = value!),
            decoration: const InputDecoration(labelText: 'Linear Algebra Operation'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _matrixAController,
            decoration: InputDecoration(
              labelText: _getMatrixLabel(),
              hintText: _getMatrixHint(),
              border: const OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          if (_selectedOperation.contains('Matrix') || _selectedOperation.contains('Dot') || _selectedOperation.contains('Cross'))
            const SizedBox(height: 8),
          if (_selectedOperation.contains('Matrix') && !_selectedOperation.contains('Determinant') && !_selectedOperation.contains('Inverse'))
            TextField(
              controller: _matrixBController,
              decoration: const InputDecoration(
                labelText: 'Matrix B',
                hintText: 'Enter second matrix...',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _compute,
            icon: const Icon(Icons.calculate),
            label: const Text('Compute'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _output.isEmpty ? 'Result will appear here...' : _output,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMatrixLabel() {
    if (_selectedOperation == 'Dot Product' || _selectedOperation == 'Cross Product (3D)') {
      return 'Vectors (one per line)';
    }
    if (_selectedOperation.contains('Determinant') || _selectedOperation.contains('Inverse')) {
      return 'Matrix';
    }
    return 'Matrix A';
  }

  String _getMatrixHint() {
    if (_selectedOperation == 'Dot Product') {
      return 'Vector1: 1 2 3\nVector2: 4 5 6';
    }
    if (_selectedOperation == 'Cross Product (3D)') {
      return 'Vector1: 1 0 0\nVector2: 0 1 0';
    }
    if (_selectedOperation == 'Determinant (2x2)') {
      return 'Row1: 1 2\nRow2: 3 4';
    }
    if (_selectedOperation == 'Determinant (3x3)') {
      return 'Row1: 1 2 3\nRow2: 4 5 6\nRow3: 7 8 9';
    }
    return 'Row1: a b c\nRow2: d e f';
  }
}

// ==================== 5. STATISTICS PAGE ====================
class StatisticsPage extends StatefulWidget {
  const StatisticsPage({super.key});

  @override
  State<StatisticsPage> createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  final TextEditingController _dataController = TextEditingController();
  String _output = '';
  String _selectedOperation = 'Mean';

  final List<String> _operations = [
    'Mean',
    'Median',
    'Mode',
    'Range',
    'Variance',
    'Standard Deviation',
    'Quartiles',
    'Percentile',
    'Correlation',
    'Regression Line',
  ];

  List<double> _parseData() {
    String text = _dataController.text.trim();
    List<double> data = [];
    for (String num in text.split(RegExp(r'[,\s]+'))) {
      double? value = double.tryParse(num);
      if (value != null) data.add(value);
    }
    return data;
  }

  void _compute() {
    List<double> data = _parseData();
    if (data.isEmpty) {
      setState(() => _output = 'Please enter numeric data (comma or space separated)');
      return;
    }

    setState(() {
      switch (_selectedOperation) {
        case 'Mean':
          _output = _mean(data);
          break;
        case 'Median':
          _output = _median(data);
          break;
        case 'Mode':
          _output = _mode(data);
          break;
        case 'Range':
          _output = _range(data);
          break;
        case 'Variance':
          _output = _variance(data);
          break;
        case 'Standard Deviation':
          _output = _stdDev(data);
          break;
        case 'Quartiles':
          _output = _quartiles(data);
          break;
        case 'Percentile':
          _output = _percentile(data);
          break;
        case 'Correlation':
          _output = _correlation();
          break;
        case 'Regression Line':
          _output = _regression();
          break;
      }
    });
  }

  String _mean(List<double> data) {
    double sum = data.reduce((a, b) => a + b);
    double mean = sum / data.length;
    return "Data: ${data.join(', ')}\n\nMean = $mean\n\nSum = $sum\nn = ${data.length}";
  }

  String _median(List<double> data) {
    List<double> sorted = List.from(data)..sort();
    double median;
    if (sorted.length % 2 == 0) {
      median = (sorted[sorted.length ~/ 2 - 1] + sorted[sorted.length ~/ 2]) / 2;
    } else {
      median = sorted[sorted.length ~/ 2];
    }
    return "Data: ${data.join(', ')}\nSorted: ${sorted.join(', ')}\n\nMedian = $median";
  }

  String _mode(List<double> data) {
    Map<double, int> freq = {};
    for (var d in data) {
      freq[d] = (freq[d] ?? 0) + 1;
    }
    int maxFreq = freq.values.reduce(math.max);
    List<double> modes = freq.entries.where((e) => e.value == maxFreq).map((e) => e.key).toList();
    
    return "Data: ${data.join(', ')}\n\nMode = ${modes.join(', ')}\nFrequency = $maxFreq";
  }

  String _range(List<double> data) {
    double min = data.reduce(math.min);
    double max = data.reduce(math.max);
    double range = max - min;
    return "Data: ${data.join(', ')}\n\nMin = $min\nMax = $max\nRange = $range";
  }

  String _variance(List<double> data) {
    double mean = data.reduce((a, b) => a + b) / data.length;
    double sumSq = data.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b);
    double variance = sumSq / (data.length - 1);
    return "Data: ${data.join(', ')}\n\nMean = ${mean.toStringAsFixed(4)}\nSum of squares = ${sumSq.toStringAsFixed(4)}\n\nSample Variance = ${variance.toStringAsFixed(4)}\nPopulation Variance = ${(sumSq / data.length).toStringAsFixed(4)}";
  }

  String _stdDev(List<double> data) {
    double mean = data.reduce((a, b) => a + b) / data.length;
    double sumSq = data.map((x) => math.pow(x - mean, 2)).reduce((a, b) => a + b);
    double stdDev = math.sqrt(sumSq / (data.length - 1));
    return "Data: ${data.join(', ')}\n\nStandard Deviation = ${stdDev.toStringAsFixed(4)}\n\nInterpretation:\n• ~68% of data within mean ± 1σ\n• ~95% within mean ± 2σ\n• ~99.7% within mean ± 3σ";
  }

  String _quartiles(List<double> data) {
    List<double> sorted = List.from(data)..sort();
    double q1 = _percentileValue(sorted, 25);
    double q2 = _percentileValue(sorted, 50);
    double q3 = _percentileValue(sorted, 75);
    double iqr = q3 - q1;
    
    return "Data: ${data.join(', ')}\n\nQ₁ (25th) = $q1\nQ₂ (50th/Median) = $q2\nQ₃ (75th) = $q3\n\nInterquartile Range (IQR) = $iqr\n\nLower Fence = ${q1 - 1.5 * iqr}\nUpper Fence = ${q3 + 1.5 * iqr}";
  }

  String _percentile(List<double> data) {
    return "Percentile Calculator\n\nEnter data and specify percentile in second line\nExample:\n1 2 3 4 5 6 7 8 9 10\n90\n\nThis returns the 90th percentile value.";
  }

  double _percentileValue(List<double> sorted, double p) {
    double rank = (p / 100) * (sorted.length - 1);
    int lower = rank.floor();
    int upper = rank.ceil();
    if (lower == upper) return sorted[lower];
    return sorted[lower] + (rank - lower) * (sorted[upper] - sorted[lower]);
  }

  String _correlation() {
    return "Correlation Coefficient (r)\n\nMeasures linear relationship between two variables.\n\nr = 1: Perfect positive correlation\nr = -1: Perfect negative correlation\nr = 0: No linear correlation\n\nEnter paired data (x,y):\nX: 1 2 3 4 5\nY: 2 4 6 8 10";
  }

  String _regression() {
    return "Linear Regression\n\ny = mx + b\n\nm = slope (rate of change)\nb = y-intercept\n\nEnter paired data (x,y):\nX: 1 2 3 4 5\nY: 2 4 6 8 10";
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedOperation,
            items: _operations.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
            onChanged: (value) => setState(() => _selectedOperation = value!),
            decoration: const InputDecoration(labelText: 'Statistical Operation'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _dataController,
            decoration: InputDecoration(
              labelText: _selectedOperation == 'Correlation' || _selectedOperation == 'Regression Line' ? 'X and Y values' : 'Data',
              hintText: _getDataHint(),
              border: const OutlineInputBorder(),
            ),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _compute,
            icon: const Icon(Icons.show_chart),
            label: const Text('Calculate'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _output.isEmpty ? 'Result will appear here...' : _output,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDataHint() {
    if (_selectedOperation == 'Correlation' || _selectedOperation == 'Regression Line') {
      return 'X: 1 2 3 4 5\nY: 2 4 6 8 10';
    }
    return 'Enter numbers separated by spaces or commas\nExample: 10 20 30 40 50';
  }
}

// ==================== 6. TRIGONOMETRY PAGE ====================
class TrigonometryPage extends StatefulWidget {
  const TrigonometryPage({super.key});

  @override
  State<TrigonometryPage> createState() => _TrigonometryPageState();
}

class _TrigonometryPageState extends State<TrigonometryPage> {
  final TextEditingController _valueController = TextEditingController();
  String _output = '';
  String _selectedOperation = 'sin';
  String _angleUnit = 'Degrees';

  final List<String> _functions = ['sin', 'cos', 'tan', 'csc', 'sec', 'cot', 'arcsin', 'arccos', 'arctan'];
  final List<String> _units = ['Degrees', 'Radians'];

  void _compute() {
    double? value = double.tryParse(_valueController.text.trim());
    if (value == null) {
      setState(() => _output = 'Please enter a numeric value');
      return;
    }

    setState(() {
      double radians = _angleUnit == 'Degrees' ? value * math.pi / 180 : value;
      
      switch (_selectedOperation) {
        case 'sin':
          _output = _trigResult('sin', value, math.sin(radians));
          break;
        case 'cos':
          _output = _trigResult('cos', value, math.cos(radians));
          break;
        case 'tan':
          double result = math.tan(radians);
          _output = _trigResult('tan', value, result);
          break;
        case 'csc':
          double result = 1 / math.sin(radians);
          _output = _trigResult('csc', value, result);
          break;
        case 'sec':
          double result = 1 / math.cos(radians);
          _output = _trigResult('sec', value, result);
          break;
        case 'cot':
          double result = 1 / math.tan(radians);
          _output = _trigResult('cot', value, result);
          break;
        case 'arcsin':
          if (value >= -1 && value <= 1) {
            double result = math.asin(value);
            _output = _inverseTrigResult('arcsin', value, result);
          } else {
            _output = 'arcsin domain: [-1, 1]';
          }
          break;
        case 'arccos':
          if (value >= -1 && value <= 1) {
            double result = math.acos(value);
            _output = _inverseTrigResult('arccos', value, result);
          } else {
            _output = 'arccos domain: [-1, 1]';
          }
          break;
        case 'arctan':
          double result = math.atan(value);
          _output = _inverseTrigResult('arctan', value, result);
          break;
      }
    });
  }

  String _trigResult(String func, double input, double result) {
    return "$func($input $angleUnit) = ${result.toStringAsFixed(6)}\n\n"
           "Exact value: ${_getExactValue(func, input)}\n\n"
           "${_getTrigInfo(func)}";
  }

  String _inverseTrigResult(String func, double input, double result) {
    double degrees = result * 180 / math.pi;
    return "$func($input) = ${result.toStringAsFixed(6)} radians = ${degrees.toStringAsFixed(2)}°\n\n"
           "${_getInverseTrigInfo(func)}";
  }

  String _getExactValue(String func, double input) {
    // Common exact values
    Map<String, Map<double, String>> exactValues = {
      'sin': {0: '0', 30: '1/2', 45: '√2/2', 60: '√3/2', 90: '1', 180: '0', 270: '-1', 360: '0'},
      'cos': {0: '1', 30: '√3/2', 45: '√2/2', 60: '1/2', 90: '0', 180: '-1', 270: '0', 360: '1'},
      'tan': {0: '0', 30: '1/√3', 45: '1', 60: '√3', 90: 'undefined', 180: '0', 270: 'undefined', 360: '0'},
    };
    
    if (exactValues.containsKey(func) && exactValues[func]!.containsKey(input)) {
      return "Exact: ${exactValues[func]![input]}";
    }
    return "";
  }

  String _getTrigInfo(String func) {
    Map<String, String> info = {
      'sin': 'sin(θ) = opposite/hypotenuse\nPeriod: 2π\nRange: [-1, 1]',
      'cos': 'cos(θ) = adjacent/hypotenuse\nPeriod: 2π\nRange: [-1, 1]',
      'tan': 'tan(θ) = sin/cos = opposite/adjacent\nPeriod: π\nRange: (-∞, ∞)',
      'csc': 'csc(θ) = 1/sin(θ)\nPeriod: 2π\nRange: (-∞, -1] ∪ [1, ∞)',
      'sec': 'sec(θ) = 1/cos(θ)\nPeriod: 2π\nRange: (-∞, -1] ∪ [1, ∞)',
      'cot': 'cot(θ) = 1/tan(θ) = cos/sin\nPeriod: π\nRange: (-∞, ∞)',
    };
    return info[func] ?? '';
  }

  String _getInverseTrigInfo(String func) {
    Map<String, String> info = {
      'arcsin': 'arcsin(x) = angle where sin = x\nDomain: [-1, 1]\nRange: [-π/2, π/2]',
      'arccos': 'arccos(x) = angle where cos = x\nDomain: [-1, 1]\nRange: [0, π]',
      'arctan': 'arctan(x) = angle where tan = x\nDomain: (-∞, ∞)\nRange: (-π/2, π/2)',
    };
    return info[func] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedOperation,
                  items: _functions.map((f) => DropdownMenuItem(value: f, child: Text(f))).toList(),
                  onChanged: (value) => setState(() => _selectedOperation = value!),
                  decoration: const InputDecoration(labelText: 'Function'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _angleUnit,
                  items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                  onChanged: (value) => setState(() => _angleUnit = value!),
                  decoration: const InputDecoration(labelText: 'Unit'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _valueController,
            decoration: InputDecoration(
              labelText: 'Value',
              hintText: 'Enter angle or value',
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _compute,
            icon: const Icon(Icons.calculate),
            label: const Text('Compute'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _output.isEmpty ? 'Result will appear here...' : _output,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 7. NUMBER THEORY PAGE ====================
class NumberTheoryPage extends StatefulWidget {
  const NumberTheoryPage({super.key});

  @override
  State<NumberTheoryPage> createState() => _NumberTheoryPageState();
}

class _NumberTheoryPageState extends State<NumberTheoryPage> {
  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _secondController = TextEditingController();
  String _output = '';
  String _selectedOperation = 'GCD';

  final List<String> _operations = [
    'GCD',
    'LCM',
    'Prime Factors',
    'Is Prime?',
    'Is Even/Odd',
    'Fibonacci',
    'Factorial',
    'Modulo',
    'Divisibility Check',
    'Perfect Number Check',
  ];

  void _compute() {
    String input = _inputController.text.trim();
    if (input.isEmpty) {
      setState(() => _output = 'Please enter a number');
      return;
    }

    setState(() {
      switch (_selectedOperation) {
        case 'GCD':
          _output = _gcd(input);
          break;
        case 'LCM':
          _output = _lcm(input);
          break;
        case 'Prime Factors':
          _output = _primeFactors(input);
          break;
        case 'Is Prime?':
          _output = _isPrimeNumber(input);
          break;
        case 'Is Even/Odd':
          _output = _evenOdd(input);
          break;
        case 'Fibonacci':
          _output = _fibonacci(input);
          break;
        case 'Factorial':
          _output = _factorial(input);
          break;
        case 'Modulo':
          _output = _modulo(input);
          break;
        case 'Divisibility Check':
          _output = _divisibility(input);
          break;
        case 'Perfect Number Check':
          _output = _perfectNumber(input);
          break;
      }
    });
  }

  String _gcd(String input) {
    List<String> nums = input.split(RegExp(r'[,\s]+'));
    if (nums.length < 2) return "Enter two numbers: 24 36";
    
    int a = int.parse(nums[0]);
    int b = int.parse(nums[1]);
    int gcd = _calculateGCD(a, b);
    
    return "GCD($a, $b) = $gcd\n\n"
           "Factors of $a: ${_getFactors(a)}\n"
           "Factors of $b: ${_getFactors(b)}\n\n"
           "Largest common factor = $gcd";
  }

  String _lcm(String input) {
    List<String> nums = input.split(RegExp(r'[,\s]+'));
    if (nums.length < 2) return "Enter two numbers: 12 18";
    
    int a = int.parse(nums[0]);
    int b = int.parse(nums[1]);
    int gcd = _calculateGCD(a, b);
    int lcm = (a * b) ~/ gcd;
    
    return "LCM($a, $b) = $lcm\n\n"
           "Formula: LCM(a,b) = (a × b) / GCD(a,b)\n"
           "= ($a × $b) / $gcd = $lcm";
  }

  String _primeFactors(String input) {
    int n = int.parse(input);
    List<int> factors = [];
    int temp = n;
    
    for (int i = 2; i <= temp; i++) {
      while (temp % i == 0) {
        factors.add(i);
        temp ~/= i;
      }
    }
    
    Map<int, int> factorCount = {};
    for (int f in factors) {
      factorCount[f] = (factorCount[f] ?? 0) + 1;
    }
    
    String result = factors.join(' × ');
    return "$n = $result\n\n"
           "Prime factorization: ${factorCount.entries.map((e) => '${e.key}^${e.value}').join(' × ')}";
  }

  String _isPrimeNumber(String input) {
    int n = int.parse(input);
    bool isPrime = _checkPrime(n);
    
    if (isPrime) {
      return "$n is PRIME\n\n"
             "✓ Only divisible by 1 and itself\n"
             "✓ ${n % 2 == 0 ? 'Even' : 'Odd'} number";
    } else {
      List<int> factors = [];
      for (int i = 2; i <= n ~/ 2; i++) {
        if (n % i == 0) factors.add(i);
      }
      return "$n is NOT prime\n\n"
             "Factors: ${_getFactors(n)}\n"
             "Divisible by: ${factors.join(', ')}";
    }
  }

  String _evenOdd(String input) {
    int n = int.parse(input);
    String parity = n % 2 == 0 ? 'Even' : 'Odd';
    return "$n is $parity\n\n"
           "${n % 2 == 0 ? 'Divisible by 2' : 'Not divisible by 2'}\n"
           "Next ${n % 2 == 0 ? 'odd' : 'even'}: ${n % 2 == 0 ? n + 1 : n + 1}\n"
           "Previous ${n % 2 == 0 ? 'odd' : 'even'}: ${n % 2 == 0 ? n - 1 : n - 1}";
  }

  String _fibonacci(String input) {
    int n = int.parse(input);
    if (n < 0) return "Please enter a positive number";
    
    List<int> fib = [];
    for (int i = 0; i <= n; i++) {
      if (i == 0) fib.add(0);
      else if (i == 1) fib.add(1);
      else fib.add(fib[i - 1] + fib[i - 2]);
    }
    
    return "Fibonacci($n) = ${fib[n]}\n\n"
           "Sequence: ${fib.join(', ')}\n\n"
           "F($n) = F(${n - 1}) + F(${n - 2})";
  }

  String _factorial(String input) {
    int n = int.parse(input);
    if (n < 0) return "Factorial not defined for negative numbers";
    if (n > 20) return "Number too large (max 20 for integer result)";
    
    BigInt result = BigInt.one;
    String calculation = "";
    for (int i = 2; i <= n; i++) {
      result *= BigInt.from(i);
      calculation += (i == 2 ? "2" : " × $i");
    }
    
    return "$n! = ${n == 0 ? "1" : result.toString()}\n\n"
           "${n}! = ${n == 0 ? "1" : "1 × $calculation"}\n\n"
           "Number of trailing zeros: ${_trailingZeros(n)}";
  }

  int _trailingZeros(int n) {
    int count = 0;
    for (int i = 5; n ~/ i >= 1; i *= 5) {
      count += n ~/ i;
    }
    return count;
  }

  String _modulo(String input) {
    List<String> nums = input.split(RegExp(r'[,\s]+'));
    if (nums.length < 2) return "Enter: a mod b (e.g., 17 5)";
    
    int a = int.parse(nums[0]);
    int b = int.parse(nums[1]);
    int result = a % b;
    
    return "$a mod $b = $result\n\n"
           "$a = ${(a ~/ b)} × $b + $result\n\n"
           "Also written as: $a ≡ $result (mod $b)";
  }

  String _divisibility(String input) {
    List<String> nums = input.split(RegExp(r'[,\s]+'));
    if (nums.length < 2) return "Enter: number divisor (e.g., 100 4)";
    
    int n = int.parse(nums[0]);
    int d = int.parse(nums[1]);
    bool divisible = n % d == 0;
    
    return "$n is ${divisible ? '' : 'NOT '}divisible by $d\n\n"
           "${n} ÷ ${d} = ${(n / d).toStringAsFixed(2)}\n"
           "Remainder = ${n % d}";
  }

  String _perfectNumber(String input) {
    int n = int.parse(input);
    List<int> properDivisors = [];
    for (int i = 1; i <= n ~/ 2; i++) {
      if (n % i == 0) properDivisors.add(i);
    }
    int sum = properDivisors.reduce((a, b) => a + b);
    bool isPerfect = sum == n;
    
    return "$n is ${isPerfect ? '' : 'NOT '}a perfect number\n\n"
           "Proper divisors: ${properDivisors.join(' + ')} = $sum\n\n"
           "${isPerfect ? '✓ Sum of proper divisors equals the number' : '✗ Sum of proper divisors does not equal the number'}\n\n"
           "Known perfect numbers: 6, 28, 496, 8128, 33550336...";
  }

  int _calculateGCD(int a, int b) {
    while (b != 0) {
      int t = b;
      b = a % b;
      a = t;
    }
    return a.abs();
  }

  bool _checkPrime(int n) {
    if (n <= 1) return false;
    if (n <= 3) return true;
    if (n % 2 == 0 || n % 3 == 0) return false;
    for (int i = 5; i * i <= n; i += 6) {
      if (n % i == 0 || n % (i + 2) == 0) return false;
    }
    return true;
  }

  String _getFactors(int n) {
    List<int> factors = [];
    for (int i = 1; i <= n; i++) {
      if (n % i == 0) factors.add(i);
    }
    return factors.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedOperation,
            items: _operations.map((op) => DropdownMenuItem(value: op, child: Text(op))).toList(),
            onChanged: (value) => setState(() => _selectedOperation = value!),
            decoration: const InputDecoration(labelText: 'Number Theory Operation'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _inputController,
            decoration: InputDecoration(
              labelText: _selectedOperation == 'Modulo' || _selectedOperation == 'Divisibility Check' ? 'a b' : 'Number(s)',
              hintText: _getNumberHint(),
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          if (_selectedOperation == 'Modulo' || _selectedOperation == 'Divisibility Check' || _selectedOperation == 'GCD' || _selectedOperation == 'LCM')
            const SizedBox(height: 8),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _compute,
            icon: const Icon(Icons.calculate),
            label: const Text('Compute'),
            style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _output.isEmpty ? 'Result will appear here...' : _output,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getNumberHint() {
    switch (_selectedOperation) {
      case 'GCD':
      case 'LCM':
        return 'Example: 24 36';
      case 'Modulo':
        return 'Example: 17 5 (calculates 17 mod 5)';
      case 'Divisibility Check':
        return 'Example: 100 4 (is 100 divisible by 4?)';
      case 'Prime Factors':
        return 'Example: 84';
      default:
        return 'Example: 17';
    }
  }
}

// ==================== 8. GRAPHING PAGE ====================
class GraphingPage extends StatefulWidget {
  const GraphingPage({super.key});

  @override
  State<GraphingPage> createState() => _GraphingPageState();
}

class _GraphingPageState extends State<GraphingPage> {
  final TextEditingController _equationController = TextEditingController(text: 'x^2');
  List<Offset> _points = [];
  double _minX = -5, _maxX = 5, _minY = -5, _maxY = 5;
  String _error = '';

  void _plotGraph() {
    setState(() {
      _error = '';
      _points = [];
      try {
        Parser parser = Parser();
        Expression exp = parser.parse(_equationController.text);
        ContextModel cm = ContextModel();
        
        for (double x = _minX; x <= _maxX; x += 0.02) {
          cm.bindVariable(Variable('x'), Number(x));
          double y = exp.evaluate(EvaluationType.REAL, cm);
          if (y.isFinite && y > -20 && y < 20) {
            _points.add(Offset(x, y));
          } else {
            _points.add(Offset(x, double.nan));
          }
        }
      } catch (e) {
        _error = 'Invalid equation: $e';
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

  @override
  void initState() {
    super.initState();
    _plotGraph();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _equationController,
                  decoration: InputDecoration(
                    labelText: 'f(x) = ',
                    hintText: 'x^2, sin(x), cos(x), e^x, ln(x)',
                    border: const OutlineInputBorder(),
                    errorText: _error.isNotEmpty ? _error : null,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: _plotGraph,
                child: const Text('Plot'),
              ),
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
              child: GestureDetector(
                onScaleUpdate: (details) {
                  if (details.scale != 1.0) {
                    _zoom(1 / details.scale);
                  }
                },
                child: CustomPaint(
                  painter: GraphingPainter(_points, _minX, _maxX, _minY, _maxY),
                  size: Size.infinite,
                ),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(onPressed: () => _zoom(0.8), icon: const Icon(Icons.zoom_in)),
            IconButton(onPressed: () => _zoom(1.2), icon: const Icon(Icons.zoom_out)),
            IconButton(onPressed: () {
              setState(() {
                _minX = -5; _maxX = 5; _minY = -5; _maxY = 5;
              });
              _plotGraph();
            }, icon: const Icon(Icons.refresh)),
          ],
        ),
      ],
    );
  }
}

class GraphingPainter extends CustomPainter {
  final List<Offset> points;
  final double minX, maxX, minY, maxY;

  GraphingPainter(this.points, this.minX, this.maxX, this.minY, this.maxY);

  double _mapX(double x, Size size) => (x - minX) / (maxX - minX) * size.width;
  double _mapY(double y, Size size) => size.height - (y - minY) / (maxY - minY) * size.height;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);
    
    Paint gridPaint = Paint()..color = Colors.grey.shade300..strokeWidth = 0.5;
    for (double x = minX; x <= maxX; x += 1) {
      double xPos = _mapX(x, size);
      canvas.drawLine(Offset(xPos, 0), Offset(xPos, size.height), gridPaint);
    }
    for (double y = minY; y <= maxY; y += 1) {
      double yPos = _mapY(y, size);
      canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), gridPaint);
    }
    
    Paint axisPaint = Paint()..color = Colors.black..strokeWidth = 1.5;
    double xAxisY = _mapY(0, size);
    if (xAxisY >= 0 && xAxisY <= size.height) {
      canvas.drawLine(Offset(0, xAxisY), Offset(size.width, xAxisY), axisPaint);
    }
    double yAxisX = _mapX(0, size);
    if (yAxisX >= 0 && yAxisX <= size.width) {
      canvas.drawLine(Offset(yAxisX, 0), Offset(yAxisX, size.height), axisPaint);
    }
    
    Paint linePaint = Paint()..color = Colors.blue..strokeWidth = 2.5;
    Path path = Path();
    bool first = true;
    for (var p in points) {
      if (p.dy.isNaN) { first = true; continue; }
      double x = _mapX(p.dx, size);
      double y = _mapY(p.dy, size);
      if (x >= 0 && x <= size.width && y >= 0 && y <= size.height) {
        if (first) { path.moveTo(x, y); first = false; }
        else { path.lineTo(x, y); }
      } else { first = true; }
    }
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}
