import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class MathParser {
  static List<Offset> plotEquation(String equation, double minX, double maxX, double minY, double maxY) {
    List<Offset> points = [];
    
    try {
      Parser parser = Parser();
      Expression exp = parser.parse(equation);
      ContextModel cm = ContextModel();
      
      int steps = 800;
      double stepSize = (maxX - minX) / steps;
      
      for (int i = 0; i <= steps; i++) {
        double x = minX + (i * stepSize);
        
        try {
          cm.bindVariable(Variable('x'), Number(x));
          double y = exp.evaluate(EvaluationType.REAL, cm);
          
          if (y.isFinite && y >= minY - 2 && y <= maxY + 2) {
            points.add(Offset(x, y));
          } else {
            points.add(Offset(x, double.nan));
          }
        } catch (e) {
          points.add(Offset(x, double.nan));
        }
      }
    } catch (e) {
      rethrow;
    }
    
    return points;
  }
}
