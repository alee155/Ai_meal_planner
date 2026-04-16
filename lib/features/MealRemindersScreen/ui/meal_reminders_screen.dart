import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/features/MealRemindersScreen/controller/meal_reminders_controller.dart';
import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_icon_back_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class MealRemindersScreen extends StatelessWidget {
  const MealRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = MealRemindersController.ensureRegistered();
    final screenBackground = AppColors.backgroundSecondaryOf(context);

    return Scaffold(
      backgroundColor: screenBackground,
      appBar: AppBar(
        backgroundColor: screenBackground,
        surfaceTintColor: screenBackground,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: EdgeInsets.only(left: 14.w),
          child: AppIconBackButton(onTap: Get.back),
        ),
        leadingWidth: 64.w,
        titleSpacing: 0,
        centerTitle: false,
        title: Padding(
          padding: EdgeInsets.only(left: 10.w),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meal reminders',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
                Text(
                  'Choose default times or create your own schedule',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _masterCard(context, controller),
              SizedBox(height: 14.h),
              _modePicker(context, controller),
              SizedBox(height: 14.h),
              if (controller.mode.value == MealRemindersMode.defaultSchedule)
                _defaultScheduleCard(context, controller)
              else
                _customScheduleCard(context, controller),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() {
        if (controller.mode.value != MealRemindersMode.custom) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton(
          backgroundColor: AppColors.primaryGreenDark,
          foregroundColor: Colors.white,
          onPressed: () => _openAddSheet(context, controller),
          child: const Icon(Icons.add),
        );
      }),
    );
  }

  Widget _masterCard(BuildContext context, MealRemindersController controller) {
    return _card(
      context,
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.chipBackgroundOf(context),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Icon(
              Icons.notifications_active_outlined,
              color: AppColors.primaryGreenDark,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Enable reminders',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'We’ll alert you at your selected meal times.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: controller.isEnabled.value,
            onChanged: controller.setEnabled,
            activeThumbColor: AppColors.primaryGreenDark,
          ),
        ],
      ),
    );
  }

  Widget _modePicker(BuildContext context, MealRemindersController controller) {
    final isDefault =
        controller.mode.value == MealRemindersMode.defaultSchedule;

    return _card(
      context,
      padding: EdgeInsets.all(10.w),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.inputBackgroundOf(context),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(color: AppColors.borderOf(context)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _modeChip(
                context,
                label: 'Default',
                selected: isDefault,
                onTap: () =>
                    controller.setMode(MealRemindersMode.defaultSchedule),
              ),
            ),
            Expanded(
              child: _modeChip(
                context,
                label: 'Custom',
                selected: !isDefault,
                onTap: () => controller.setMode(MealRemindersMode.custom),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeChip(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final bg = selected ? AppColors.primaryGreenDark : Colors.transparent;
    final fg = selected ? Colors.white : AppColors.textPrimaryOf(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }

  Widget _defaultScheduleCard(
    BuildContext context,
    MealRemindersController controller,
  ) {
    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Default meal times',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'These are placeholder times until the backend “Get Time” API is ready. Tap “Use default schedule” to create alarms.',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondaryOf(context),
              height: 1.35,
            ),
          ),
          SizedBox(height: 14.h),
          ...controller.defaultSchedule.map((entry) {
            final label = MealRemindersController.displayMealName(
              entry.mealKey,
            );
            final timeText = entry.time.format(context);
            return Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _alarmRow(
                context,
                title: label,
                subtitle: timeText,
                trailing: const SizedBox.shrink(),
              ),
            );
          }),
          SizedBox(height: 8.h),
          AppFilledButton(
            label: 'Use default schedule',
            onPressed: controller.applyDefaultSchedule,
            backgroundColor: AppColors.primaryGreenDark,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _customScheduleCard(
    BuildContext context,
    MealRemindersController controller,
  ) {
    final items = controller.alarms.toList(growable: false);

    return _card(
      context,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your alarms',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            items.isEmpty
                ? 'No alarms yet. Add one for breakfast, lunch, snacks, or dinner.'
                : 'Add as many meal alarms as you like. Each one can be turned on or off.',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondaryOf(context),
              height: 1.35,
            ),
          ),
          SizedBox(height: 14.h),
          if (items.isNotEmpty)
            ...items.map((alarm) {
              final label = MealRemindersController.displayMealName(
                alarm.mealKey,
              );
              final timeText = TimeOfDay(
                hour: alarm.hour,
                minute: alarm.minute,
              ).format(context);
              return Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: _alarmRow(
                  context,
                  title: label,
                  subtitle: timeText,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: alarm.enabled,
                        onChanged: (value) =>
                            controller.toggleAlarm(alarm, value),
                        activeThumbColor: AppColors.primaryGreenDark,
                      ),
                      SizedBox(width: 6.w),
                      InkWell(
                        onTap: () => controller.deleteAlarm(alarm),
                        borderRadius: BorderRadius.circular(14.r),
                        child: Padding(
                          padding: EdgeInsets.all(8.w),
                          child: Icon(
                            Icons.delete_outline,
                            size: 20.sp,
                            color: const Color(0xFFA32D2D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          if (items.isEmpty) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: AppColors.inputBackgroundOf(context),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: AppColors.borderOf(context)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.alarm_add_outlined,
                    color: AppColors.textSecondaryOf(context),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      'Tap the + button to add your first meal alarm.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondaryOf(context),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 10.h),
          AppOutlinedButton(
            label: 'Add alarm',
            onPressed: () => _openAddSheet(context, controller),
            foregroundColor: AppColors.textPrimaryOf(context),
            borderColor: AppColors.borderOf(context),
          ),
        ],
      ),
    );
  }

  Widget _alarmRow(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.inputBackgroundOf(context),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }

  Widget _card(
    BuildContext context, {
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Container(
      width: double.infinity,
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOf(context),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Future<void> _openAddSheet(
    BuildContext context,
    MealRemindersController controller,
  ) async {
    final result = await showModalBottomSheet<_AddAlarmResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddAlarmSheet(),
    );

    if (result == null) return;
    await controller.addAlarm(mealKey: result.mealKey, time: result.time);
  }
}

class _AddAlarmResult {
  const _AddAlarmResult({required this.mealKey, required this.time});

  final String mealKey;
  final TimeOfDay time;
}

class _AddAlarmSheet extends StatefulWidget {
  @override
  State<_AddAlarmSheet> createState() => _AddAlarmSheetState();
}

class _AddAlarmSheetState extends State<_AddAlarmSheet> {
  static const mealKeys = <String>['breakfast', 'lunch', 'snacks', 'dinner'];

  String _mealKey = mealKeys.first;
  TimeOfDay _time = TimeOfDay.now();

  @override
  Widget build(BuildContext context) {
    final surface = AppColors.surfaceOf(context);
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 20.h),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          border: Border.all(color: AppColors.borderOf(context)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: AppColors.borderOf(context),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Add meal alarm',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              'Pick a meal and a time. You can add multiple alarms.',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondaryOf(context),
              ),
            ),
            SizedBox(height: 16.h),
            _fieldLabel(context, 'Meal'),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.inputBackgroundOf(context),
                borderRadius: BorderRadius.circular(18.r),
                border: Border.all(color: AppColors.borderOf(context)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _mealKey,
                  isExpanded: true,
                  icon: const Icon(Icons.expand_more),
                  items: mealKeys
                      .map(
                        (key) => DropdownMenuItem(
                          value: key,
                          child: Text(
                            MealRemindersController.displayMealName(key),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _mealKey = value);
                  },
                ),
              ),
            ),
            SizedBox(height: 14.h),
            _fieldLabel(context, 'Time'),
            SizedBox(height: 8.h),
            InkWell(
              onTap: () async {
                final picked = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (picked == null) return;
                setState(() => _time = picked);
              },
              borderRadius: BorderRadius.circular(18.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.inputBackgroundOf(context),
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: AppColors.borderOf(context)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 18.sp,
                      color: AppColors.textSecondaryOf(context),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        _time.format(context),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimaryOf(context),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.edit_outlined,
                      size: 18.sp,
                      color: AppColors.textSecondaryOf(context),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 18.h),
            AppFilledButton(
              label: 'Save alarm',
              onPressed: () => Navigator.of(
                context,
              ).pop(_AddAlarmResult(mealKey: _mealKey, time: _time)),
              backgroundColor: AppColors.primaryGreenDark,
              foregroundColor: Colors.white,
            ),
            SizedBox(height: 10.h),
            AppOutlinedButton(
              label: 'Cancel',
              onPressed: () => Navigator.of(context).pop(),
              foregroundColor: AppColors.textPrimaryOf(context),
              borderColor: AppColors.borderOf(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fieldLabel(BuildContext context, String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textSecondaryOf(context),
      ),
    );
  }
}
