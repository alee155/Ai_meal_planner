import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FoodPreferencesCard extends StatelessWidget {
  const FoodPreferencesCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.dietPreferenceLabel,
    required this.selectDietPreferenceLabel,
    required this.selectedDietPreferenceKey,
    required this.dietPreferenceOptions,
    required this.onDietPreferenceChanged,
    required this.allergiesLabel,
    required this.allergiesHint,
    required this.allergyOptions,
    required this.selectedAllergyKeys,
    required this.onAllergyToggled,
    required this.dislikedFoodsLabel,
    required this.dislikedFoodsHint,
    required this.dislikedFoodsController,
    required this.safetyNote,
    required this.onDislikedFoodsChanged,
  });

  final String title;
  final String subtitle;
  final String dietPreferenceLabel;
  final String selectDietPreferenceLabel;
  final String selectedDietPreferenceKey;
  final Map<String, String> dietPreferenceOptions;
  final ValueChanged<String?> onDietPreferenceChanged;
  final String allergiesLabel;
  final String allergiesHint;
  final Map<String, String> allergyOptions;
  final Set<String> selectedAllergyKeys;
  final ValueChanged<String> onAllergyToggled;
  final String dislikedFoodsLabel;
  final String dislikedFoodsHint;
  final TextEditingController dislikedFoodsController;
  final String safetyNote;
  final ValueChanged<String> onDislikedFoodsChanged;

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
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: AppTextStyles.body(context, fontSize: 13, height: 1.45),
          ),
          SizedBox(height: 16.h),
          _FoodFieldLabel(label: dietPreferenceLabel),
          SizedBox(height: 6.h),
          DropdownButtonFormField<String>(
            initialValue: selectedDietPreferenceKey,
            items: dietPreferenceOptions.entries
                .map(
                  (entry) => DropdownMenuItem<String>(
                    value: entry.key,
                    child: Text(
                      entry.value,
                      style: AppTextStyles.body(
                        context,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryOf(context),
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onDietPreferenceChanged,
            style: AppTextStyles.body(
              context,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryOf(context),
            ),
            icon: Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondaryOf(context),
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.surfaceOf(context),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 12.h,
              ),
              hintText: selectDietPreferenceLabel,
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textHintOf(context),
              ),
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
          ),
          SizedBox(height: 16.h),
          _FoodFieldLabel(label: allergiesLabel),
          SizedBox(height: 4.h),
          Text(
            allergiesHint,
            style: AppTextStyles.caption(context, fontSize: 11),
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: allergyOptions.entries.map((entry) {
              final isSelected = selectedAllergyKeys.contains(entry.key);

              return FilterChip(
                label: Text(
                  entry.value,
                  style: AppTextStyles.caption(
                    context,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? AppColors.textWhite
                        : AppColors.textPrimaryOf(context),
                  ),
                ),
                selected: isSelected,
                onSelected: (_) => onAllergyToggled(entry.key),
                backgroundColor: AppColors.surfaceOf(context),
                selectedColor: AppColors.error,
                checkmarkColor: AppColors.textWhite,
                side: BorderSide(
                  color: isSelected
                      ? AppColors.error
                      : AppColors.borderOf(context),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              );
            }).toList(),
          ),
          SizedBox(height: 14.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primarylightGreen,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  size: 16.sp,
                  color: AppColors.primaryGreenDark,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    safetyNote,
                    style: AppTextStyles.caption(
                      context,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryGreenDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          _FoodFieldLabel(label: dislikedFoodsLabel),
          SizedBox(height: 6.h),
          TextField(
            controller: dislikedFoodsController,
            onChanged: onDislikedFoodsChanged,
            maxLines: 3,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textPrimaryOf(context),
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.surfaceOf(context),
              hintText: dislikedFoodsHint,
              hintStyle: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textHintOf(context),
              ),
              contentPadding: EdgeInsets.all(12.w),
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
          ),
        ],
      ),
    );
  }
}

class _FoodFieldLabel extends StatelessWidget {
  const _FoodFieldLabel({required this.label});

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
