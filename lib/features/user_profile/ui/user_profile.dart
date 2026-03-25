import 'package:ai_meal_planner/core/animations/app_animations.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key, this.playEntranceAnimation = true});

  final bool playEntranceAnimation;

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  @override
  Widget build(BuildContext context) {
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
                "Set Up Your Profile",
                style: TextStyle(
                  fontSize: 19.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryOf(context),
                ),
              ),
              Text(
                "Help us personalize your nutrition plan",
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
            50.h.verticalSpace,
            Container(
              height: 100.h,
              width: 100.w,
              decoration: BoxDecoration(
                color: AppColors.primarylightGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person,
                size: 50,
                color: AppColors.primaryGreenLight,
              ),
            ).animateProfileAvatar(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(1, initialMs: 120),
            ),
            30.h.verticalSpace,
            Container(
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
                  /// Header
                  Text(
                    "Basic Information",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  16.h.verticalSpace,

                  /// Weight
                  Text(
                    "Weight",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  6.h.verticalSpace,
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceOf(context),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.borderOf(context),
                            ),
                          ),
                          child: Text(
                            "70",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textHintOf(context),
                            ),
                          ),
                        ),
                      ),
                      8.w.horizontalSpace,
                      Container(
                        width: 70.w,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceOf(context),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.borderOf(context),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "kg",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textPrimaryOf(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// Height
                  12.h.verticalSpace,
                  Text(
                    "Height",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  6.h.verticalSpace,
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceOf(context),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.borderOf(context),
                            ),
                          ),
                          child: Text(
                            "170",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textHintOf(context),
                            ),
                          ),
                        ),
                      ),
                      8.w.horizontalSpace,
                      Container(
                        width: 70.w,
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 10.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceOf(context),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.borderOf(context),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            "cm",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textPrimaryOf(context),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  /// Age
                  12.h.verticalSpace,
                  Text(
                    "Age",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  6.h.verticalSpace,
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceOf(context),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.borderOf(context)),
                    ),
                    child: Text(
                      "28",
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textHintOf(context),
                      ),
                    ),
                  ),

                  /// Gender
                  12.h.verticalSpace,
                  Text(
                    "Gender",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  8.h.verticalSpace,
                  Row(
                    children: [
                      _genderButton("Male", true, context),
                      8.w.horizontalSpace,
                      _genderButton("Female", false, context),
                      8.w.horizontalSpace,
                      _genderButton("Other", false, context),
                    ],
                  ),
                ],
              ),
            ).animateProfileSection(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(2, initialMs: 140),
            ),
            // Health Metrics Card
            Container(
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
                  // Header
                  Text(
                    "Health Metrics",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  16.h.verticalSpace,

                  // BMI Box
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primarylightGreen, // #E8F5E9
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "BMI (Auto-calculated)",
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimaryOf(context),
                          ),
                        ),
                        4.h.verticalSpace,
                        Text(
                          "22.5",
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        8.h.verticalSpace,
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceOf(context),
                            borderRadius: BorderRadius.circular(50.r),
                          ),
                          child: Text(
                            "Normal",
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.primaryGreen,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Activity Level Dropdown
                  16.h.verticalSpace,
                  Text(
                    "Activity Level",
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  6.h.verticalSpace,
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceOf(context),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.borderOf(context)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Select activity level",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textHintOf(context),
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ],
              ),
            ).animateProfileSection(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(3, initialMs: 140),
            ),

            // Your Fitness Goals Card
            Container(
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
                  // Header
                  Text(
                    "Your Fitness Goals",
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  16.h.verticalSpace,

                  // Goal Buttons
                  _fitnessGoalButton("Lose Weight", true, context),
                  12.h.verticalSpace,
                  _fitnessGoalButton("Maintain Weight", false, context),
                  12.h.verticalSpace,
                  _fitnessGoalButton("Gain Muscle", false, context),
                ],
              ),
            ).animateProfileSection(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(4, initialMs: 140),
            ),
            150.h.verticalSpace,
          ],
        ),
      ),
    );
  }
}

Widget _genderButton(String text, bool isSelected, BuildContext context) {
  return Expanded(
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
          text,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : AppColors.textSecondaryOf(context),
          ),
        ),
      ),
    ),
  );
}

Widget _fitnessGoalButton(String text, bool isSelected, BuildContext context) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
    decoration: BoxDecoration(
      color: isSelected ? AppColors.primaryGreen : AppColors.surfaceOf(context),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(
        color: isSelected
            ? AppColors.primaryGreen
            : AppColors.borderOf(context),
      ),
    ),
    child: Row(
      children: [
        Icon(
          text == "Lose Weight"
              ? Icons.trending_down
              : text == "Maintain Weight"
              ? Icons.flag
              : Icons.fitness_center,
          color: isSelected ? Colors.white : AppColors.textSecondaryOf(context),
          size: 20.sp,
        ),
        12.w.horizontalSpace,
        Text(
          text,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : AppColors.textSecondaryOf(context),
          ),
        ),
      ],
    ),
  );
}
