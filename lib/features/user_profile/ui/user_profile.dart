import 'package:ai_meal_planner/core/animations/app_animations.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/controller/subscription_controller.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/widgets/subscription_status_card.dart';
import 'package:ai_meal_planner/features/user_profile/widgets/basic_info_card.dart';
import 'package:ai_meal_planner/features/user_profile/widgets/fitness_goals_card.dart';
import 'package:ai_meal_planner/features/user_profile/widgets/health_metrics_card.dart';
import 'package:ai_meal_planner/features/user_profile/widgets/profile_overview_card.dart';
import 'package:ai_meal_planner/l10n/app_localizations.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, this.playEntranceAnimation = true});

  final bool playEntranceAnimation;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _heightFeetController;
  late final TextEditingController _heightInchesController;
  late final TextEditingController _ageController;

  late String _selectedGenderKey;
  late String _selectedWeightUnit;
  late String _selectedHeightUnit;
  String? _selectedActivityKey;
  late String _selectedGoalKey;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController(text: '70');
    _heightController = TextEditingController(text: '170');
    _heightFeetController = TextEditingController(text: '5');
    _heightInchesController = TextEditingController(text: '7');
    _ageController = TextEditingController(text: '28');
    _selectedGenderKey = 'male';
    _selectedWeightUnit = 'kg';
    _selectedHeightUnit = 'cm';
    _selectedActivityKey = 'moderatelyActive';
    _selectedGoalKey = 'loseWeight';
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _heightFeetController.dispose();
    _heightInchesController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final subscriptionController = SubscriptionController.ensureRegistered();

    final genderOptions = _genderOptions(l10n);
    final activityOptions = _activityOptions(l10n);
    final goalOptions = _goalOptions(l10n);

    final bmiValue = _calculateBmi();
    final hasBmiData = bmiValue != null;
    final bmiDisplayValue = hasBmiData ? bmiValue.toStringAsFixed(1) : '--';
    final bmiCategory = _bmiCategory(context, bmiValue);

    return Scaffold(
      backgroundColor: AppColors.backgroundMainOf(context),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundMainOf(context),
        surfaceTintColor: AppColors.backgroundMainOf(context),
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: const SizedBox.shrink(),
        leadingWidth: 10.w,
        titleSpacing: 5.h,
        centerTitle: false,
        title: Align(
          alignment: Alignment.centerLeft,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.setUpYourProfile,
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryOf(context),
                ),
              ),
              Text(
                l10n.profileIntroDescription,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondaryOf(context),
                ),
              ),
            ],
          ).animateProfileHeader(enabled: widget.playEntranceAnimation),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileOverviewCard(
              title: l10n.setUpYourProfile,
              subtitle: l10n.profileIntroDescription,
              planLabel: subscriptionController.hasPremium
                  ? l10n.premiumPlan
                  : l10n.freePlan,
              goalLabel: l10n.goal,
              goalValue: goalOptions[_selectedGoalKey]!,
              activityLabel: l10n.activityLevel,
              activityValue: _selectedActivityKey == null
                  ? l10n.notEnoughData
                  : activityOptions[_selectedActivityKey]!,
              bmiLabel: l10n.bmiAutoCalculated,
              bmiValue: bmiDisplayValue,
              bmiStatus: bmiCategory,
              hasPremium: subscriptionController.hasPremium,
              hasBmiData: hasBmiData,
            ).animateProfileAvatar(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(1, initialMs: 120),
            ),
            Obx(() {
              final activeSubscription =
                  subscriptionController.activeSubscription.value;

              if (activeSubscription == null) {
                return const SizedBox.shrink();
              }

              return Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                child: SubscriptionStatusCard(subscription: activeSubscription),
              ).animateProfileSection(
                enabled: widget.playEntranceAnimation,
                delay: AppMotion.stagger(2, initialMs: 140),
              );
            }),
            30.h.verticalSpace,
            BasicInfoCard(
              title: l10n.basicInformation,
              weightLabel: l10n.weight,
              heightLabel: l10n.height,
              ageLabel: l10n.age,
              genderLabel: l10n.gender,
              weightController: _weightController,
              heightController: _heightController,
              heightFeetController: _heightFeetController,
              heightInchesController: _heightInchesController,
              ageController: _ageController,
              selectedGender: genderOptions[_selectedGenderKey]!,
              genderOptions: genderOptions.values.toList(),
              selectedWeightUnit: _selectedWeightUnit,
              weightUnitOptions: const ['kg', 'lb'],
              onWeightUnitChanged: _handleWeightUnitChanged,
              selectedHeightUnit: _selectedHeightUnit,
              heightUnitOptions: const ['cm', 'ft/in'],
              onHeightUnitChanged: _handleHeightUnitChanged,
              feetLabel: 'ft',
              inchesLabel: 'in',
              onGenderChanged: (value) {
                setState(() {
                  _selectedGenderKey = genderOptions.entries
                      .firstWhere((entry) => entry.value == value)
                      .key;
                });
              },
              onValueChanged: () => setState(() {}),
            ).animateProfileSection(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(3, initialMs: 140),
            ),
            HealthMetricsCard(
              title: l10n.healthMetrics,
              bmiLabel: l10n.bmiAutoCalculated,
              activityLevelLabel: l10n.activityLevel,
              selectActivityLevelLabel: l10n.selectActivityLevel,
              bmiValueLabel: bmiDisplayValue,
              bmiCategory: bmiCategory,
              hasBmiData: hasBmiData,
              selectedActivityLevel: _selectedActivityKey == null
                  ? null
                  : activityOptions[_selectedActivityKey],
              activityOptions: activityOptions.values.toList(),
              onActivityChanged: (value) {
                setState(() {
                  _selectedActivityKey = value == null
                      ? null
                      : activityOptions.entries
                            .firstWhere((entry) => entry.value == value)
                            .key;
                });
              },
            ).animateProfileSection(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(4, initialMs: 140),
            ),
            FitnessGoalsCard(
              title: l10n.yourFitnessGoals,
              selectedGoal: goalOptions[_selectedGoalKey]!,
              goalOptions: goalOptions.values.toList(),
              onGoalChanged: (value) {
                setState(() {
                  _selectedGoalKey = goalOptions.entries
                      .firstWhere((entry) => entry.value == value)
                      .key;
                });
              },
            ).animateProfileSection(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(5, initialMs: 140),
            ),
            150.h.verticalSpace,
          ],
        ),
      ),
    );
  }

  void _handleWeightUnitChanged(String value) {
    if (value == _selectedWeightUnit) {
      return;
    }

    final weight = double.tryParse(_weightController.text);
    if (weight != null && weight > 0) {
      final convertedWeight = _selectedWeightUnit == 'kg'
          ? weight * 2.20462
          : weight / 2.20462;
      _weightController.text = _formatValue(
        convertedWeight,
        allowDecimal: true,
      );
    }

    setState(() {
      _selectedWeightUnit = value;
    });
  }

  void _handleHeightUnitChanged(String value) {
    if (value == _selectedHeightUnit) {
      return;
    }

    final heightInCm = _heightInCentimeters();

    setState(() {
      _selectedHeightUnit = value;
    });

    if (heightInCm == null || heightInCm <= 0) {
      return;
    }

    if (value == 'cm') {
      _heightController.text = _formatValue(heightInCm);
      return;
    }

    final totalInches = heightInCm / 2.54;
    var feet = totalInches ~/ 12;
    var inches = (totalInches - (feet * 12)).round();

    if (inches == 12) {
      feet += 1;
      inches = 0;
    }

    _heightFeetController.text = feet.toString();
    _heightInchesController.text = inches.toString();
  }

  double? _calculateBmi() {
    final weightKg = _weightInKilograms();
    final heightCm = _heightInCentimeters();

    if (weightKg == null ||
        heightCm == null ||
        weightKg <= 0 ||
        heightCm <= 0) {
      return null;
    }

    final heightMeters = heightCm / 100;
    return weightKg / (heightMeters * heightMeters);
  }

  double? _weightInKilograms() {
    final weight = double.tryParse(_weightController.text);
    if (weight == null || weight <= 0) {
      return null;
    }

    return _selectedWeightUnit == 'kg' ? weight : weight / 2.20462;
  }

  double? _heightInCentimeters() {
    if (_selectedHeightUnit == 'cm') {
      final heightCm = double.tryParse(_heightController.text);
      return heightCm == null || heightCm <= 0 ? null : heightCm;
    }

    final feet = int.tryParse(_heightFeetController.text) ?? 0;
    final inches = int.tryParse(_heightInchesController.text) ?? 0;

    if (feet <= 0 && inches <= 0) {
      return null;
    }

    return (feet * 30.48) + (inches * 2.54);
  }

  String _bmiCategory(BuildContext context, double? bmi) {
    final l10n = context.l10n;

    if (bmi == null) {
      return l10n.notEnoughData;
    }
    if (bmi < 18.5) {
      return l10n.underweight;
    }
    if (bmi < 25) {
      return l10n.normal;
    }
    if (bmi < 30) {
      return l10n.overweight;
    }
    return l10n.obese;
  }

  String _formatValue(double value, {bool allowDecimal = false}) {
    if (!allowDecimal || value == value.roundToDouble()) {
      return value.round().toString();
    }

    return value.toStringAsFixed(1);
  }

  Map<String, String> _genderOptions(AppLocalizations l10n) {
    return <String, String>{
      'male': l10n.male,
      'female': l10n.female,
      'other': l10n.other,
    };
  }

  Map<String, String> _activityOptions(AppLocalizations l10n) {
    return <String, String>{
      'lightlyActive': l10n.lightlyActive,
      'moderatelyActive': l10n.moderatelyActive,
      'veryActive': l10n.veryActive,
    };
  }

  Map<String, String> _goalOptions(AppLocalizations l10n) {
    return <String, String>{
      'loseWeight': l10n.loseWeight,
      'maintainWeight': l10n.maintainWeight,
      'gainMuscle': l10n.gainMuscle,
    };
  }
}
