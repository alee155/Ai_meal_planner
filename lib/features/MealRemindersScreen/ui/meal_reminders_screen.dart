import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/features/MealRemindersScreen/controller/meal_reminders_controller.dart';
import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_icon_back_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

// ─── Screen ───────────────────────────────────────────────────────────────────

class MealRemindersScreen extends StatelessWidget {
  const MealRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = MealRemindersController.ensureRegistered();
    final bg = AppColors.backgroundSecondaryOf(context);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        surfaceTintColor: bg,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: EdgeInsets.only(left: 14.w),
          child: AppIconBackButton(onTap: Get.back),
        ),
        leadingWidth: 64.w,
        titleSpacing: 0,
        title: Padding(
          padding: EdgeInsets.only(left: 10.w),
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
                'Manage your meal time schedule',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondaryOf(context),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 100.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MasterToggleCard(ctrl: ctrl),
              SizedBox(height: 14.h),
              _ModePicker(ctrl: ctrl),
              SizedBox(height: 14.h),
              if (ctrl.mode.value == MealRemindersMode.defaultSchedule)
                _DefaultScheduleSection(ctrl: ctrl)
              else
                _CustomAlarmsSection(ctrl: ctrl),
            ],
          ),
        );
      }),
      floatingActionButton: Obx(() {
        if (ctrl.mode.value != MealRemindersMode.custom) {
          return const SizedBox.shrink();
        }
        return FloatingActionButton(
          backgroundColor: AppColors.primaryGreenDark,
          foregroundColor: Colors.white,
          onPressed: () => _openAddSheet(context, ctrl),
          child: const Icon(Icons.add),
        );
      }),
    );
  }

  Future<void> _openAddSheet(
    BuildContext ctx,
    MealRemindersController ctrl,
  ) async {
    final result = await showModalBottomSheet<_AddAlarmResult>(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddAlarmSheet(),
    );
    if (result == null) return;
    await ctrl.addAlarm(mealKey: result.mealKey, time: result.time);
  }
}

// ─── Master toggle card ───────────────────────────────────────────────────────

class _MasterToggleCard extends StatelessWidget {
  const _MasterToggleCard({required this.ctrl});
  final MealRemindersController ctrl;

