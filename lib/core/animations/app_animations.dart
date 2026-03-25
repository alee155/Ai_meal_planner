import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppMotion {
  const AppMotion._();

  static const Duration fast = Duration(milliseconds: 320);
  static const Duration medium = Duration(milliseconds: 360);
  static const Duration slow = Duration(milliseconds: 420);

  static Duration stagger(int index, {int initialMs = 100, int stepMs = 80}) {
    return Duration(milliseconds: initialMs + (index * stepMs));
  }
}

extension AppMotionWidget on Widget {
  Widget _animate({
    bool enabled = true,
    required Duration delay,
    Duration duration = AppMotion.medium,
    double? slideYBegin,
    double? slideXBegin,
    Offset? scaleBegin,
    Curve curve = Curves.easeOutCubic,
  }) {
    var animation = animate(
      target: enabled ? 1 : 0,
    ).fadeIn(delay: delay, duration: duration);

    if (slideYBegin != null) {
      animation = animation.slideY(begin: slideYBegin, end: 0, curve: curve);
    }

    if (slideXBegin != null) {
      animation = animation.slideX(begin: slideXBegin, end: 0, curve: curve);
    }

    if (scaleBegin != null) {
      animation = animation.scale(
        begin: scaleBegin,
        end: const Offset(1, 1),
        curve: curve,
      );
    }

    return animation;
  }

  Widget animateAuthChip({
    bool enabled = true,
    Duration delay = const Duration(milliseconds: 120),
  }) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.fast,
      slideXBegin: -0.08,
    );
  }

  Widget animateAuthContent({
    bool enabled = true,
    required Duration delay,
    double begin = 0.1,
  }) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.medium,
      slideYBegin: begin,
    );
  }

  Widget animateAuthCard({bool enabled = true, required Duration delay}) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.slow,
      slideYBegin: 0.1,
      scaleBegin: const Offset(0.975, 0.975),
    );
  }

  Widget animateAuthAction({bool enabled = true, required Duration delay}) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.fast,
      slideYBegin: 0.06,
    );
  }

  Widget animateDashboardHeader({
    bool enabled = true,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.fast,
      slideYBegin: -0.08,
    );
  }

  Widget animateDashboardCard({bool enabled = true, required Duration delay}) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.medium,
      slideXBegin: 0.06,
      scaleBegin: const Offset(0.985, 0.985),
    );
  }

  Widget animateDashboardPanel({bool enabled = true, required Duration delay}) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.medium,
      slideYBegin: 0.06,
    );
  }

  Widget animateDashboardAction({
    bool enabled = true,
    required Duration delay,
  }) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.fast,
      slideYBegin: 0.1,
    );
  }

  Widget animateSettingsHeader({
    bool enabled = true,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.fast,
      slideYBegin: -0.05,
    );
  }

  Widget animateSettingsCard({
    bool enabled = true,
    required Duration delay,
    Offset scaleBegin = const Offset(0.988, 0.988),
  }) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.medium,
      slideYBegin: 0.05,
      scaleBegin: scaleBegin,
    );
  }

  Widget animateSettingsSection({
    bool enabled = true,
    required Duration delay,
  }) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.fast,
      slideYBegin: 0.04,
    );
  }

  Widget animateSettingsAction({bool enabled = true, required Duration delay}) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.fast,
      slideYBegin: 0.03,
    );
  }

  Widget animatePlanHeader({
    bool enabled = true,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.fast,
      slideXBegin: -0.05,
    );
  }

  Widget animatePlanSummary({bool enabled = true, required Duration delay}) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.medium,
      slideYBegin: 0.07,
      scaleBegin: const Offset(0.985, 0.985),
    );
  }

  Widget animatePlanMeal({
    bool enabled = true,
    required Duration delay,
    bool fromLeft = true,
  }) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.fast,
      slideXBegin: fromLeft ? -0.08 : 0.08,
    );
  }

  Widget animatePlanAction({bool enabled = true, required Duration delay}) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.fast,
      slideYBegin: 0.08,
      scaleBegin: const Offset(0.99, 0.99),
    );
  }

  Widget animateProfileHeader({
    bool enabled = true,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.fast,
      slideYBegin: -0.04,
    );
  }

  Widget animateProfileAvatar({bool enabled = true, required Duration delay}) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.medium,
      slideYBegin: 0.05,
      scaleBegin: const Offset(0.94, 0.94),
    );
  }

  Widget animateProfileSection({bool enabled = true, required Duration delay}) {
    return _animate(
      enabled: enabled,
      delay: delay,
      duration: AppMotion.medium,
      slideYBegin: 0.05,
    );
  }
}
