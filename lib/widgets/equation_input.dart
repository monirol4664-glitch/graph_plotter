import 'package:flutter/material.dart';

class EquationInput extends StatelessWidget {
  final String equation;
  final Function(String) onEquationChanged;

  const EquationInput({
    super.key,
    required this.equation,
    required this.onEquationChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: TextEditingController(text: equation),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Equation (e.g., x^2, sin(x))',
                prefixIcon: Icon(Icons.functions),
              ),
              onSubmitted: onEquationChanged,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => onEquationChanged(equation),
            child: const Text('Plot'),
          ),
        ],
      ),
    );
  }
}
