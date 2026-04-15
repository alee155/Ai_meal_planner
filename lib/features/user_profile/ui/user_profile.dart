import 'package:ai_meal_planner/core/animations/app_animations.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/network/api_exception.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/controller/subscription_controller.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/widgets/subscription_status_card.dart';
import 'package:ai_meal_planner/features/user_profile/controller/user_profile_controller.dart';
import 'package:ai_meal_planner/features/user_profile/widgets/basic_info_card.dart';
import 'package:ai_meal_planner/features/user_profile/widgets/fitness_goals_card.dart';
import 'package:ai_meal_planner/features/user_profile/widgets/food_preferences_card.dart';
import 'package:ai_meal_planner/features/user_profile/widgets/health_metrics_card.dart';
import 'package:ai_meal_planner/features/user_profile/widgets/profile_completion_prompt_card.dart';

import 'package:ai_meal_planner/l10n/app_localizations.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({
    super.key,
    this.playEntranceAnimation = true,
    this.isOnboarding = false,
  });

  final bool playEntranceAnimation;
  final bool isOnboarding;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
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
    final subscriptionController = SubscriptionController.ensureRegistered();

    final genderOptions = _genderOptions(l10n);
    final activityOptions = _activityOptions(l10n);
    final goalOptions = _goalOptions(l10n);
    final dietPreferenceOptions = _dietPreferenceOptions(l10n);
    final allergyOptions = _allergyOptions(l10n);

    final bmiValue = _calculateBmi();
    final hasBmiData = bmiValue != null;
    final bmiDisplayValue = hasBmiData ? bmiValue.toStringAsFixed(1) : '--';
    final bmiCategory = _bmiCategory(context, bmiValue);
    final storedProfile = _profileController.profile.value;
    final currentProfileDraft = _buildProfileData(
      onboardingComplete: storedProfile.onboardingComplete,
    );
    final hasUnsavedChanges =
        widget.isOnboarding ||
        !storedProfile.hasSameEditableValues(currentProfileDraft);
    final headerTitle = widget.isOnboarding
        ? l10n.setUpYourProfile
        : l10n.navProfile;
    final headerSubtitle = widget.isOnboarding
        ? l10n.finishProfileSetupMessage
        : l10n.profileIntroDescription;
    // final overviewTitle = storedProfile.fullName.trim().isEmpty
    //     ? l10n.setUpYourProfile
    //     : storedProfile.fullName.trim();
    // final overviewSubtitle = storedProfile.email.trim().isEmpty
    //     ? headerSubtitle
    //     : storedProfile.email.trim();

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
                headerTitle,
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryOf(context),
                ),
              ),
              Text(
                headerSubtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondaryOf(context),
                ),
              ),
            ],
          ).animateProfileHeader(enabled: widget.playEntranceAnimation),
        ),
        actions: widget.isOnboarding
            ? null
            : [
                Padding(
                  padding: EdgeInsets.only(right: 14.w),
                  child: InkWell(
                    onTap: () => Get.toNamed(AppRoutes.settings),
                    borderRadius: BorderRadius.circular(18.r),
                    child: Container(
                      width: 46.w,
                      height: 46.w,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceOf(context),
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(color: AppColors.borderOf(context)),
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        color: AppColors.textPrimaryOf(context),
                      ),
                    ),
                  ),
                ),
              ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ProfileOverviewCard(
            //   title: overviewTitle,
            //   subtitle: overviewSubtitle,
            //   planLabel: subscriptionController.hasPremium
            //       ? l10n.premiumPlan
            //       : l10n.freePlan,
            //   goalLabel: l10n.goal,
            //   goalValue: goalOptions[_selectedGoalKey]!,
            //   activityLabel: l10n.activityLevel,
            //   activityValue: _selectedActivityKey == null
            //       ? l10n.notEnoughData
            //       : activityOptions[_selectedActivityKey]!,
            //   bmiLabel: l10n.bmiAutoCalculated,
            //   bmiValue: bmiDisplayValue,
            //   bmiStatus: bmiCategory,
            //   hasPremium: subscriptionController.hasPremium,
            //   hasBmiData: hasBmiData,
            // ).animateProfileAvatar(
            //   enabled: widget.playEntranceAnimation,
            //   delay: AppMotion.stagger(1, initialMs: 120),
            // ),
            if (!widget.isOnboarding && !storedProfile.onboardingComplete)
              ProfileCompletionPromptCard(
                title: l10n.completeYourProfileTitle,
                message: l10n.completeYourProfileMessage,
                buttonLabel: l10n.resumeSetup,
                onPressed: () => Get.toNamed(AppRoutes.profileSetup),
              ).animateProfileSection(
                enabled: widget.playEntranceAnimation,
                delay: AppMotion.stagger(2, initialMs: 140),
              ),
            if (!widget.isOnboarding)
              Obx(() {
                final activeSubscription =
                    subscriptionController.activeSubscription.value;

                if (activeSubscription == null) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                  child: SubscriptionStatusCard(
                    subscription: activeSubscription,
                  ),
                ).animateProfileSection(
                  enabled: widget.playEntranceAnimation,
                  delay: AppMotion.stagger(3, initialMs: 140),
                );
              }),
            SizedBox(height: widget.isOnboarding ? 20.h : 30.h),
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
            FoodPreferencesCard(
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
            ).animateProfileSection(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(6, initialMs: 140),
            ),
            if (hasUnsavedChanges)
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
                child: AppFilledButton(
                  label: widget.isOnboarding
                      ? l10n.completeSetup
                      : l10n.saveProfile,
                  onPressed: _isSaving ? null : _saveProfile,
                  backgroundColor: AppColors.buttonPrimary,
                  foregroundColor: AppColors.textWhite,
                  isLoading: _isSaving,
                  fontSize: 16,
                ),
              ).animateProfileSection(
                enabled: widget.playEntranceAnimation,
                delay: AppMotion.stagger(7, initialMs: 160),
              ),
            150.h.verticalSpace,
          ],
        ),
      ),
    );
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

  Future<void> _saveProfile() async {
    FocusScope.of(context).unfocus();
    final l10n = context.l10n;

    if (!_hasRequiredFields()) {
      AppSnackbar.warning(
        l10n.completeRequiredFieldsTitle,
        l10n.completeRequiredFieldsMessage,
      );
      return;
    }

    setState(() => _isSaving = true);

    final data = _buildProfileData(onboardingComplete: true);

    try {
      if (_profileController.hasRemoteStats.value) {
        await _profileController.updateProfile(data);
      } else {
        await _profileController.createProfile(data);
      }

      if (!mounted) {
        return;
      }

      setState(() {
        _applyProfileData(_profileController.profile.value);
        _isSaving = false;
      });

      if (widget.isOnboarding) {
        Get.offAllNamed(AppRoutes.bottomNav);
      }

      AppSnackbar.success(
        l10n.profileUpdatedTitle,
        widget.isOnboarding
            ? l10n.mealPlannerReadyMessage
            : l10n.profileUpdatedMessage,
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }

      setState(() => _isSaving = false);
      AppSnackbar.error(l10n.profileUpdatedTitle, error.message);
    } catch (_) {
      if (!mounted) {
        return;
      }

      setState(() => _isSaving = false);
      AppSnackbar.error(
        l10n.profileUpdatedTitle,
        'Unable to save your profile right now. Please try again.',
      );
    }
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

  bool _hasRequiredFields() {
    final age = int.tryParse(_ageController.text);

    return age != null &&
        age > 0 &&
        _weightInKilograms() != null &&
        _heightInCentimeters() != null &&
        _selectedActivityKey != null &&
        _selectedGoalKey.isNotEmpty;
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
      'light': l10n.lightlyActive,
      'moderate': l10n.moderatelyActive,
      'active': l10n.veryActive,
    };
  }

  Map<String, String> _goalOptions(AppLocalizations l10n) {
    return <String, String>{
      'loss': l10n.loseWeight,
      'maintain': l10n.maintainWeight,
      'gain': l10n.gainMuscle,
    };
  }

  Map<String, String> _dietPreferenceOptions(AppLocalizations l10n) {
    return <String, String>{
      'balanced': l10n.balancedDiet,
      'vegetarian': l10n.vegetarian,
      'vegan': l10n.vegan,
      'halal': l10n.halal,
      'keto': l10n.keto,
      'high-protein': l10n.highProteinDiet,
    };
  }

  Map<String, String> _allergyOptions(AppLocalizations l10n) {
    return <String, String>{
      'peanut': l10n.peanuts,
      'tree-nut': l10n.treeNuts,
      'dairy': l10n.dairy,
      'egg': l10n.eggs,
      'shellfish': l10n.shellfish,
      'fish': l10n.fish,
      'soy': l10n.soy,
      'wheat': l10n.wheat,
      'sesame': l10n.sesame,
    };
  }
}
