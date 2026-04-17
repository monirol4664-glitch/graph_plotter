import 'package:flutter/material.dart';

class EquationInput extends StatelessWidget {
  final String equation;
  final Function(String) onEquationChanged;
  final VoidCallback onPlot;

  const EquationInput({
    super.key,
    required this.equation,
    required this.onEquationChanged,
    required this.onPlot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: TextEditingController(text: equation),
              decoration: InputDecoration(
                hintText: 'Enter equation (e.g., x^2, sin(x))',
                prefixIcon: const Icon(Icons.functions),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => onEquationChanged('x'),
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onSubmitted: (value) {
                onEquationChanged(value);
                onPlot();
              },
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: onPlot,
            icon: const Icon(Icons.show_chart),
            label: const Text('Plot'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}
