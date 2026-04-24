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
    required this.dailyNutritionTargets,
    required this.actualDailyTotals,
    required this.meals,
    required this.swapSuggestions,
    required this.flags,
  });

  final MealPlanDailyNutritionTargetsModel dailyNutritionTargets;
  final MealPlanActualDailyTotalsModel actualDailyTotals;
  final List<MealPlanMealModel> meals;
  final List<MealPlanSwapSuggestionModel> swapSuggestions;
  final MealPlanFlagsModel flags;

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      dailyNutritionTargets: MealPlanDailyNutritionTargetsModel.fromJson(
        json['dailyNutritionTargets'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['dailyNutritionTargets'] as Map)
            : const <String, dynamic>{},
      ),
      actualDailyTotals: MealPlanActualDailyTotalsModel.fromJson(
        json['actualDailyTotals'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['actualDailyTotals'] as Map)
            : const <String, dynamic>{},
      ),
      meals: (json['meals'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                MealPlanMealModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      swapSuggestions: (json['swapSuggestions'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) => MealPlanSwapSuggestionModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
      flags: MealPlanFlagsModel.fromJson(
        json['flags'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['flags'] as Map)
            : const <String, dynamic>{},
      ),
    );
  }
}

class MealPlanDailyNutritionTargetsModel {
  const MealPlanDailyNutritionTargetsModel({
    required this.calories,
    required this.macros,
  });

  final int calories;
  final MealPlanMacroTargetsModel macros;

  factory MealPlanDailyNutritionTargetsModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return MealPlanDailyNutritionTargetsModel(
      calories: _asInt(json['calories']),
      macros: MealPlanMacroTargetsModel.fromJson(
        json['macros'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['macros'] as Map)
            : const <String, dynamic>{},
      ),
    );
  }
}

