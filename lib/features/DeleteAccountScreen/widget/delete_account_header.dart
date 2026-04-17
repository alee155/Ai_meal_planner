import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/shared/widgets/app_icon_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DeleteAccountHeader extends StatelessWidget {
  const DeleteAccountHeader({super.key, required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppIconBackButton(onTap: onBackTap),
        SizedBox(width: 14.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Delete Account', style: AppTextStyles.headline(context)),
              Text(
                'Review the warnings before continuing',
                style: AppTextStyles.label(context),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
