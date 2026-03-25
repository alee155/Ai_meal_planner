import 'package:flutter/material.dart';

class DietMacroTarget {
  const DietMacroTarget({
    required this.title,
    required this.percentage,
    required this.gramsLabel,
    required this.color,
  });

  final String title;
  final double percentage;
  final String gramsLabel;
  final Color color;

  String get percentLabel => '${(percentage * 100).round()}%';
}

class DietPlanMeal {
  const DietPlanMeal({
    required this.title,
    required this.calories,
    required this.timeWindow,
    required this.items,
    required this.summary,
  });

  final String title;
  final int calories;
  final String timeWindow;
  final List<String> items;
  final String summary;
}
