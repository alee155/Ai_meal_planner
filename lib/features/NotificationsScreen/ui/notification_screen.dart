import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/notifications/in_app_inbox_store.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/features/NotificationsScreen/controller/notifications_inbox_controller.dart';
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
  late final NotificationsInboxController _inboxController;

  @override
  void initState() {
    super.initState();
    _inboxController = NotificationsInboxController.ensureRegistered();
    _inboxController.reload();
  }

  @override
  Widget build(BuildContext context) {
    final screenBackground = AppColors.backgroundSecondaryOf(context);
    final surfaceColor = AppColors.surfaceOf(context);
    final borderColor = AppColors.borderOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);
    final textSecondary = AppColors.textSecondaryOf(context);

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
                        Obx(() {
                          final unreadCount =
                              _inboxController.unreadCount.value;
                          return Text(
                            '$unreadCount unread updates from your AI meal planner',
                            style: AppTextStyles.label(
                              context,
                              color: textSecondary,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  Obx(() {
                    final disabled = _inboxController.unreadCount.value == 0;
                    return TextButton(
                      onPressed: disabled ? null : _markAllAsRead,
                      child: Text(
                        'Mark all read',
                        style: AppTextStyles.button(
                          context,
                          fontSize: 13,
                          color: disabled
                              ? textSecondary
                              : AppColors.primaryGreenDark,
                        ),
                      ),
                    );
                  }),
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
                child: Obx(() {
                  if (_inboxController.isLoading.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final items = _inboxController.items.toList(growable: false);
                  if (items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30.w),
                        child: Text(
                          'No notifications yet. When a meal reminder rings, it will appear here.',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.body(
                            context,
                            fontSize: 13,
                            height: 1.5,
                            color: textSecondary,
                          ),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, index) => SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final accent = _accentFor(item);
                      return Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: surfaceColor,
                          borderRadius: BorderRadius.circular(22.r),
                          border: Border.all(
                            color: item.isRead
                                ? borderColor
                                : accent.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 46.w,
                              height: 46.w,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Icon(
                                _iconFor(item),
                                color: accent,
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
                                      if (!item.isRead)
                                        Container(
                                          width: 10.w,
                                          height: 10.w,
                                          decoration: BoxDecoration(
                                            color: accent,
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
                                    _formatTimeLabel(context, item),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.w600,
                                      color: accent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _markAllAsRead() {
    _inboxController.markAllRead();

    AppSnackbar.success(
      'Notifications updated',
      'All notifications have been marked as read.',
    );
  }

  static IconData _iconFor(InAppInboxItem item) {
    if (item.type == 'meal_alarm') {
      switch (item.mealKey) {
        case 'breakfast':
          return Icons.breakfast_dining_outlined;
        case 'lunch':
          return Icons.lunch_dining_outlined;
        case 'snacks':
          return Icons.fastfood_outlined;
        case 'dinner':
          return Icons.dinner_dining_outlined;
        default:
          return Icons.restaurant_menu_outlined;
      }
    }

    return Icons.notifications_outlined;
  }

  static Color _accentFor(InAppInboxItem item) {
    if (item.type == 'meal_alarm') {
      switch (item.mealKey) {
        case 'breakfast':
          return AppColors.warning;
        case 'lunch':
          return AppColors.primaryGreenDark;
        case 'snacks':
          return AppColors.info;
        case 'dinner':
          return AppColors.success;
        default:
          return AppColors.primaryGreen;
      }
    }

    return AppColors.primaryGreenDark;
  }

  static String _formatTimeLabel(BuildContext context, InAppInboxItem item) {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(item.createdAtMs);
    final now = DateTime.now();
    final isToday =
        createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday =
        createdAt.year == yesterday.year &&
        createdAt.month == yesterday.month &&
        createdAt.day == yesterday.day;

    final timeText = TimeOfDay.fromDateTime(createdAt).format(context);
    if (isToday) return 'Today • $timeText';
    if (isYesterday) return 'Yesterday • $timeText';

    final month = _monthShort(createdAt.month);
    return '$month ${createdAt.day} • $timeText';
  }

  static String _monthShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }
}
