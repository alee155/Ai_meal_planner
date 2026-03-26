import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/features/ProfileSetupScreen/widgets/profile_setup_footer.dart';
import 'package:ai_meal_planner/features/ProfileSetupScreen/widgets/profile_setup_header.dart';
import 'package:ai_meal_planner/features/ProfileSetupScreen/widgets/profile_setup_step_indicator.dart';
import 'package:ai_meal_planner/features/user_profile/controller/user_profile_controller.dart';
import 'package:ai_meal_planner/features/user_profile/widgets/basic_info_card.dart';
import 'package:ai_meal_planner/features/user_profile/widgets/fitness_goals_card.dart';
import 'package:ai_meal_planner/features/user_profile/widgets/food_preferences_card.dart';
import 'package:ai_meal_planner/features/user_profile/widgets/health_metrics_card.dart';
import 'package:ai_meal_planner/l10n/app_localizations.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  late final TextEditingController _heightFeetController;
  late final TextEditingController _heightInchesController;
  late final TextEditingController _ageController;
  late final TextEditingController _dislikedFoodsController;
  late final UserProfileController _profileController;

  late String _selectedGenderKey;
  late String _selectedWeightUnit;
  late String _selectedHeightUnit;
  String? _selectedActivityKey;
  late String _selectedGoalKey;
  late String _selectedDietPreferenceKey;
  Set<String> _selectedAllergyKeys = <String>{};

  bool _isInitializing = true;
  bool _isSaving = false;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _weightController = TextEditingController();
    _heightController = TextEditingController();
    _heightFeetController = TextEditingController();
    _heightInchesController = TextEditingController();
    _ageController = TextEditingController();
    _dislikedFoodsController = TextEditingController();
    _profileController = UserProfileController.ensureRegistered();
    _applyProfileData(const UserProfileData());
    _initializeProfile();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _heightFeetController.dispose();
    _heightInchesController.dispose();
    _ageController.dispose();
    _dislikedFoodsController.dispose();
    super.dispose();
  }

  Future<void> _initializeProfile() async {
    await _profileController.init();
    _applyProfileData(_profileController.profile.value);

    if (!mounted) {
      return;
    }

    setState(() => _isInitializing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return Scaffold(
        backgroundColor: AppColors.backgroundMainOf(context),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final l10n = context.l10n;
    final activityOptions = _activityOptions(l10n);
    final goalOptions = _goalOptions(l10n);
    final genderOptions = _genderOptions(l10n);
    final dietPreferenceOptions = _dietPreferenceOptions(l10n);
    final allergyOptions = _allergyOptions(l10n);
    final stepLabels = [
      l10n.basicInformation,
      l10n.healthMetrics,
      l10n.foodPreferences,
    ];
    final bmiValue = _calculateBmi();
    final hasBmiData = bmiValue != null;
    final bmiDisplayValue = hasBmiData ? bmiValue.toStringAsFixed(1) : '--';
    final bmiCategory = _bmiCategory(context, bmiValue);

    return Scaffold(
      backgroundColor: AppColors.backgroundMainOf(context),
      body: SafeArea(
        child: Column(
          children: [
            ProfileSetupHeader(
              title: l10n.setUpYourProfile,
              subtitle: l10n.finishProfileSetupMessage,
              stepLabel: l10n.profileSetupStepLabel(
                _currentStep + 1,
                stepLabels.length,
              ),
              skipLabel: l10n.skipForNow,
              onSkipTap: _skipSetup,
            ),
            ProfileSetupStepIndicator(
              labels: stepLabels,
              currentStep: _currentStep,
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: SingleChildScrollView(
                child: _buildStepContent(
                  context,
                  l10n,
                  genderOptions,
                  activityOptions,
                  goalOptions,
                  dietPreferenceOptions,
                  allergyOptions,
                  bmiDisplayValue,
                  bmiCategory,
                  hasBmiData,
                ),
              ),
            ),
            ProfileSetupFooter(
              primaryLabel: _currentStep == stepLabels.length - 1
                  ? l10n.completeSetup
                  : l10n.nextButton,
              onPrimaryTap: _handlePrimaryAction,
              isSaving: _isSaving,
              secondaryLabel: _currentStep == 0 ? null : l10n.backButton,
              onSecondaryTap: _currentStep == 0
                  ? null
                  : () => setState(() => _currentStep -= 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent(
    BuildContext context,
    AppLocalizations l10n,
    Map<String, String> genderOptions,
    Map<String, String> activityOptions,
    Map<String, String> goalOptions,
    Map<String, String> dietPreferenceOptions,
    Map<String, String> allergyOptions,
    String bmiDisplayValue,
    String bmiCategory,
    bool hasBmiData,
  ) {
    switch (_currentStep) {
      case 0:
        return BasicInfoCard(
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
        );
      case 1:
        return Column(
          children: [
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
            ),
          ],
        );
      default:
        return FoodPreferencesCard(
          title: l10n.foodPreferences,
          subtitle: l10n.foodPreferencesSubtitle,
          dietPreferenceLabel: l10n.dietPreference,
          selectDietPreferenceLabel: l10n.selectDietPreference,
          selectedDietPreferenceKey: _selectedDietPreferenceKey,
          dietPreferenceOptions: dietPreferenceOptions,
          onDietPreferenceChanged: (value) {
            if (value == null) {
              return;
            }

            setState(() => _selectedDietPreferenceKey = value);
          },
          allergiesLabel: l10n.allergiesAndAvoidances,
          allergiesHint: l10n.allergiesSelectionHint,
          allergyOptions: allergyOptions,
          selectedAllergyKeys: _selectedAllergyKeys,
          onAllergyToggled: _toggleAllergy,
          dislikedFoodsLabel: l10n.dislikedFoods,
          dislikedFoodsHint: l10n.dislikedFoodsHint,
          dislikedFoodsController: _dislikedFoodsController,
          safetyNote: l10n.allergySafetyNote,
          onDislikedFoodsChanged: (_) => setState(() {}),
        );
    }
  }

  Future<void> _handlePrimaryAction() async {
    FocusScope.of(context).unfocus();
    final l10n = context.l10n;

    if (!_canProceedFromCurrentStep()) {
      AppSnackbar.warning(
        l10n.completeRequiredFieldsTitle,
        l10n.completeRequiredFieldsMessage,
      );
      return;
    }

    if (_currentStep < 2) {
      setState(() => _currentStep += 1);
      return;
    }

    setState(() => _isSaving = true);
    await _profileController.saveProfile(
      _buildProfileData(onboardingComplete: true),
    );

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    Get.offAllNamed(AppRoutes.bottomNav);
    AppSnackbar.success(l10n.profileUpdatedTitle, l10n.mealPlannerReadyMessage);
  }

  Future<void> _skipSetup() async {
    final l10n = context.l10n;
    setState(() => _isSaving = true);
    await _profileController.saveProfile(
      _buildProfileData(onboardingComplete: false),
    );

    if (!mounted) {
      return;
    }

    setState(() => _isSaving = false);
    Get.offAllNamed(AppRoutes.bottomNav);
    AppSnackbar.info(l10n.setupSkippedTitle, l10n.setupSkippedMessage);
  }

  UserProfileData _buildProfileData({required bool onboardingComplete}) {
    return _profileController.profile.value.copyWith(
      weight: _weightController.text.trim(),
      height: _heightController.text.trim(),
      heightFeet: _heightFeetController.text.trim(),
      heightInches: _heightInchesController.text.trim(),
      age: _ageController.text.trim(),
      genderKey: _selectedGenderKey,
      weightUnit: _selectedWeightUnit,
      heightUnit: _selectedHeightUnit,
      activityKey: _selectedActivityKey,
      clearActivityKey: _selectedActivityKey == null,
      goalKey: _selectedGoalKey,
      dietPreferenceKey: _selectedDietPreferenceKey,
      allergies: _selectedAllergyKeys.toList()..sort(),
      dislikedFoods: _dislikedFoodsController.text.trim(),
      onboardingComplete: onboardingComplete,
    );
  }

  bool _canProceedFromCurrentStep() {
    switch (_currentStep) {
      case 0:
        final age = int.tryParse(_ageController.text);
        return age != null &&
            age > 0 &&
            _weightInKilograms() != null &&
            _heightInCentimeters() != null;
      case 1:
        return _selectedActivityKey != null && _selectedGoalKey.isNotEmpty;
      default:
        return true;
    }
  }

  void _applyProfileData(UserProfileData data) {
    _weightController.text = data.weight;
    _heightController.text = data.height;
    _heightFeetController.text = data.heightFeet;
    _heightInchesController.text = data.heightInches;
    _ageController.text = data.age;
    _dislikedFoodsController.text = data.dislikedFoods;
    _selectedGenderKey = data.genderKey;
    _selectedWeightUnit = data.weightUnit;
    _selectedHeightUnit = data.heightUnit;
    _selectedActivityKey = data.activityKey;
    _selectedGoalKey = data.goalKey;
    _selectedDietPreferenceKey = data.dietPreferenceKey;
    _selectedAllergyKeys = data.allergies.toSet();
  }

  void _toggleAllergy(String allergyKey) {
    setState(() {
      if (_selectedAllergyKeys.contains(allergyKey)) {
        _selectedAllergyKeys.remove(allergyKey);
      } else {
        _selectedAllergyKeys.add(allergyKey);
      }
    });
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

    setState(() => _selectedWeightUnit = value);
  }

  void _handleHeightUnitChanged(String value) {
    if (value == _selectedHeightUnit) {
      return;
    }

    final heightInCm = _heightInCentimeters();
    setState(() => _selectedHeightUnit = value);

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

  Map<String, String> _dietPreferenceOptions(AppLocalizations l10n) {
    return <String, String>{
      'balancedDiet': l10n.balancedDiet,
      'vegetarian': l10n.vegetarian,
      'vegan': l10n.vegan,
      'halal': l10n.halal,
      'keto': l10n.keto,
      'highProteinDiet': l10n.highProteinDiet,
    };
  }

  Map<String, String> _allergyOptions(AppLocalizations l10n) {
    return <String, String>{
      'peanuts': l10n.peanuts,
      'treeNuts': l10n.treeNuts,
      'dairy': l10n.dairy,
      'eggs': l10n.eggs,
      'shellfish': l10n.shellfish,
      'fish': l10n.fish,
      'soy': l10n.soy,
      'wheat': l10n.wheat,
      'sesame': l10n.sesame,
    };
  }
}