class MealPlanMacroTargetsModel {
  const MealPlanMacroTargetsModel({
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  final int protein;
  final int carbs;
  final int fats;

  factory MealPlanMacroTargetsModel.fromJson(Map<String, dynamic> json) {
    return MealPlanMacroTargetsModel(
      protein: _asInt(json['protein']),
      carbs: _asInt(json['carbs']),
      fats: _asInt(json['fats']),
    );
  }
}

class MealPlanActualDailyTotalsModel {
  const MealPlanActualDailyTotalsModel({
    required this.calories,
    required this.macros,
    required this.macroPercentages,
  });

  final int calories;
  final MealPlanMacroActualModel macros;
  final MealPlanMacroPercentagesModel macroPercentages;

  factory MealPlanActualDailyTotalsModel.fromJson(Map<String, dynamic> json) {
    return MealPlanActualDailyTotalsModel(
      calories: _asInt(json['calories']),
      macros: MealPlanMacroActualModel.fromJson(
        json['macros'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['macros'] as Map)
            : const <String, dynamic>{},
      ),
      macroPercentages: MealPlanMacroPercentagesModel.fromJson(
        json['macroPercentages'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['macroPercentages'] as Map)
            : const <String, dynamic>{},
      ),
    );
  }
}

class MealPlanMacroActualModel {
  const MealPlanMacroActualModel({
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  final double protein;
  final double carbs;
  final double fats;

  factory MealPlanMacroActualModel.fromJson(Map<String, dynamic> json) {
    return MealPlanMacroActualModel(
      protein: _asDouble(json['protein']),
      carbs: _asDouble(json['carbs']),
      fats: _asDouble(json['fats']),
    );
  }
}

class MealPlanMacroPercentagesModel {
  const MealPlanMacroPercentagesModel({
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  final double protein;
  final double carbs;
  final double fats;

  factory MealPlanMacroPercentagesModel.fromJson(Map<String, dynamic> json) {
    return MealPlanMacroPercentagesModel(
      protein: _asDouble(json['protein']),
      carbs: _asDouble(json['carbs']),
      fats: _asDouble(json['fats']),
    );
  }
}

class MealPlanMealModel {
  const MealPlanMealModel({
    required this.mealName,
    required this.targetCalories,
    required this.actualCalories,
    required this.calorieGapPercent,
    required this.items,
    required this.subtotal,
  });

  final String mealName;
  final int targetCalories;
  final int actualCalories;
  final double calorieGapPercent;
  final List<MealPlanFoodItemModel> items;
  final MealPlanSubtotalModel subtotal;

  factory MealPlanMealModel.fromJson(Map<String, dynamic> json) {
    return MealPlanMealModel(
      mealName: json['mealName']?.toString().trim() ?? '',
      targetCalories: _asInt(json['targetCalories']),
      actualCalories: _asInt(json['actualCalories']),
      calorieGapPercent: _asDouble(json['calorieGapPercent']),
      items: (json['items'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) =>
                MealPlanFoodItemModel.fromJson(Map<String, dynamic>.from(item)),
          )
          .toList(),
      subtotal: MealPlanSubtotalModel.fromJson(
        json['subtotal'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['subtotal'] as Map)
            : const <String, dynamic>{},
      ),
    );
  }
}

class MealPlanFoodItemModel {
  const MealPlanFoodItemModel({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.weightGrams,
  });

  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final int weightGrams;

  factory MealPlanFoodItemModel.fromJson(Map<String, dynamic> json) {
    return MealPlanFoodItemModel(
      name: json['name']?.toString().trim() ?? '',
      calories: _asInt(json['calories']),
      protein: _asDouble(json['protein']),
      carbs: _asDouble(json['carbs']),
      fats: _asDouble(json['fats']),
      weightGrams: _asInt(json['weightGrams']),
    );
  }
}

class MealPlanSubtotalModel {
  const MealPlanSubtotalModel({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  final double calories;
  final double protein;
  final double carbs;
  final double fats;

  factory MealPlanSubtotalModel.fromJson(Map<String, dynamic> json) {
    return MealPlanSubtotalModel(
      calories: _asDouble(json['calories']),
      protein: _asDouble(json['protein']),
      carbs: _asDouble(json['carbs']),
      fats: _asDouble(json['fats']),
    );
  }
}

class MealPlanSwapSuggestionModel {
  const MealPlanSwapSuggestionModel({
    required this.meal,
    required this.currentItem,
    required this.alternatives,
  });

  final String meal;
  final MealPlanSwapItemModel currentItem;
  final List<MealPlanSwapAlternativeModel> alternatives;

  factory MealPlanSwapSuggestionModel.fromJson(Map<String, dynamic> json) {
    return MealPlanSwapSuggestionModel(
      meal: json['meal']?.toString().trim() ?? '',
      currentItem: MealPlanSwapItemModel.fromJson(
        json['currentItem'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['currentItem'] as Map)
            : const <String, dynamic>{},
      ),
      alternatives: (json['alternatives'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (item) => MealPlanSwapAlternativeModel.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
    );
  }
}

class MealPlanSwapItemModel {
  const MealPlanSwapItemModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
  });

  final int id;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;

  factory MealPlanSwapItemModel.fromJson(Map<String, dynamic> json) {
    return MealPlanSwapItemModel(
      id: _asInt(json['id']),
      name: json['name']?.toString().trim() ?? '',
      calories: _asInt(json['calories']),
      protein: _asDouble(json['protein']),
      carbs: _asDouble(json['carbs']),
      fats: _asDouble(json['fats']),
    );
  }
}

class MealPlanSwapAlternativeModel {
  const MealPlanSwapAlternativeModel({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fats,
    required this.matchScore,
    required this.isSafeSwap,
  });

  final int id;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fats;
  final double matchScore;
  final bool isSafeSwap;

  factory MealPlanSwapAlternativeModel.fromJson(Map<String, dynamic> json) {
    return MealPlanSwapAlternativeModel(
      id: _asInt(json['id']),
      name: json['name']?.toString().trim() ?? '',
      calories: _asInt(json['calories']),
      protein: _asDouble(json['protein']),
      carbs: _asDouble(json['carbs']),
      fats: _asDouble(json['fats']),
      matchScore: _asDouble(json['matchScore']),
      isSafeSwap: json['isSafeSwap'] == true,
    );
  }
}

class MealPlanFlagsModel {
  const MealPlanFlagsModel({
    required this.calorieGap,
    required this.allergiesRespected,
    required this.dislikesAvoided,
  });

  final String? calorieGap;
  final String? allergiesRespected;
  final String? dislikesAvoided;

  factory MealPlanFlagsModel.fromJson(Map<String, dynamic> json) {
    return MealPlanFlagsModel(
      calorieGap: json['calorieGap']?.toString(),
      allergiesRespected: json['allergiesRespected']?.toString(),
      dislikesAvoided: json['dislikesAvoided']?.toString(),
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
