import 'package:flutter/material.dart';

enum DietMealType { breakfast, lunch, snack, dinner }

enum DietMealStatus { pending, completed, skipped }

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

class DietMealProgress {
  const DietMealProgress({
    this.status = DietMealStatus.pending,
    this.completedAt,
  });

  final DietMealStatus status;
  final DateTime? completedAt;

  DietMealProgress copyWith({
    DietMealStatus? status,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return DietMealProgress(
      status: status ?? this.status,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    );
  }
}

class DietPlanMeal {
  const DietPlanMeal({
    required this.type,
    required this.title,
    required this.calories,
    required this.timeWindow,
    required this.items,
    required this.summary,
    this.status = DietMealStatus.pending,
    this.completedAt,
  });

  final DietMealType type;
  final String title;
  final int calories;
  final String timeWindow;
  final List<String> items;
  final String summary;
  final DietMealStatus status;
  final DateTime? completedAt;

  bool get isCompleted => status == DietMealStatus.completed;
  bool get isSkipped => status == DietMealStatus.skipped;

  DietPlanMeal copyWith({
    DietMealType? type,
    String? title,
    int? calories,
    String? timeWindow,
    List<String>? items,
    String? summary,
    DietMealStatus? status,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return DietPlanMeal(
      type: type ?? this.type,
      title: title ?? this.title,
      calories: calories ?? this.calories,
      timeWindow: timeWindow ?? this.timeWindow,
      items: items ?? this.items,
      summary: summary ?? this.summary,
      status: status ?? this.status,
      completedAt: clearCompletedAt ? null : completedAt ?? this.completedAt,
    );
  }
}
