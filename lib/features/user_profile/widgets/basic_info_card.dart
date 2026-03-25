import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BasicInfoCard extends StatelessWidget {
  const BasicInfoCard({
    super.key,
    required this.title,
    required this.weightLabel,
    required this.heightLabel,
    required this.ageLabel,
    required this.genderLabel,
    required this.weightController,
    required this.heightController,
    required this.heightFeetController,
    required this.heightInchesController,
    required this.ageController,
    required this.selectedGender,
    required this.genderOptions,
    required this.selectedWeightUnit,
    required this.weightUnitOptions,
    required this.onWeightUnitChanged,
    required this.selectedHeightUnit,
    required this.heightUnitOptions,
    required this.onHeightUnitChanged,
    required this.feetLabel,
    required this.inchesLabel,
    required this.onGenderChanged,
    required this.onValueChanged,
  });

  final String title;
  final String weightLabel;
  final String heightLabel;
  final String ageLabel;
  final String genderLabel;
  final TextEditingController weightController;
  final TextEditingController heightController;
  final TextEditingController heightFeetController;
  final TextEditingController heightInchesController;
  final TextEditingController ageController;
  final String selectedGender;
  final List<String> genderOptions;
  final String selectedWeightUnit;
  final List<String> weightUnitOptions;
  final ValueChanged<String> onWeightUnitChanged;
  final String selectedHeightUnit;
  final List<String> heightUnitOptions;
  final ValueChanged<String> onHeightUnitChanged;
  final String feetLabel;
  final String inchesLabel;
  final ValueChanged<String> onGenderChanged;
  final VoidCallback onValueChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundOf(context),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOf(context),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.title(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          16.h.verticalSpace,
          _ProfileFieldLabel(label: weightLabel),
          6.h.verticalSpace,
          Row(
            children: [
              Expanded(
                child: _ProfileInputField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => onValueChanged(),
                ),
              ),
              SizedBox(width: 10.w),
              _UnitSelector(
                selectedValue: selectedWeightUnit,
                options: weightUnitOptions,
                onChanged: onWeightUnitChanged,
              ),
            ],
          ),
          12.h.verticalSpace,
          _ProfileFieldLabel(label: heightLabel),
          6.h.verticalSpace,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: selectedHeightUnit == 'cm'
                    ? _ProfileInputField(
                        controller: heightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => onValueChanged(),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _ProfileInputField(
                              controller: heightFeetController,
                              keyboardType: TextInputType.number,
                              hintText: feetLabel,
                              onChanged: (_) => onValueChanged(),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: _ProfileInputField(
                              controller: heightInchesController,
                              keyboardType: TextInputType.number,
                              hintText: inchesLabel,
                              onChanged: (_) => onValueChanged(),
                            ),
                          ),
                        ],
                      ),
              ),
              SizedBox(width: 10.w),
              _UnitSelector(
                selectedValue: selectedHeightUnit,
                options: heightUnitOptions,
                onChanged: onHeightUnitChanged,
              ),
            ],
          ),
          12.h.verticalSpace,
          _ProfileFieldLabel(label: ageLabel),
          6.h.verticalSpace,
          _ProfileInputField(
            controller: ageController,
            keyboardType: TextInputType.number,
            onChanged: (_) => onValueChanged(),
          ),
          12.h.verticalSpace,
          _ProfileFieldLabel(label: genderLabel),
          8.h.verticalSpace,
          Row(
            children: genderOptions
                .map(
                  (gender) => Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: gender == genderOptions.last ? 0 : 8.w,
                      ),
                      child: _GenderButton(
                        label: gender,
                        isSelected: selectedGender == gender,
                        onTap: () => onGenderChanged(gender),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _ProfileFieldLabel extends StatelessWidget {
  const _ProfileFieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.label(
        context,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryOf(context),
      ),
    );
  }
}

class _ProfileInputField extends StatelessWidget {
  const _ProfileInputField({
    required this.controller,
    this.hintText,
    this.keyboardType,
    this.onChanged,
  });

  final TextEditingController controller;
  final String? hintText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        fontSize: 14.sp,
        color: AppColors.textPrimaryOf(context),
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: AppColors.surfaceOf(context),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textHintOf(context),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.borderOf(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(color: AppColors.borderOf(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: const BorderSide(color: AppColors.primaryGreenDark),
        ),
      ),
    );
  }
}

class _UnitSelector extends StatelessWidget {
  const _UnitSelector({
    required this.selectedValue,
    required this.options,
    required this.onChanged,
  });

  final String selectedValue;
  final List<String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: options
            .map(
              (option) => Padding(
                padding: EdgeInsets.only(
                  right: option == options.last ? 0 : 4.w,
                ),
                child: _UnitOption(
                  label: option,
                  isSelected: selectedValue == option,
                  onTap: () => onChanged(option),
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _UnitOption extends StatelessWidget {
  const _UnitOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreenDark : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: isSelected
                ? Colors.white
                : AppColors.textSecondaryOf(context),
          ),
        ),
      ),
    );
  }
}

class _GenderButton extends StatelessWidget {
  const _GenderButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryGreen
              : AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreen
                : AppColors.borderOf(context),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: isSelected
                  ? Colors.white
                  : AppColors.textSecondaryOf(context),
            ),
          ),
        ),
      ),
    );
  }
}
