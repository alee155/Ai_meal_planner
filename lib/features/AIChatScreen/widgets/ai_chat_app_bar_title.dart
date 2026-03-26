import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AiChatAppBarTitle extends StatelessWidget {
  const AiChatAppBarTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: const BoxDecoration(
            color: AppColors.primaryGreenDark,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'AI Nutrition Coach',
                style: AppTextStyles.title(
                  context,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Online',
                style: AppTextStyles.caption(
                  context,
                  color: AppColors.primaryGreenDark,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