  @override
  Widget build(BuildContext context) {
    return _Card(
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
                  'Get alerted at your selected meal times.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
              ],
            ),
          ),
          Obx(
            () => Switch(
              value: ctrl.isEnabled.value,
              onChanged: ctrl.setEnabled,
              activeColor: AppColors.primaryGreenDark,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Mode picker ──────────────────────────────────────────────────────────────

class _ModePicker extends StatelessWidget {
  const _ModePicker({required this.ctrl});
  final MealRemindersController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDefault = ctrl.mode.value == MealRemindersMode.defaultSchedule;
      return _Card(
        padding: EdgeInsets.all(8.w),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.inputBackgroundOf(context),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.borderOf(context)),
          ),
          child: Row(
            children: [
              Expanded(
                child: _ModeChip(
                  label: 'Default',
                  selected: isDefault,
                  onTap: () => ctrl.setMode(MealRemindersMode.defaultSchedule),
                ),
              ),
              Expanded(
                child: _ModeChip(
                  label: 'Custom',
                  selected: !isDefault,
                  onTap: () => ctrl.setMode(MealRemindersMode.custom),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryGreenDark : Colors.transparent,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: selected ? Colors.white : AppColors.textPrimaryOf(context),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Default schedule section ─────────────────────────────────────────────────

class _DefaultScheduleSection extends StatelessWidget {
  const _DefaultScheduleSection({required this.ctrl});
  final MealRemindersController ctrl;

  @override
  Widget build(BuildContext context) {
    final hasApi = ctrl.defaultScheduleHasApiData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Attention / info banner ──────────────────────────────────────
        _InfoBanner(
          icon: Icons.info_outline_rounded,
          color: AppColors.primaryGreenDark,
          message: hasApi
              ? 'Your meal times are synced from your plan (shown in PKT). '
                    'Tap the ✏️ pen to update any time — changes are saved to your journey and will apply every day going forward.'
              : 'No plan times found yet. Showing suggested defaults. Tap ✏️ to customise any time. Changes are saved to your journey.',
        ),
        SizedBox(height: 14.h),
        _Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Default meal times',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimaryOf(context),
                      ),
                    ),
                  ),
                  if (hasApi)
                    _SmallBadge(
                      icon: Icons.cloud_done_rounded,
                      label: 'From plan',
                      color: AppColors.primaryGreenDark,
                    ),
                ],
              ),
              SizedBox(height: 14.h),
              // Reactive rows
              Obx(() {
                return Column(
                  children: ctrl.scheduleEntries.map((entry) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: _DefaultTimeRow(entry: entry, ctrl: ctrl),
                    );
                  }).toList(),
                );
              }),
              SizedBox(height: 6.h),
              Obx(() {
                final loading = ctrl.isApplyingDefault.value;
                return GestureDetector(
                  onTap: loading ? null : ctrl.applyDefaultSchedule,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: loading
                          ? AppColors.primaryGreenDark.withValues(alpha: 0.60)
                          : AppColors.primaryGreenDark,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (loading) ...[
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Text(
                            'Scheduling alarms…',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ] else ...[
                          Icon(
                            Icons.alarm_on_rounded,
                            color: Colors.white,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Use default schedule',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── One default time row with edit pens ──────────────────────────────────────

class _DefaultTimeRow extends StatelessWidget {
  const _DefaultTimeRow({required this.entry, required this.ctrl});
  final DefaultScheduleEntry entry;
  final MealRemindersController ctrl;

  @override
  Widget build(BuildContext context) {
    final label = MealRemindersController.displayMealName(entry.mealKey);

    // Formatted PKT strings
    final startStr = _fmt(entry.startPkt.hour, entry.startPkt.minute);
    final endStr = entry.endPkt != null
        ? _fmt(entry.endPkt!.hour, entry.endPkt!.minute)
        : null;

    // Original UTC row string (only if API gave us data)
    String? origLine;
    if (entry.utcStart != null) {
      final utcStartStr = _fmt(entry.utcStart!.hour, entry.utcStart!.minute);
      String combined = utcStartStr;
      if (entry.utcEnd != null) {
        combined += ' – ${_fmt(entry.utcEnd!.hour, entry.utcEnd!.minute)}';
      }
      final tz = entry.originalTz?.isNotEmpty == true
          ? entry.originalTz!
          : 'UTC';
      origLine = '$combined UTC · $tz';
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.inputBackgroundOf(context),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderOf(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 12.h, 10.w, 8.h),
            child: Row(
              children: [
                // Alarm icon
                Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreenDark.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    Icons.alarm_rounded,
                    color: AppColors.primaryGreenDark,
                    size: 17.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
              ],
            ),
          ),
          // Start time row with edit pen
          _EditableTimeField(
            label: 'Start',
            timeStr: '$startStr PKT',
            isLoading: entry.isUpdatingStart,
            onEdit: () async {
              final picked = await _pickTime(context, entry.startPkt);
              if (picked == null) return;
              await ctrl.updateEntryStartTime(entry, picked);
            },
          ),
          // End time row with edit pen
          _EditableTimeField(
            label: 'End',
            timeStr: endStr != null ? '$endStr PKT' : '—',
            isLoading: entry.isUpdatingEnd,
            onEdit: () async {
              final initial =
                  entry.endPkt ??
                  TimeOfDay(
                    hour: (entry.startPkt.hour + 1) % 24,
                    minute: entry.startPkt.minute,
                  );
              final picked = await _pickTime(context, initial);
              if (picked == null) return;
              await ctrl.updateEntryEndTime(entry, picked);
            },
          ),
          // UTC/tz reference row
          if (origLine != null)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 10.h),
              child: Row(
                children: [
                  Icon(
                    Icons.language_rounded,
                    size: 11.sp,
                    color: AppColors.textSecondaryOf(
                      context,
                    ).withValues(alpha: 0.65),
                  ),
                  SizedBox(width: 5.w),
                  Expanded(
                    child: Text(
                      origLine,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: AppColors.textSecondaryOf(
                          context,
                        ).withValues(alpha: 0.65),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          // Inline error (PATCH failure)
          if (entry.updateError != null)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 10.h),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      size: 13.sp,
                      color: AppColors.error,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        entry.updateError!,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<TimeOfDay?> _pickTime(BuildContext ctx, TimeOfDay init) {
    return showTimePicker(context: ctx, initialTime: init);
  }
}

// ─── Editable time field row ──────────────────────────────────────────────────

class _EditableTimeField extends StatelessWidget {
  const _EditableTimeField({
    required this.label,
    required this.timeStr,
    required this.isLoading,
    required this.onEdit,
  });
  final String label;
  final String timeStr;
  final bool isLoading;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(14.w, 0, 10.w, 6.h),
      child: Row(
        children: [
          SizedBox(
            width: 36.w,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondaryOf(context),
              ),
            ),
          ),
          Icon(
            Icons.schedule_rounded,
            size: 12.sp,
            color: AppColors.primaryGreenDark,
          ),
          SizedBox(width: 5.w),
          Text(
            timeStr,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryGreenDark,
            ),
          ),
          const Spacer(),
          if (isLoading)
            SizedBox(
              width: 16.w,
              height: 16.w,
              child: const CircularProgressIndicator(
                strokeWidth: 1.8,
                color: AppColors.primaryGreenDark,
              ),
            )
          else
            InkWell(
              onTap: onEdit,
              borderRadius: BorderRadius.circular(10.r),
              child: Container(
                padding: EdgeInsets.all(7.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreenDark.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  size: 14.sp,
                  color: AppColors.primaryGreenDark,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Custom alarms section ────────────────────────────────────────────────────

class _CustomAlarmsSection extends StatelessWidget {
  const _CustomAlarmsSection({required this.ctrl});
  final MealRemindersController ctrl;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final items = ctrl.customAlarms.toList();
      return _Card(
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
                  : 'Toggle individual alarms on or off. Each alarm fires daily at its set PKT time.',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondaryOf(context),
                height: 1.35,
              ),
            ),
            SizedBox(height: 14.h),
            if (items.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: AppColors.inputBackgroundOf(context),
                  borderRadius: BorderRadius.circular(14.r),
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
                        'Tap the + button to add your first alarm.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondaryOf(context),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              ...items.map((alarm) {
                final t = _fmt(alarm.hour, alarm.minute);
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.inputBackgroundOf(context),
                      borderRadius: BorderRadius.circular(14.r),
                      border: Border.all(color: AppColors.borderOf(context)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                MealRemindersController.displayMealName(
                                  alarm.mealKey,
                                ),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimaryOf(context),
                                ),
                              ),
                              SizedBox(height: 3.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule_rounded,
                                    size: 12.sp,
                                    color: AppColors.primaryGreenDark,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '$t PKT',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryGreenDark,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: alarm.enabled,
                          onChanged: (v) => ctrl.toggleAlarm(alarm, v),
                          activeColor: AppColors.primaryGreenDark,
                        ),
                        SizedBox(width: 4.w),
                        InkWell(
                          onTap: () => ctrl.deleteAlarm(alarm),
                          borderRadius: BorderRadius.circular(12.r),
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
          ],
        ),
      );
    });
  }
}

// ─── Add alarm bottom sheet ───────────────────────────────────────────────────

class _AddAlarmResult {
  const _AddAlarmResult({required this.mealKey, required this.time});
  final String mealKey;
  final TimeOfDay time;
}

class _AddAlarmSheet extends StatefulWidget {
  const _AddAlarmSheet();
  @override
  State<_AddAlarmSheet> createState() => _AddAlarmSheetState();
}

class _AddAlarmSheetState extends State<_AddAlarmSheet> {
  static const _keys = ['breakfast', 'lunch', 'snacks', 'dinner'];
  String _mealKey = _keys.first;
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
            SizedBox(height: 5.h),
            Text(
              'Choose a meal and a PKT time. Multiple alarms allowed.',
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondaryOf(context),
              ),
            ),
            SizedBox(height: 16.h),
            _label(context, 'Meal'),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.inputBackgroundOf(context),
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: AppColors.borderOf(context)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _mealKey,
                  isExpanded: true,
                  icon: const Icon(Icons.expand_more),
                  items: _keys
                      .map(
                        (k) => DropdownMenuItem(
                          value: k,
                          child: Text(
                            MealRemindersController.displayMealName(k),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => _mealKey = v);
                  },
                ),
              ),
            ),
            SizedBox(height: 14.h),
            _label(context, 'Time (PKT — UTC+05:00)'),
            SizedBox(height: 8.h),
            InkWell(
              onTap: () async {
                final p = await showTimePicker(
                  context: context,
                  initialTime: _time,
                );
                if (p != null) setState(() => _time = p);
              },
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: AppColors.inputBackgroundOf(context),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.borderOf(context)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 18.sp,
                      color: AppColors.primaryGreenDark,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_fmt(_time.hour, _time.minute)} PKT',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimaryOf(context),
                            ),
                          ),
                          Text(
                            'Pakistan Standard Time (UTC+05:00)',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: AppColors.textSecondaryOf(context),
                            ),
                          ),
                        ],
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

  Widget _label(BuildContext context, String text) => Text(
    text,
    style: TextStyle(
      fontSize: 12.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.textSecondaryOf(context),
    ),
  );
}

// ─── Reusable widgets ─────────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child, this.padding});
  final Widget child;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
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
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.color,
    required this.message,
  });
  final IconData icon;
  final Color color;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18.sp, color: color),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textPrimaryOf(context),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({
    required this.icon,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shared time formatter ────────────────────────────────────────────────────

String _fmt(int hour, int minute) {
  final period = hour < 12 ? 'AM' : 'PM';
  final h = hour % 12 == 0 ? 12 : hour % 12;
  final m = minute.toString().padLeft(2, '0');
  return '$h:$m $period';
}
