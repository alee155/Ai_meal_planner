import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/shared/widgets/app_icon_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<_NotificationItem> _notifications = [
    _NotificationItem(
      title: 'Breakfast reminder',
      message: 'Your high-protein breakfast window starts in 20 minutes.',
      time: 'Today • 7:10 AM',
      icon: Icons.breakfast_dining_outlined,
      accent: AppColors.warning,
      isUnread: true,
    ),
    _NotificationItem(
      title: 'Calories on track',
      message: 'You stayed within your calorie target for 3 days in a row.',
      time: 'Today • 8:45 AM',
      icon: Icons.local_fire_department_outlined,
      accent: AppColors.primaryGreenDark,
      isUnread: true,
    ),
    _NotificationItem(
      title: 'Hydration reminder',
      message: 'Drink one more glass of water to stay on pace for today.',
      time: 'Today • 11:30 AM',
      icon: Icons.water_drop_outlined,
      accent: AppColors.info,
    ),
    _NotificationItem(
      title: 'AI plan updated',
      message:
          'Your lunch recommendation was adjusted for better protein balance.',
      time: 'Yesterday • 6:20 PM',
      icon: Icons.auto_awesome_rounded,
      accent: AppColors.primaryGreenLight,
    ),
    _NotificationItem(
      title: 'Weekly insight ready',
      message: 'Your weekly nutrition trend is available to review.',
      time: 'Yesterday • 9:00 AM',
      icon: Icons.insights_outlined,
      accent: AppColors.primaryGreen,
    ),
    _NotificationItem(
      title: 'Subscription renewed',
      message: 'Your AI Diet Planner premium plan is active for another month.',
      time: 'Mar 20 • 2:40 PM',
      icon: Icons.workspace_premium_outlined,
      accent: AppColors.success,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenBackground = AppColors.backgroundSecondaryOf(context);
    final surfaceColor = AppColors.surfaceOf(context);
    final borderColor = AppColors.borderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

    final unreadCount = _notifications.where((item) => item.isUnread).length;

    return Scaffold(
      backgroundColor: screenBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 18.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppIconBackButton(
                    onTap: Get.back,
                    size: 46,
                    borderRadius: 16,
                    backgroundColor: surfaceColor,
                    borderColor: borderColor,
                    iconColor: textPrimary,
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Notifications',
                          style: AppTextStyles.headline(
                            context,
                            fontWeight: FontWeight.w800,
                            color: textPrimary,
                          ),
                        ),
                        Text(
                          '$unreadCount unread updates from your AI meal planner',
                          style: AppTextStyles.label(
                            context,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: _markAllAsRead,
                    child: Text(
                      'Mark all read',
                      style: AppTextStyles.button(
                        context,
                        fontSize: 13,
                        color: AppColors.primaryGreenDark,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(18.w),
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(24.r),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadowOf(
                        context,
                      ).withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50.w,
                      height: 50.w,
                      decoration: BoxDecoration(
                        color: AppColors.chipBackgroundOf(context),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: const Icon(
                        Icons.notifications_active_outlined,
                        color: AppColors.primaryGreenDark,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Stay on top of your plan',
                            style: AppTextStyles.title(
                              context,
                              fontWeight: FontWeight.w700,
                              color: textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Meal reminders, calorie insights, hydration alerts, and AI updates all show here.',
                            style: AppTextStyles.body(
                              context,
                              fontSize: 13,
                              height: 1.5,
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 18.h),
              Expanded(
                child: ListView.separated(
                  itemCount: _notifications.length,
                  separatorBuilder: (_, index) => SizedBox(height: 12.h),
                  itemBuilder: (context, index) {
                    final item = _notifications[index];
                    return Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(22.r),
                        border: Border.all(
                          color: item.isUnread
                              ? item.accent.withValues(alpha: 0.35)
                              : borderColor,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 46.w,
                            height: 46.w,
                            decoration: BoxDecoration(
                              color: item.accent.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Icon(
                              item.icon,
                              color: item.accent,
                              size: 22.sp,
                            ),
                          ),
                          SizedBox(width: 14.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.title,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w700,
                                          color: textPrimary,
                                        ),
                                      ),
                                    ),
                                    if (item.isUnread)
                                      Container(
                                        width: 10.w,
                                        height: 10.w,
                                        decoration: BoxDecoration(
                                          color: item.accent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  item.message,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    height: 1.5,
                                    color: textSecondary,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  item.time,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                    color: item.accent,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _markAllAsRead() {
    setState(() {
      for (final notification in _notifications) {
        notification.isUnread = false;
      }
    });

    AppSnackbar.success(
      'Notifications updated',
      'All notifications have been marked as read.',
    );
  }
}

class _NotificationItem {
  _NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.accent,
    this.isUnread = false,
  });

  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color accent;
  bool isUnread;
}
