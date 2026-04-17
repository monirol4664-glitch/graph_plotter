import 'package:flutter/material.dart';

class ExampleChips extends StatelessWidget {
  final Function(String) onEquationSelected;

  const ExampleChips({super.key, required this.onEquationSelected});

  final List<Map<String, String>> examples = const [
    {'name': 'Quadratic', 'equation': 'x^2'},
    {'name': 'Cubic', 'equation': 'x^3'},
    {'name': 'Sine', 'equation': 'sin(x)'},
    {'name': 'Cosine', 'equation': 'cos(x)'},
    {'name': 'Linear', 'equation': '2*x+1'},
    {'name': 'Absolute', 'equation': 'abs(x)'},
    {'name': 'Exponential', 'equation': '2^x'},
    {'name': 'Rational', 'equation': '1/x'},
    {'name': 'Tangent', 'equation': 'tan(x)'},
    {'name': 'Square Root', 'equation': 'sqrt(x)'},
    {'name': 'Log', 'equation': 'ln(x)'},
    {'name': 'Sinc', 'equation': 'sin(x)/x'},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Examples',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: examples.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(examples[index]['name']!),
                    onPressed: () => onEquationSelected(examples[index]['equation']!),
                    backgroundColor: Colors.blue.shade50,
                    side: BorderSide.none,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
