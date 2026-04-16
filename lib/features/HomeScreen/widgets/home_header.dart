import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.onNotificationsTap,
    this.greeting = 'Good morning',
    this.userName = 'Guest User',
    this.badgeCount,
    this.avatarImageUrl,
  });

  final VoidCallback onNotificationsTap;
  final String greeting;
  final String userName;
  final int? badgeCount;
  final String? avatarImageUrl;

  @override
  Widget build(BuildContext context) {
    final localizedGreeting = greeting == 'Good morning'
        ? context.l10n.goodMorning
        : greeting;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42.w,
          height: 42.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.buttonDisabled,
          ),
          clipBehavior: Clip.antiAlias,
          alignment: Alignment.center,
          child: (avatarImageUrl ?? '').trim().isEmpty
              ? Icon(
                  Icons.person_rounded,
                  color: AppColors.textSecondaryOf(context),
                )
              : CachedNetworkImage(
                  imageUrl: avatarImageUrl!.trim(),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorWidget: (_, _, _) => Icon(
                    Icons.person_rounded,
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
        ),
        5.w.horizontalSpace,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizedGreeting,
                style: AppTextStyles.label(context),
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              Text(
                userName,
                style: AppTextStyles.title(
                  context,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        _HomeHeaderAction(
          icon: Icons.notifications_none_rounded,
          onTap: onNotificationsTap,
          badgeCount: badgeCount,
        ),
      ],
    );
  }
}

class _HomeHeaderAction extends StatelessWidget {
  const _HomeHeaderAction({
    required this.icon,
    required this.onTap,
    this.badgeCount,
  });

  final IconData icon;
  final VoidCallback onTap;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: AppColors.surfaceOf(context),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: AppColors.borderOf(context)),
            ),
            child: Icon(icon, color: AppColors.textPrimaryOf(context)),
          ),
          if (badgeCount != null)
            Positioned(
              top: -4.h,
              right: -2.w,
              child: Container(
                height: 20.w,
                constraints: BoxConstraints(minWidth: 20.w),
                padding: EdgeInsets.symmetric(horizontal: 5.w),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.surfaceOf(context),
                    width: 2,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  '$badgeCount',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
