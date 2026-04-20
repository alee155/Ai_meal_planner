class LatestMealPlanResponseModel {
  const LatestMealPlanResponseModel({
    required this.success,
    this.data,
    this.message,
    this.details,
  });

  final bool success;
  final LatestMealPlanDataModel? data;
  final String? message;
  final List<String>? details;

  factory LatestMealPlanResponseModel.fromJson(Map<String, dynamic> json) {
    return LatestMealPlanResponseModel(
      success: json['success'] == true,
      data: json['data'] is Map<String, dynamic>
          ? LatestMealPlanDataModel.fromJson(
              Map<String, dynamic>.from(json['data'] as Map),
            )
          : null,
      message: json['message']?.toString(),
      details: (json['details'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }
}

class LatestMealPlanDataModel {
  const LatestMealPlanDataModel({
    required this.id,
    required this.userId,
    required this.plan,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final int userId;
  final MealPlanModel plan;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory LatestMealPlanDataModel.fromJson(Map<String, dynamic> json) {
    return LatestMealPlanDataModel(
      id: _asInt(json['id']),
      userId: _asInt(json['userId']),
      plan: MealPlanModel.fromJson(
        json['plan'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['plan'] as Map)
            : const <String, dynamic>{},
      ),
      createdAt: _asDateTime(json['createdAt']),
      updatedAt: _asDateTime(json['updatedAt']),
    );
  }
}

class MealPlanModel {
  const MealPlanModel({
    required this.nutrition,
    this.mealTargets,
    this.breakfast,
    this.lunch,
    this.dinner,
    this.snacks = const [],
    this.alternatives,
  });

  final MealPlanNutritionModel nutrition;
  final MealPlanTargetsModel? mealTargets;
  final MealPlanMealModel? breakfast;
  final MealPlanMealModel? lunch;
  final MealPlanMealModel? dinner;
  final List<MealPlanMealModel> snacks;
  final MealPlanAlternativesModel? alternatives;

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      nutrition: MealPlanNutritionModel.fromJson(
        json['nutrition'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['nutrition'] as Map)
            : const <String, dynamic>{},
      ),
      mealTargets: json['mealTargets'] is Map<String, dynamic>
          ? MealPlanTargetsModel.fromJson(
              Map<String, dynamic>.from(json['mealTargets'] as Map),
            )
          : null,
      breakfast: json['breakfast'] is Map<String, dynamic>
          ? MealPlanMealModel.fromJson(
              Map<String, dynamic>.from(json['breakfast'] as Map),
            )
          : null,
      lunch: json['lunch'] is Map<String, dynamic>
          ? MealPlanMealModel.fromJson(
              Map<String, dynamic>.from(json['lunch'] as Map),
            )
          : null,
      dinner: json['dinner'] is Map<String, dynamic>
          ? MealPlanMealModel.fromJson(
              Map<String, dynamic>.from(json['dinner'] as Map),
            )
          : null,
      snacks: (json['snacks'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                MealPlanMealModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      alternatives: json['alternatives'] is Map<String, dynamic>
          ? MealPlanAlternativesModel.fromJson(
              Map<String, dynamic>.from(json['alternatives'] as Map),
            )
          : null,
    );
  }
}

class MealPlanNutritionModel {
  const MealPlanNutritionModel({
    required this.source,
    required this.targetCalories,
    required this.macros,
    required this.mealsCount,
  });

  final String source;
  final double targetCalories;
  final MealPlanMacroModel macros;
  final int mealsCount;

  factory MealPlanNutritionModel.fromJson(Map<String, dynamic> json) {
    return MealPlanNutritionModel(
      source: json['source']?.toString() ?? '',
      targetCalories: _asDouble(json['targetCalories']),
      macros: MealPlanMacroModel.fromJson(
        json['macros'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['macros'] as Map)
            : const <String, dynamic>{},
      ),
      mealsCount: _asInt(json['mealsCount']),
    );
  }
}

class MealPlanMacroModel {
  const MealPlanMacroModel({
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  final int protein;
  final int carbs;
  final int fats;

  factory MealPlanMacroModel.fromJson(Map<String, dynamic> json) {
    return MealPlanMacroModel(
      protein: _asInt(json['protein']),
      carbs: _asInt(json['carbs']),
      fats: _asInt(json['fats']),
    );
  }
}

class MealPlanTargetsModel {
  const MealPlanTargetsModel({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });

  final double breakfast;
  final double lunch;
  final double dinner;

  factory MealPlanTargetsModel.fromJson(Map<String, dynamic> json) {
    return MealPlanTargetsModel(
      breakfast: _asDouble(json['breakfast']),
      lunch: _asDouble(json['lunch']),
      dinner: _asDouble(json['dinner']),
    );
  }
}

class MealPlanMealModel {
  const MealPlanMealModel({required this.items, required this.totals});

  final List<dynamic> items;
  final MealPlanTotalsModel totals;

  factory MealPlanMealModel.fromJson(Map<String, dynamic> json) {
    return MealPlanMealModel(
      items: json['items'] is List
          ? List<dynamic>.from(json['items'] as List)
          : const [],
      totals: MealPlanTotalsModel.fromJson(
        json['totals'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['totals'] as Map)
            : const <String, dynamic>{},
      ),
    );
  }
}

class MealPlanTotalsModel {
  const MealPlanTotalsModel({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  final int calories;
  final int protein;
  final int carbs;
  final int fats;

  factory MealPlanTotalsModel.fromJson(Map<String, dynamic> json) {
    return MealPlanTotalsModel(
      calories: _asInt(json['calories']),
      protein: _asInt(json['protein']),
      carbs: _asInt(json['carbs']),
      fats: _asInt(json['fats']),
    );
  }
}

class MealPlanAlternativesModel {
  const MealPlanAlternativesModel({
    required this.breakfast,
    required this.lunch,
    required this.dinner,
    required this.snacks,
  });

  final List<dynamic> breakfast;
  final List<dynamic> lunch;
  final List<dynamic> dinner;
  final List<dynamic> snacks;

  factory MealPlanAlternativesModel.fromJson(Map<String, dynamic> json) {
    return MealPlanAlternativesModel(
      breakfast: json['breakfast'] is List
          ? List<dynamic>.from(json['breakfast'] as List)
          : const [],
      lunch: json['lunch'] is List
          ? List<dynamic>.from(json['lunch'] as List)
          : const [],
      dinner: json['dinner'] is List
          ? List<dynamic>.from(json['dinner'] as List)
          : const [],
      snacks: json['snacks'] is List
          ? List<dynamic>.from(json['snacks'] as List)
          : const [],
    );
  }
}

int _asInt(Object? value) {
  if (value is int) return value;
  if (value is double) return value.round();
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

double _asDouble(Object? value) {
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value.trim()) ?? 0;
  return 0;
}

DateTime? _asDateTime(Object? value) {
  final raw = value?.toString().trim() ?? '';
  if (raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}
