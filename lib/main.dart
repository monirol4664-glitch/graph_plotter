import 'package:flutter/material.dart';
import 'screens/graph_screen.dart';

void main() {
  runApp(const GraphPlotterApp());
}

class GraphPlotterApp extends StatelessWidget {
  const GraphPlotterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Graph Plotter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const GraphScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
