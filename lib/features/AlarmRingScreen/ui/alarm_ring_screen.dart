import 'dart:async';
import 'dart:io';

import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/notification_service.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AlarmRingScreen extends StatefulWidget {
  const AlarmRingScreen({super.key, this.initialAlarmData});

  final AlarmLaunchData? initialAlarmData;

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  Timer? _clockTimer;
  late DateTime _currentTime;
  bool _isHandlingAction = false;

  AlarmLaunchData get _alarmData {
    final arguments = Get.arguments;
    if (arguments is AlarmLaunchData) {
      return arguments;
    }
    return widget.initialAlarmData ??
        const AlarmLaunchData(
          title: NotificationService.defaultTitle,
          instruction: NotificationService.defaultInstruction,
          hour: 0,
          minute: 0,
        );
  }

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => _currentTime = DateTime.now());
    });
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  Future<void> _handleStop() async {
    setState(() => _isHandlingAction = true);
    await NotificationService.stopAlarm();
    if (!mounted) return;
    await _dismissAlarmUi();
  }

  Future<void> _handleSnooze() async {
    setState(() => _isHandlingAction = true);
    await NotificationService.snoozeAlarm();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alarm will ring again after 30 seconds.')),
    );
    await _dismissAlarmUi();
  }

  Future<void> _dismissAlarmUi() async {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back<void>();
      return;
    }

    if (Platform.isAndroid) {
      await SystemNavigator.pop();
      return;
    }

    await Get.offAllNamed(AppRoutes.multicolorloader);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final primary = isDark
        ? AppColors.primaryGreenLight
        : AppColors.primaryGreenDark;
    final accent = isDark
        ? AppColors.primaryGreenDark
        : AppColors.primaryGreenLight;
    final surface = AppColors.surfaceOf(context);
    final scheduledTime = TimeOfDay(
      hour: _alarmData.hour,
      minute: _alarmData.minute,
    ).format(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.backgroundMainOf(context),
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primary.withValues(alpha: isDark ? 0.24 : 0.16),
                      AppColors.backgroundMainOf(context),
                      AppColors.backgroundSecondaryOf(context),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              top: -110.h,
              right: -90.w,
              child: Container(
                width: 260.w,
                height: 260.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: isDark ? 0.22 : 0.18),
                ),
              ),
            ),
            Positioned(
              top: 140.h,
              left: -100.w,
              child: Container(
                width: 220.w,
                height: 220.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: primary.withValues(alpha: isDark ? 0.16 : 0.10),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 24.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: surface.withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(999.r),
                        border: Border.all(color: AppColors.borderOf(context)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.alarm_rounded,
                            color: primary,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Meal alarm ringing',
                            style: AppTextStyles.caption(
                              context,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimaryOf(context),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 28.h),
                    Text(
                      _formatCurrentTime(context),
                      style: AppTextStyles.display(
                        context,
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimaryOf(context),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      _formatCurrentDate(),
                      style: AppTextStyles.body(
                        context,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondaryOf(context),
                      ),
                    ),
                    SizedBox(height: 26.h),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(22.w),
                            decoration: BoxDecoration(
                              color: surface.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(28.r),
                              border: Border.all(
                                color: AppColors.borderOf(context),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primary.withValues(alpha: 0.12),
                                  blurRadius: 32,
                                  offset: const Offset(0, 16),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 60.w,
                                  height: 60.w,
                                  decoration: BoxDecoration(
                                    color: primary.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(20.r),
                                  ),
                                  child: Icon(
                                    Icons.restaurant_menu_rounded,
                                    color: primary,
                                    size: 28.sp,
                                  ),
                                ),
                                SizedBox(height: 18.h),
                                Text(
                                  _alarmData.title,
                                  style: AppTextStyles.headline(
                                    context,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  _alarmData.instruction,
                                  style: AppTextStyles.body(
                                    context,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textPrimaryOf(
                                      context,
                                    ).withValues(alpha: 0.82),
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: 18.h),
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(16.w),
                                  decoration: BoxDecoration(
                                    color: AppColors.backgroundSecondaryOf(
                                      context,
                                    ),
                                    borderRadius: BorderRadius.circular(18.r),
                                    border: Border.all(
                                      color: AppColors.borderOf(context),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.schedule_rounded,
                                        size: 20.sp,
                                        color: primary,
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Scheduled alarm time',
                                              style: AppTextStyles.caption(
                                                context,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                            SizedBox(height: 3.h),
                                            Text(
                                              scheduledTime,
                                              style: AppTextStyles.title(
                                                context,
                                                fontSize: 18,
                                                fontWeight: FontWeight.w800,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 18.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 18.w,
                              vertical: 16.h,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.chipBackgroundOf(context),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: primary.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.tips_and_updates_rounded,
                                  color: primary,
                                  size: 20.sp,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Text(
                                    'Snooze pauses this alarm for 30 seconds. Stop silences it and keeps your daily reminder schedule.',
                                    style: AppTextStyles.body(
                                      context,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textPrimaryOf(context),
                                      height: 1.45,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppOutlinedButton(
                      label: 'Snooze 30s',
                      onPressed: _isHandlingAction ? null : _handleSnooze,
                      foregroundColor: primary,
                      borderColor: primary.withValues(alpha: 0.32),
                      borderRadius: 22,
                      paddingVertical: 17,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                    SizedBox(height: 12.h),
                    AppFilledButton(
                      label: 'Stop Alarm',
                      onPressed: _isHandlingAction ? null : _handleStop,
                      backgroundColor: primary,
                      foregroundColor: AppColors.textWhite,
                      borderRadius: 22,
                      paddingVertical: 18,
                      fontSize: 16,
                      isLoading: _isHandlingAction,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrentTime(BuildContext context) {
    return TimeOfDay.fromDateTime(_currentTime).format(context);
  }

  String _formatCurrentDate() {
    const months = <String>[
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const weekdays = <String>[
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return '${weekdays[_currentTime.weekday - 1]}, ${months[_currentTime.month - 1]} ${_currentTime.day}';
  }
}
