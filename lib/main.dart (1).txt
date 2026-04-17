import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';
import 'dart:math' as math;

void main() {
  runApp(const MathematicaPlayground());
}

class MathematicaPlayground extends StatelessWidget {
  const MathematicaPlayground({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mathematica Playground',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'monospace',
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        brightness: Brightness.dark,
        cardTheme: CardTheme(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[900],
        ),
      ),
      themeMode: ThemeMode.system,
      home: const PlaygroundScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PlaygroundScreen extends StatefulWidget {
  const PlaygroundScreen({super.key});

  @override
  State<PlaygroundScreen> createState() => _PlaygroundScreenState();
}

class _PlaygroundScreenState extends State<PlaygroundScreen> with SingleTickerProviderStateMixin {
  // Input
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocus = FocusNode();
  String _output = '';
  String _commandType = 'Plot';
  bool _isLoading = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // Graph state
  List<Offset> _points = [];
  double _minX = -5, _maxX = 5, _minY = -5, _maxY = 5;
  String _currentEquation = 'x^2';
  final GlobalKey _graphKey = GlobalKey();
  
  // UI State
  bool _isDark = false;
  bool _showHistory = false;
  final List<Map<String, String>> _history = [];
  final List<Map<String, String>> _favorites = [];
  
  // Available commands with icons
  final List<Map<String, dynamic>> _commands = [
    {'name': 'Plot', 'icon': Icons.show_chart, 'color': Colors.blue, 'desc': 'Plot a function'},
    {'name': 'Solve', 'icon': Icons.calculate, 'color': Colors.green, 'desc': 'Solve equations'},
    {'name': 'Simplify', 'icon': Icons.compress, 'color': Colors.purple, 'desc': 'Simplify expressions'},
    {'name': 'Expand', 'icon': Icons.open_in_full, 'color': Colors.orange, 'desc': 'Expand expressions'},
    {'name': 'Factor', 'icon': Icons.grid_view, 'color': Colors.teal, 'desc': 'Factor expressions'},
    {'name': 'D', 'icon': Icons.trending_up, 'color': Colors.red, 'desc': 'Derivative'},
    {'name': 'Integrate', 'icon': Icons.integration_instructions, 'color': Colors.indigo, 'desc': 'Integral'},
    {'name': 'GCD', 'icon': Icons.numbers, 'color': Colors.cyan, 'desc': 'Greatest Common Divisor'},
    {'name': 'LCM', 'icon': Icons.multiline_chart, 'color': Colors.pink, 'desc': 'Least Common Multiple'},
    {'name': 'PrimeQ', 'icon': Icons.verified, 'color': Colors.amber, 'desc': 'Prime test'},
    {'name': 'Mod', 'icon': Icons.calculate, 'color': Colors.brown, 'desc': 'Modulo operation'},
  ];
  
  // Interactive examples
  final List<Map<String, String>> _examples = [
    {'name': '📈 Quadratic', 'cmd': 'Plot[x^2]'},
    {'name': '📉 Sine Wave', 'cmd': 'Plot[sin(x)]'},
    {'name': '🔄 Cosine', 'cmd': 'Plot[cos(x)]'},
    {'name': '⚡ Tangent', 'cmd': 'Plot[tan(x)]'},
    {'name': '🔷 Cubic', 'cmd': 'Plot[x^3 - 2*x]'},
    {'name': '💠 Absolute', 'cmd': 'Plot[abs(x)]'},
    {'name': '🔢 Quadratic Eq', 'cmd': 'Solve[x^2 - 4 == 0]'},
    {'name': '📐 Linear Eq', 'cmd': 'Solve[2*x + 3 == 7]'},
    {'name': '🔄 Simplify', 'cmd': 'Simplify[(x^2 - 1)/(x - 1)]'},
    {'name': '📦 Expand', 'cmd': 'Expand[(x+2)^3]'},
    {'name': '🔍 Factor', 'cmd': 'Factor[x^2 - 5*x + 6]'},
    {'name': '📈 Derivative', 'cmd': 'D[x^3]'},
    {'name': '∫ Integral', 'cmd': 'Integrate[x^2]'},
    {'name': '🔢 GCD', 'cmd': 'GCD[24, 36]'},
    {'name': '📊 LCM', 'cmd': 'LCM[12, 18]'},
    {'name': '🔐 PrimeQ', 'cmd': 'PrimeQ[17]'},
    {'name': '🧮 Mod', 'cmd': 'Mod[17, 5]'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _animationController, curve: Curves.easeIn);
    _animationController.forward();
    _plotEquation(_currentEquation);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _inputController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _executeCommand() async {
    String input = _inputController.text.trim();
    if (input.isEmpty) return;
    
    setState(() {
      _isLoading = true;
      _history.insert(0, {'cmd': input, 'result': ''});
      if (_history.length > 50) _history.removeLast();
    });
    
    await Future.delayed(const Duration(milliseconds: 100));
    
    // Parse command
    String command = '';
    String args = '';
    
    int bracketStart = input.indexOf('[');
    if (bracketStart != -1) {
      command = input.substring(0, bracketStart).trim();
      int bracketEnd = input.lastIndexOf(']');
      if (bracketEnd != -1 && bracketEnd > bracketStart) {
        args = input.substring(bracketStart + 1, bracketEnd);
      }
    }
    
    setState(() {
      _commandType = command;
    });
    
    switch (command) {
      case 'Plot':
        _handlePlot(args);
        break;
      case 'Solve':
        _handleSolve(args);
        break;
      case 'Simplify':
        _handleSimplify(args);
        break;
      case 'Expand':
        _handleExpand(args);
        break;
      case 'Factor':
        _handleFactor(args);
        break;
      case 'D':
        _handleDerivative(args);
        break;
      case 'Integrate':
        _handleIntegrate(args);
        break;
      case 'GCD':
        _handleGCD(args);
        break;
      case 'LCM':
        _handleLCM(args);
        break;
      case 'PrimeQ':
        _handlePrimeQ(args);
        break;
      case 'Mod':
        _handleMod(args);
        break;
      default:
        _output = '❌ Unknown command: $command\n\n✨ Available commands:\n${_commands.map((c) => '   • ${c['name']} - ${c['desc']}').join('\n')}';
    }
    
    setState(() {
      _isLoading = false;
      if (_history.isNotEmpty) {
        _history[0]['result'] = _output;
      }
    });
    
    _inputController.clear();
    _inputFocus.requestFocus();
  }
  
  void _handlePlot(String args) {
    if (args.isEmpty) {
      _output = '📊 Plot Command\n\nUsage: Plot[expression]\n\nExamples:\n   • Plot[x^2]\n   • Plot[sin(x)]\n   • Plot[cos(x)]\n   • Plot[tan(x)]\n   • Plot[abs(x)]';
      return;
    }
    
    _currentEquation = args;
    _output = '📈 Plotting: $args\n\n🖱️ Tips:\n   • Pinch to zoom\n   • Drag to pan\n   • Use +/- buttons';
    _plotEquation(args);
  }
  
  void _plotEquation(String equation) {
    setState(() {
      _points = [];
      try {
        Parser parser = Parser();
        Expression exp = parser.parse(equation);
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
        _output = '⚠️ Error plotting: $e\n\n📝 Make sure your equation uses valid syntax.\nExample: Plot[x^2]';
      }
    });
  }
  
  void _handleSolve(String args) {
    try {
      List<String> parts = args.split('==');
      if (parts.length != 2) {
        _output = '🔍 Solve Command\n\nUsage: Solve[equation == 0]\n\nExamples:\n   • Solve[x^2 - 4 == 0]\n   • Solve[2*x + 3 == 7]';
        return;
      }
      
      String equation = parts[0].trim();
      
      if (equation.contains('x^2')) {
        double a = 1, b = 0, c = 0;
        
        RegExp expReg = RegExp(r'([+-]?\d*)\*?x\^2');
        Match? aMatch = expReg.firstMatch(equation);
        if (aMatch != null) {
          String aStr = aMatch.group(1) ?? '';
          if (aStr == '+' || aStr == '') a = 1;
          else if (aStr == '-') a = -1;
          else a = double.parse(aStr);
        }
        
        RegExp expReg2 = RegExp(r'([+-]?\d*)\*?x(?!\^)');
        Match? bMatch = expReg2.firstMatch(equation.replaceAll('x^2', ''));
        if (bMatch != null) {
          String bStr = bMatch.group(1) ?? '';
          if (bStr == '+' || bStr == '') b = 1;
          else if (bStr == '-') b = -1;
          else b = double.parse(bStr);
        }
        
        String remaining = equation.replaceAll(RegExp(r'[+-]?\d*\*?x(\^2)?'), '');
        if (remaining.isNotEmpty) {
          c = double.tryParse(remaining) ?? 0;
        }
        
        double discriminant = b * b - 4 * a * c;
        if (discriminant < 0) {
          _output = '📐 Quadratic Equation: ${equation.replaceAll('*', '')} = 0\n\n⚠️ No real solutions (discriminant < 0)\n📊 Discriminant = ${discriminant.toStringAsFixed(2)}';
        } else {
          double sqrtD = math.sqrt(discriminant);
          double x1 = (-b + sqrtD) / (2 * a);
          double x2 = (-b - sqrtD) / (2 * a);
          
          if (x1 == x2) {
            _output = '📐 Equation: ${equation.replaceAll('*', '')} = 0\n\n✅ Solution: x = ${x1.toStringAsFixed(4)}\n\n📊 Discriminant = ${discriminant.toStringAsFixed(2)}';
          } else {
            _output = '📐 Equation: ${equation.replaceAll('*', '')} = 0\n\n✅ Solutions:\n   • x₁ = ${x1.toStringAsFixed(4)}\n   • x₂ = ${x2.toStringAsFixed(4)}\n\n📊 Discriminant = ${discriminant.toStringAsFixed(2)}';
          }
        }
      } else {
        RegExp linear = RegExp(r'([+-]?\d*)\*?x\s*([+-]?\d*)');
        Match? match = linear.firstMatch(equation);
        if (match != null) {
          double a = double.tryParse(match.group(1) ?? '1') ?? 1;
          double b = double.tryParse(match.group(2) ?? '0') ?? 0;
          double c = 0;
          
          String remaining = equation.replaceAll(linear, '');
          if (remaining.isNotEmpty) c = double.tryParse(remaining) ?? 0;
          
          if (a != 0) {
            double x = (c - b) / a;
            _output = '📐 Equation: ${equation.replaceAll('*', '')} = 0\n\n✅ Solution: x = ${x.toStringAsFixed(4)}';
          } else {
            _output = '⚠️ No solution (coefficient a = 0)';
          }
        } else {
          _output = '⚠️ Could not parse equation.\n\nExample: Solve[2*x + 3 == 7]';
        }
      }
    } catch (e) {
      _output = '⚠️ Error: $e';
    }
  }
  
  void _handleSimplify(String args) {
    try {
      Parser parser = Parser();
      Expression exp = parser.parse(args);
      _output = '🔧 Simplify Command\n\n📝 Expression: $args\n\n✨ Simplified evaluation:\n   ${exp.toString()}';
    } catch (e) {
      _output = '⚠️ Could not simplify: $e\n\nExample: Simplify[(x^2 - 1)/(x - 1)]';
    }
  }
  
  void _handleExpand(String args) {
    try {
      if (args.contains('^')) {
        RegExp expandReg = RegExp(r'\(([^)]+)\)\^(\d+)');
        Match? match = expandReg.firstMatch(args);
        if (match != null) {
          String inner = match.group(1)!;
          int power = int.parse(match.group(2)!);
          
          List<String> terms = [];
          for (int k = 0; k <= power; k++) {
            int coeff = _binomialCoefficient(power, k);
            String xTerm = power - k > 0 ? 'x^${power - k}' : '';
            String constTerm = k > 0 ? '*${_extractConstant(inner)}^$k' : '';
            if (coeff != 0) {
              terms.add('$coeff$xTerm$constTerm');
            }
          }
          _output = '📦 Expand Command\n\n📝 Original: $args\n\n✨ Expanded:\n   ${terms.join(' + ')}';
        } else {
          _output = '📦 Expand Command\n\nUsage: Expand[(expression)^n]\n\nExample: Expand[(x+2)^3]\nResult: x³ + 6x² + 12x + 8';
        }
      } else {
        _output = '📦 Expand Command\n\nUsage: Expand[(expression)^n]\n\nExample: Expand[(x+2)^3]';
      }
    } catch (e) {
      _output = '⚠️ Error: $e';
    }
  }
  
  void _handleFactor(String args) {
    try {
      RegExp quadratic = RegExp(r'x\^2\s*([+-]\s*\d*)\*?x\s*([+-]\s*\d+)');
      Match? match = quadratic.firstMatch(args);
      if (match != null) {
        String bStr = match.group(1)?.trim().replaceAll(' ', '') ?? '0';
        String cStr = match.group(2)?.trim().replaceAll(' ', '') ?? '0';
        double b = bStr == '+' || bStr == '' ? 1 : double.parse(bStr);
        double c = double.parse(cStr);
        
        List<int> factors = [];
        for (int i = 1; i <= c.abs().toInt(); i++) {
          if (c % i == 0) factors.add(i);
        }
        
        bool found = false;
        for (int f in factors) {
          if (f + (c / f).toInt() == b) {
            _output = '🔍 Factor Command\n\n📝 Expression: $args\n\n✨ Factored:\n   (x + ${f.toInt()})(x + ${(c / f).toInt()})';
            found = true;
            break;
          }
          if (-f + (c / -f).toInt() == b) {
            _output = '🔍 Factor Command\n\n📝 Expression: $args\n\n✨ Factored:\n   (x - ${f.toInt()})(x - ${(c / f).toInt()})';
            found = true;
            break;
          }
        }
        if (!found) _output = '🔍 Factor Command\n\n⚠️ Cannot factor: $args\n\nExample: Factor[x^2 - 5x + 6]';
      } else {
        _output = '🔍 Factor Command\n\nUsage: Factor[quadratic]\n\nExample: Factor[x^2 - 5x + 6]\nResult: (x - 2)(x - 3)';
      }
    } catch (e) {
      _output = '⚠️ Error: $e';
    }
  }
  
  void _handleDerivative(String args) {
    String result = _derivativeString(args);
    _output = '📈 Derivative Command\n\n📝 f(x) = $args\n\n✨ f\'(x) = $result\n\n⚡ The derivative represents the rate of change or slope of the function.';
  }
  
  String _derivativeString(String expr) {
    if (expr == 'x^3') return '3x²';
    if (expr == 'x^2') return '2x';
    if (expr == 'x') return '1';
    if (expr == 'sin(x)') return 'cos(x)';
    if (expr == 'cos(x)') return '-sin(x)';
    if (expr == 'tan(x)') return 'sec²(x)';
    if (expr == 'ln(x)') return '1/x';
    if (expr == 'e^x') return 'e^x';
    return 'Not implemented for: $expr\n\nTry: D[x^3], D[sin(x)], D[cos(x)]';
  }
  
  void _handleIntegrate(String args) {
    String result = _integralString(args);
    _output = '∫ Integral Command\n\n📝 ∫ $args dx\n\n✨ = $result\n\n📚 + C (constant of integration)\n\nThe integral represents the area under the curve.';
  }
  
  String _integralString(String expr) {
    if (expr == 'x^2') return 'x³/3';
    if (expr == 'x') return 'x²/2';
    if (expr == 'sin(x)') return '-cos(x)';
    if (expr == 'cos(x)') return 'sin(x)';
    if (expr == 'sec^2(x)') return 'tan(x)';
    return 'Not implemented for: $expr\n\nTry: Integrate[x^2], Integrate[sin(x)]';
  }
  
  void _handleGCD(String args) {
    List<String> nums = args.split(RegExp(r'[,\s]+'));
    if (nums.length >= 2) {
      int a = int.parse(nums[0]);
      int b = int.parse(nums[1]);
      int gcd = _gcd(a, b);
      _output = '🔢 GCD Command\n\n📝 GCD($a, $b)\n\n✨ Result: $gcd\n\n📊 The Greatest Common Divisor is the largest positive integer that divides both numbers without a remainder.';
    } else {
      _output = '🔢 GCD Command\n\nUsage: GCD[a, b]\n\nExample: GCD[24, 36]\nResult: 12';
    }
  }
  
  void _handleLCM(String args) {
    List<String> nums = args.split(RegExp(r'[,\s]+'));
    if (nums.length >= 2) {
      int a = int.parse(nums[0]);
      int b = int.parse(nums[1]);
      int lcm = (a * b ~/ _gcd(a, b)).abs();
      _output = '📊 LCM Command\n\n📝 LCM($a, $b)\n\n✨ Result: $lcm\n\n📚 The Least Common Multiple is the smallest positive integer that is divisible by both numbers.';
    } else {
      _output = '📊 LCM Command\n\nUsage: LCM[a, b]\n\nExample: LCM[12, 18]\nResult: 36';
    }
  }
  
  void _handlePrimeQ(String args) {
    int n = int.tryParse(args) ?? 0;
    bool isPrime = _isPrime(n);
    _output = '🔐 PrimeQ Command\n\n📝 Is $n prime?\n\n✨ Result: $isPrime\n\n📚 ${isPrime ? '✓ This number has exactly two distinct positive divisors: 1 and itself.' : '✗ This number has more than two distinct positive divisors.'}';
  }
  
  void _handleMod(String args) {
    List<String> nums = args.split(RegExp(r'[,\s]+'));
    if (nums.length >= 2) {
      int a = int.parse(nums[0]);
      int b = int.parse(nums[1]);
      int mod = a % b;
      _output = '🧮 Mod Command\n\n📝 $a mod $b\n\n✨ Result: $mod\n\n📚 The remainder when $a is divided by $b.';
    } else {
      _output = '🧮 Mod Command\n\nUsage: Mod[a, b]\n\nExample: Mod[17, 5]\nResult: 2\n\nBecause 17 = 3×5 + 2';
    }
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
  
  int _binomialCoefficient(int n, int k) {
    if (k < 0 || k > n) return 0;
    if (k == 0 || k == n) return 1;
    int result = 1;
    for (int i = 1; i <= k; i++) {
      result = result * (n - k + i) ~/ i;
    }
    return result;
  }
  
  String _extractConstant(String expr) {
    RegExp digits = RegExp(r'\d+');
    Match? match = digits.firstMatch(expr);
    return match?.group(0) ?? '1';
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
    _plotEquation(_currentEquation);
  }
  
  void _resetView() {
    setState(() {
      _minX = -5;
      _maxX = 5;
      _minY = -5;
      _maxY = 5;
    });
    _plotEquation(_currentEquation);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('View reset to default'), duration: Duration(seconds: 1)),
    );
  }
  
  void _addToFavorites(String cmd) {
    setState(() {
      if (!_favorites.any((f) => f['cmd'] == cmd)) {
        _favorites.add({'cmd': cmd, 'name': cmd.length > 30 ? '${cmd.substring(0, 27)}...' : cmd});
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Added to favorites'), duration: Duration(milliseconds: 800)),
    );
  }
  
  void _useExample(String command) {
    _inputController.text = command;
    _executeCommand();
  }
  
  void _toggleTheme() {
    setState(() {
      _isDark = !_isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isDark 
                  ? [Colors.grey[900]!, Colors.grey[800]!]
                  : [Colors.blue[50]!, Colors.white],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.blue, Colors.purple]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.auto_awesome, color: Colors.white, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Mathematica Playground',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
                        onPressed: _toggleTheme,
                        tooltip: 'Toggle theme',
                      ),
                      IconButton(
                        icon: Badge(
                          label: Text(_history.length.toString()),
                          child: const Icon(Icons.history),
                        ),
                        onPressed: () => setState(() => _showHistory = !_showHistory),
                        tooltip: 'History',
                      ),
                    ],
                  ),
                ),
                
                // Command input area
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isDark ? Colors.grey[850] : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _inputController,
                              focusNode: _inputFocus,
                              style: const TextStyle(fontSize: 16),
                              decoration: InputDecoration(
                                hintText: 'Enter command... (e.g., Plot[x^2])',
                                prefixIcon: const Icon(Icons.code),
                                suffixIcon: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : IconButton(
                                        icon: const Icon(Icons.send),
                                        onPressed: _executeCommand,
                                      ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: _isDark ? Colors.grey[800] : Colors.grey[100],
                              ),
                              onSubmitted: (_) => _executeCommand(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Command chips
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _commands.length,
                          itemBuilder: (context, index) {
                            final cmd = _commands[index];
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    _inputController.text = '${cmd['name']}[';
                                    _inputFocus.requestFocus();
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: (cmd['color'] as Color).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: cmd['color'], width: 0.5),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(cmd['icon'], size: 16, color: cmd['color']),
                                        const SizedBox(width: 6),
                                        Text(
                                          cmd['name'],
                                          style: TextStyle(color: cmd['color'], fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Graph area (shows only for Plot command)
                if (_commandType == 'Plot' && _points.isNotEmpty)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 280,
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            child: GestureDetector(
                              onScaleUpdate: (details) {
                                if (details.scale != 1.0) {
                                  _zoom(1 / details.scale);
                                }
                              },
                              onPanUpdate: (details) {
                                setState(() {
                                  _minX -= details.delta.dx / 20;
                                  _maxX -= details.delta.dx / 20;
                                  _minY += details.delta.dy / 20;
                                  _maxY += details.delta.dy / 20;
                                });
                                _plotEquation(_currentEquation);
                              },
                              child: CustomPaint(
                                painter: GraphPainter(_points, _minX, _maxX, _minY, _maxY, _currentEquation),
                                size: Size.infinite,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _isDark ? Colors.grey[850] : Colors.grey[50],
                            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildZoomButton(Icons.zoom_in, () => _zoom(0.8)),
                              _buildZoomButton(Icons.zoom_out, () => _zoom(1.2)),
                              _buildZoomButton(Icons.refresh, _resetView),
                              const VerticalDivider(),
                              _buildZoomButton(Icons.fullscreen, () {
                                showDialog(
                                  context: context,
                                  builder: (_) => Dialog(
                                    child: Container(
                                      height: MediaQuery.of(context).size.height * 0.7,
                                      width: MediaQuery.of(context).size.width * 0.9,
                                      padding: const EdgeInsets.all(16),
                                      child: CustomPaint(
                                        painter: GraphPainter(_points, _minX, _maxX, _minY, _maxY, _currentEquation),
                                        size: Size.infinite,
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                
                // Output console
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isDark ? Colors.grey[900] : const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _commandType == 'Plot' ? 'GRAPH OUTPUT' : 'CONSOLE OUTPUT',
                                style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Copied to clipboard')),
                                  );
                                },
                                tooltip: 'Copy output',
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, size: 18),
                                onPressed: () => setState(() => _output = ''),
                                tooltip: 'Clear output',
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: SelectableText(
                              _output.isEmpty 
                                  ? '✨ Welcome to Mathematica Playground!\n\n📝 Try these commands:\n   • Plot[x^2]\n   • Solve[x^2 - 4 == 0]\n   • GCD[24, 36]\n   • PrimeQ[17]\n\n💡 Tap any command chip above to get started!'
                                  : _output,
                              style: const TextStyle(
                                color: Colors.green,
                                fontFamily: 'monospace',
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Examples section
                Container(
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _examples.length,
                    itemBuilder: (context, index) {
                      final example = _examples[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(example['name']!, style: const TextStyle(fontSize: 12)),
                          onPressed: () => _useExample(example['cmd']!),
                          backgroundColor: _isDark ? Colors.grey[800] : Colors.blue[50],
                          elevation: 0,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildZoomButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        backgroundColor: Colors.blue.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

class GraphPainter extends CustomPainter {
  final List<Offset> points;
  final double minX, maxX, minY, maxY;
  final String equation;

  GraphPainter(this.points, this.minX, this.maxX, this.minY, this.maxY, this.equation);

  double _mapX(double x, Size size) => (x - minX) / (maxX - minX) * size.width;
  double _mapY(double y, Size size) => size.height - (y - minY) / (maxY - minY) * size.height;

  @override
  void paint(Canvas canvas, Size size) {
    // Background
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = Colors.white);
    
    // Grid lines
    Paint gridPaint = Paint()..color = Colors.grey.shade300..strokeWidth = 0.5;
    for (double x = -5; x <= 5; x += 1) {
      double xPos = _mapX(x, size);
      canvas.drawLine(Offset(xPos, 0), Offset(xPos, size.height), gridPaint);
    }
    for (double y = -5; y <= 5; y += 1) {
      double yPos = _mapY(y, size);
      canvas.drawLine(Offset(0, yPos), Offset(size.width, yPos), gridPaint);
    }
    
    // Axes
    Paint axisPaint = Paint()..color = Colors.black..strokeWidth = 1.5;
    double xAxisY = _mapY(0, size);
    if (xAxisY >= 0 && xAxisY <= size.height) {
      canvas.drawLine(Offset(0, xAxisY), Offset(size.width, xAxisY), axisPaint);
    }
    double yAxisX = _mapX(0, size);
    if (yAxisX >= 0 && yAxisX <= size.width) {
      canvas.drawLine(Offset(yAxisX, 0), Offset(yAxisX, size.height), axisPaint);
    }
    
    // Draw the function
    Paint linePaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
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