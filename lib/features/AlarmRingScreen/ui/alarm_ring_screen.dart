import 'dart:async';
import 'dart:io';

import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/features/AlarmRingScreen/widgets/alarm_header.dart';
import 'package:ai_meal_planner/features/AlarmRingScreen/widgets/swipe_action_button.dart';
import 'package:ai_meal_planner/notification_service.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    if (arguments is AlarmLaunchData) return arguments;

    return widget.initialAlarmData ??
        const AlarmLaunchData(
          title: NotificationService.defaultTitle,
          instruction: NotificationService.defaultInstruction,
          hour: 8,
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

  // ───────────────────────── ACTIONS ─────────────────────────

  Future<void> _handleStop() async {
    if (_isHandlingAction) return;

    setState(() => _isHandlingAction = true);

    await NotificationService.stopAlarm(alarmId: _alarmData.alarmId);

    if (!mounted) return;
    await _dismiss();
  }

  Future<void> _handleSnooze() async {
    if (_isHandlingAction) return;

    setState(() => _isHandlingAction = true);

    await NotificationService.snoozeAlarm(alarmId: _alarmData.alarmId);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alarm will ring again after 30 seconds.')),
    );

    await _dismiss();
  }

  Future<void> _dismiss() async {
    if (Get.key.currentState?.canPop() ?? false) {
      Get.back();
      return;
    }

    if (Platform.isAndroid) {
      await SystemNavigator.pop();
      return;
    }

    await Get.offAllNamed(AppRoutes.multicolorloader);
  }

  // ───────────────────────── FORMATTERS ─────────────────────────

  String _formatHHMM(BuildContext context) =>
      TimeOfDay.fromDateTime(_currentTime).format(context);

  String _formatDate() {
    const months = [
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

    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    return '${weekdays[_currentTime.weekday - 1]}, '
        '${months[_currentTime.month - 1]} ${_currentTime.day}';
  }

  // ───────────────────────── BUILD ─────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    final primary = isDark
        ? AppColors.primaryGreenLight
        : AppColors.primaryGreenDark;

    final scheduledTime = TimeOfDay(
      hour: _alarmData.hour,
      minute: _alarmData.minute,
    ).format(context);

    // colors
    final snoozeTrackDark = const Color(0xFF0F6E56).withOpacity(0.25);
    final snoozeFill = isDark
        ? const Color(0xFF1D9E75)
        : const Color(0xFF5DCAA5);

    final stopTrackDark = const Color(0xFFA32D2D).withOpacity(0.25);
    const stopFill = Color(0xFFE24B4A);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.backgroundMainOf(context),
        body: Column(
          children: [
            // ───────── HEADER (clean extracted widget)
            AlarmHeader(
              isDark: isDark,
              primary: primary,
              scheduledTime: scheduledTime,
              dateText: _formatDate(),
              currentTime: _formatHHMM(context),
            ),

            // ───────── BODY
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
                child: Column(
                  children: [
                    // ── Meal Card (still inside screen for now)
                    _mealCard(context, primary, isDark),

                    SizedBox(height: 12.h),

                    _hintBanner(context, primary, isDark),

                    SizedBox(height: 28.h),

                    // ── Snooze
                    _sectionLabel("SWIPE TO SNOOZE"),

                    SizedBox(height: 8.h),

                    SwipeActionButton(
                      label: 'Snooze 30s',
                      icon: Icon(Icons.schedule_rounded, size: 16.sp),
                      thumbIcon: Icon(Icons.access_time_rounded, size: 22.sp),
                      trackColor: isDark
                          ? snoozeTrackDark
                          : AppColors.primaryGreenLight,
                      fillColor: snoozeFill,
                      thumbColor: isDark
                          ? const Color(0xFF1a2e27)
                          : Colors.white,
                      labelColor: isDark
                          ? AppColors.primaryGreenLight
                          : AppColors.surfaceWhite,
                      onCompleted: _isHandlingAction ? () {} : _handleSnooze,
                    ),

                    SizedBox(height: 20.h),

                    // ── Stop
                    _sectionLabel("SWIPE TO STOP"),

                    SizedBox(height: 8.h),

                    SwipeActionButton(
                      label: 'Stop alarm',
                      icon: Icon(Icons.stop_circle_outlined, size: 16.sp),
                      thumbIcon: Icon(Icons.stop_rounded, size: 22.sp),
                      trackColor: isDark
                          ? stopTrackDark
                          : const Color(0xFFFCEBEB),
                      fillColor: stopFill,
                      thumbColor: isDark
                          ? const Color(0xFF2e1a1a)
                          : Colors.white,
                      labelColor: isDark
                          ? const Color(0xFFF09595)
                          : const Color(0xFFA32D2D),
                      onCompleted: _isHandlingAction ? () {} : _handleStop,
                    ),

                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── LOCAL SMALL WIDGETS ─────────────────────────

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: AppColors.textSecondaryOf(context),
      ),
    );
  }

  Widget _mealCard(BuildContext context, Color primary, bool isDark) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context).withOpacity(0.95),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderOf(context), width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: primary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.restaurant_menu_rounded,
              color: primary,
              size: 26.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _alarmData.title,
                  style: AppTextStyles.headline(
                    context,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  _alarmData.instruction,
                  style: AppTextStyles.body(
                    context,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimaryOf(context).withOpacity(0.72),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hintBanner(BuildContext context, Color primary, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
      decoration: BoxDecoration(
        color: primary.withOpacity(isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Icon(Icons.tips_and_updates_rounded, color: primary, size: 16.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'Snooze pauses for 30 s · Stop silences & keeps your schedule',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
