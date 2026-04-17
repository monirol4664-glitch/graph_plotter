import 'package:flutter/material.dart';
import 'package:math_expressions/math_expressions.dart';

class MathParser {
  static List<Offset> plotEquation(String equation, double minX, double maxX, double minY, double maxY) {
    List<Offset> points = [];
    
    Parser parser = Parser();
    Expression exp = parser.parse(equation);
    ContextModel cm = ContextModel();
    
    for (double x = minX; x <= maxX; x += 0.02) {
      cm.bindVariable(Variable('x'), Number(x));
      double y = exp.evaluate(EvaluationType.REAL, cm);
      if (y.isFinite && y > minY - 2 && y < maxY + 2) {
        points.add(Offset(x, y));
      } else {
        points.add(Offset(x, double.nan));
      }
    }
    
    return points;
  }
}
