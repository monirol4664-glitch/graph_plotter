import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;
  final VoidCallback onToggleGrid;
  final VoidCallback onToggleAxes;
  final bool showGrid;
  final bool showAxes;

  const ControlButtons({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
    required this.onToggleGrid,
    required this.onToggleAxes,
    required this.showGrid,
    required this.showAxes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButton(
            icon: Icons.zoom_in,
            label: 'Zoom In',
            onPressed: onZoomIn,
          ),
          _buildButton(
            icon: Icons.zoom_out,
            label: 'Zoom Out',
            onPressed: onZoomOut,
          ),
          _buildButton(
            icon: Icons.refresh,
            label: 'Reset',
            onPressed: onReset,
          ),
          _buildButton(
            icon: showGrid ? Icons.grid_on : Icons.grid_off,
            label: 'Grid',
            onPressed: onToggleGrid,
            isActive: showGrid,
          ),
          _buildButton(
            icon: showAxes ? Icons.timeline : Icons.timeline_outlined,
            label: 'Axes',
            onPressed: onToggleAxes,
            isActive: showAxes,
          ),
        ],
      ),
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Column(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon),
          color: isActive ? Colors.blue : Colors.grey.shade700,
          style: IconButton.styleFrom(
            backgroundColor: isActive ? Colors.blue.shade50 : Colors.transparent,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: isActive ? Colors.blue : Colors.grey.shade600),
        ),
      ],
    );
  }
}
