import 'package:flutter/material.dart';

class ControlButtons extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  const ControlButtons({
    super.key,
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(onPressed: onZoomIn, icon: const Icon(Icons.zoom_in)),
        IconButton(onPressed: onZoomOut, icon: const Icon(Icons.zoom_out)),
        IconButton(onPressed: onReset, icon: const Icon(Icons.refresh)),
      ],
    );
  }
}
