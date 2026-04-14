import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'pulse_ring.dart';
import 'status_badge.dart';

class AlarmHeader extends StatelessWidget {
  const AlarmHeader({
    super.key,
    required this.isDark,
    required this.primary,
    required this.scheduledTime,
    required this.dateText,
    required this.currentTime,
  });

  final bool isDark;
  final Color primary;
  final String scheduledTime;
  final String dateText;
  final String currentTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [primary.withOpacity(0.6), primary]
              : [primary, primary.withOpacity(0.7)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(22.w, 16.h, 22.w, 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [StatusBadge()],
              ),
              SizedBox(height: 20.h),

              Center(
                child: PulseRing(
                  color: Colors.white,
                  child: Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.18),
                    ),
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 28.sp,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              Center(
                child: Text(
                  currentTime,
                  style: TextStyle(
                    fontSize: 58.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),

              SizedBox(height: 12.h),

              Center(
                child: Text(
                  dateText,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white.withOpacity(0.75),
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 14.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.14),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    'Scheduled for $scheduledTime',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
