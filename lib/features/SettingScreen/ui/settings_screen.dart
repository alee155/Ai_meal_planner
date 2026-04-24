import 'dart:io';

import 'package:ai_meal_planner/core/animations/app_animations.dart';
import 'package:ai_meal_planner/core/auth/controller/auth_session_controller.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/constants/app_links.dart';
import 'package:ai_meal_planner/core/localization/locale_controller.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/core/theme/theme_controller.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/core/utils/app_validators.dart';
import 'package:ai_meal_planner/features/Account/controller/account_controller.dart';
import 'package:ai_meal_planner/features/MealRemindersScreen/controller/meal_reminders_controller.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/controller/subscription_controller.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/widgets/subscription_status_card.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_icon_back_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_outlined_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_text_form_field.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    super.key,
    this.showBackButton = true,
    this.playEntranceAnimation = true,
  });

  final bool showBackButton;
  final bool playEntranceAnimation;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _waterReminders = true;
  bool _weeklyInsights = false;
  // bool _biometricLock = true;
  // bool _marketingEmails = false;

  @override
  Widget build(BuildContext context) {
    final authSessionController = AuthSessionController.ensureRegistered();
    final localeController = LocaleController.ensureRegistered();
    final subscriptionController = SubscriptionController.ensureRegistered();
    final mealRemindersController = MealRemindersController.ensureRegistered();
    final isGuest = authSessionController.isGuest;
    final screenBackground = AppColors.backgroundSecondaryOf(context);
    final surfaceColor = AppColors.surfaceOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);

    return Scaffold(
      backgroundColor: screenBackground,
      appBar: AppBar(
        backgroundColor: screenBackground,
        surfaceTintColor: screenBackground,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: widget.showBackButton
            ? Padding(
                padding: EdgeInsets.only(left: 14.w),
                child: AppIconBackButton(onTap: Get.back),
              )
            : const SizedBox.shrink(),
        leadingWidth: widget.showBackButton ? 64.w : 10.w,
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
                  'Settings',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
                Text(
                  'Manage your account, privacy, and subscription',
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
              ],
            ).animateSettingsHeader(enabled: widget.playEntranceAnimation),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(
              () =>
                  _buildProfileCard(
                    hasPremium: subscriptionController.hasPremium,
                    authSessionController: authSessionController,
                    isGuest: isGuest,
                  ).animateSettingsCard(
                    enabled: widget.playEntranceAnimation,
                    delay: AppMotion.stagger(1, initialMs: 120),
                    scaleBegin: const Offset(0.985, 0.985),
                  ),
            ),
            SizedBox(height: 18.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Account'),
                _buildSettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Personal details',
                      subtitle: 'Name, email, and profile preferences',
                      trailing: isGuest
                          ? Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.textHintOf(context),
                            )
                          : null,
                      onTap: () => isGuest
                          ? Get.toNamed(AppRoutes.login)
                          : Get.toNamed(AppRoutes.personalDetails),
                    ),
                    _SettingsTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Change password',
                      subtitle: 'Update your account password securely',
                      trailing: isGuest
                          ? Icon(
                              Icons.lock_outline_rounded,
                              color: AppColors.textHintOf(context),
                            )
                          : null,
                      onTap: isGuest
                          ? () => Get.toNamed(AppRoutes.login)
                          : _showChangePasswordSheet,
                    ),
                    // _SettingsTile(
                    //   icon: Icons.devices_outlined,
                    //   title: 'Connected devices',
                    //   subtitle: 'Manage sessions across your devices',
                    //   trailing: _buildBadge('2 active'),
                    //   onTap: () => _showInfoSheet(
                    //     title: 'Connected devices',
                    //     message:
                    //         'Phone and tablet are currently signed in to this account.',
                    //   ),
                    // ),
                  ],
                ),
              ],
            ).animateSettingsSection(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(2, initialMs: 140),
            ),
            SizedBox(height: 18.h),
            Obx(
              () =>
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(
                        subscriptionController.hasPremium
                            ? 'Subscription Plan'
                            : 'Available Subscription',
                      ),
                      subscriptionController.hasPremium
                          ? SubscriptionStatusCard(
                              subscription: subscriptionController
                                  .activeSubscription
                                  .value!,
                              primaryLabel: 'Manage plan',
                              onPrimaryTap: () =>
                                  Get.toNamed(AppRoutes.subscription),
                              secondaryLabel: 'View benefits',
                              onSecondaryTap: () =>
                                  Get.toNamed(AppRoutes.subscription),
                            )
                          : _buildAvailableSubscriptionCard(),
                    ],
                  ).animateSettingsSection(
                    enabled: widget.playEntranceAnimation,
                    delay: AppMotion.stagger(3, initialMs: 140),
                  ),
            ),
            SizedBox(height: 18.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Notifications'),
                _buildSettingsGroup(
                  children: [
                    Obx(
                      () => _SettingsTile(
                        icon: Icons.restaurant_menu_outlined,
                        title: 'Meal reminders',
                        subtitle: 'Breakfast, lunch, dinner, and snack alerts',
                        trailing: _buildBadge(
                          mealRemindersController.isEnabled.value
                              ? 'On'
                              : 'Off',
                        ),
                        onTap: () => Get.toNamed(AppRoutes.mealReminders),
                      ),
                    ),
                    _SettingsSwitchTile(
                      icon: Icons.water_drop_outlined,
                      title: 'Hydration reminders',
                      subtitle: 'Keep daily water goals on track',
                      value: _waterReminders,
                      onChanged: (value) {
                        setState(() => _waterReminders = value);
                      },
                    ),
                    _SettingsSwitchTile(
                      icon: Icons.insights_outlined,
                      title: 'Weekly insights',
                      subtitle: 'Get progress reports every Sunday',
                      value: _weeklyInsights,
                      onChanged: (value) {
                        setState(() => _weeklyInsights = value);
                      },
                    ),
                  ],
                ),
              ],
            ).animateSettingsSection(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(4, initialMs: 140),
            ),
            SizedBox(height: 18.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Appearance'),
                _buildSettingsGroup(
                  children: [
                    Obx(
                      () => _SettingsTile(
                        icon: Icons.translate_rounded,
                        title: context.l10n.language,
                        subtitle: context.l10n.languageSubtitle,
                        trailing: _buildBadge(
                          localeController.isUrdu
                              ? context.l10n.urdu
                              : context.l10n.english,
                        ),
                        onTap: () => _showLanguageSheet(localeController),
                      ),
                    ),
                    GetX<ThemeController>(
                      builder: (controller) => _SettingsSwitchTile(
                        icon: Icons.dark_mode_outlined,
                        title: 'Dark mode',
                        subtitle:
                            'Switch between light and dark theme for the app',
                        value: controller.isDarkMode,
                        onChanged: controller.toggleTheme,
                      ),
                    ),
                  ],
                ),
              ],
            ).animateSettingsSection(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(5, initialMs: 140),
            ),
            SizedBox(height: 18.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Privacy & Security'),
                _buildSettingsGroup(
                  children: [
                    // _SettingsSwitchTile(
                    //   icon: Icons.fingerprint,
                    //   title: 'Biometric lock',
                    //   subtitle: 'Require Face ID or fingerprint to open app',
                    //   value: _biometricLock,
                    //   onChanged: (value) {
                    //     setState(() => _biometricLock = value);
                    //   },
                    // ),
                    // _SettingsSwitchTile(
                    //   icon: Icons.email_outlined,
                    //   title: 'Marketing emails',
                    //   subtitle: 'Product updates, offers, and app news',
                    //   value: _marketingEmails,
                    //   onChanged: (value) {
                    //     setState(() => _marketingEmails = value);
                    //   },
                    // ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy policy',
                      subtitle: 'How your nutrition data is used and protected',
                      onTap: () => AppLinks.open(AppLinks.privacyPolicy),
                    ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Terms and conditions',
                      subtitle:
                          'Read the terms and conditions for using this app',
                      onTap: () => AppLinks.open(AppLinks.termsAndConditions),
                    ),
                  ],
                ),
              ],
            ).animateSettingsSection(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(6, initialMs: 140),
            ),
            SizedBox(height: 18.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('Support'),
                _buildSettingsGroup(
                  children: [
                    _SettingsTile(
                      icon: Icons.help_outline_rounded,
                      title: 'Help center',
                      subtitle: 'FAQs, troubleshooting, and guidance',
                      onTap: () => _showInfoSheet(
                        title: 'Help center',
                        message:
                            'This area is ready for FAQ content or customer support links.',
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Contact support',
                      subtitle: 'Reach the team for billing or account help',
                      onTap: () => _showInfoSheet(
                        title: 'Contact support',
                        message: 'Email: support@aimealplanner.app',
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      title: 'App version',
                      subtitle: 'AI Diet Planner 1.0.0',
                      trailing: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                      ),
                      onTap: null,
                    ),
                  ],
                ),
              ],
            ).animateSettingsSection(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(7, initialMs: 140),
            ),
            SizedBox(height: 22.h),
            _buildSecondaryAction(
              icon: isGuest ? Icons.login_rounded : Icons.logout_rounded,
              label: isGuest ? context.l10n.guestModeButtonSignIn : 'Log out',
              color: textPrimary,
              backgroundColor: surfaceColor,
              onTap: isGuest ? () => Get.toNamed(AppRoutes.login) : _logout,
            ).animateSettingsAction(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(8, initialMs: 140),
            ),
            SizedBox(height: 12.h),
            _buildSecondaryAction(
              icon: Icons.delete_forever_outlined,
              label: 'Delete account',
              color: AppColors.error,
              backgroundColor: AppColors.isDark(context)
                  ? AppColors.error.withValues(alpha: 0.12)
                  : const Color(0xFFFFF1F1),
              onTap: isGuest
                  ? () => Get.toNamed(AppRoutes.login)
                  : _openDeleteAccountScreen,
            ).animateSettingsAction(
              enabled: widget.playEntranceAnimation,
              delay: AppMotion.stagger(9, initialMs: 140),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard({
    required bool hasPremium,
    required AuthSessionController authSessionController,
    required bool isGuest,
  }) {
    final user = authSessionController.currentUser.value;
    final resolvedName = (user?.name.trim().isNotEmpty ?? false)
        ? user!.name.trim()
        : 'Guest user';
    final resolvedEmail = (user?.email.trim().isNotEmpty ?? false)
        ? user!.email.trim()
        : 'No email connected';
    final resolvedImageUrl = user?.resolvedProfileImageUrl;
    final initials = _resolveInitials(resolvedName);

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28.r),
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.primaryGreenDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreenDark.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          /// 🔥 Avatar with image + fallback
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: (resolvedImageUrl ?? '').isEmpty
                  ? Container(
                      color: Colors.white.withValues(alpha: 0.2),
                      alignment: Alignment.center,
                      child: Text(
                        initials,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : CachedNetworkImage(
                      imageUrl: resolvedImageUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) => Container(
                        color: Colors.white.withValues(alpha: 0.2),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
            ),
          ),

          SizedBox(width: 14.w),

          /// 🔥 User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Name + edit icon
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        resolvedName,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: isGuest
                          ? () => Get.toNamed(AppRoutes.login)
                          : _showEditProfileSheet,
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: EdgeInsets.all(6.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isGuest ? Icons.lock_outline_rounded : Icons.edit,
                          size: 16.sp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 4.h),

                Text(
                  resolvedEmail,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),

                SizedBox(height: 12.h),

                /// 🔥 Chips
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _buildProfileChip(
                      hasPremium ? 'Premium Plan' : 'Free Plan',
                      hasPremium
                          ? Icons.workspace_premium
                          : Icons.shield_outlined,
                    ),
                    _buildProfileChip(
                      user?.isEmailVerified == true
                          ? 'Email verified'
                          : 'Verification pending',
                      user?.isEmailVerified == true
                          ? Icons.verified_rounded
                          : Icons.mark_email_unread_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileChip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: Colors.white),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _resolveInitials(String name) {
    final parts = name
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .take(2)
        .toList();

    if (parts.isEmpty) {
      return 'AI';
    }

    return parts.map((part) => part[0].toUpperCase()).join();
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondaryOf(context),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOf(context).withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildAvailableSubscriptionCard() {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(22.r),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOf(context).withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.primarylightGreen,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: const Icon(
                  Icons.workspace_premium_outlined,
                  color: AppColors.primaryGreenDark,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Premium Plan',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimaryOf(context),
                      ),
                    ),
                    Text(
                      'Unlock expert guidance and advanced AI planning',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.textSecondaryOf(context),
                      ),
                    ),
                  ],
                ),
              ),
              _buildBadge('\$9.99/mo'),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: _buildPlanStat('AI Chat', 'Unlimited')),
              SizedBox(width: 10.w),
              Expanded(child: _buildPlanStat('Experts', 'Included')),
              SizedBox(width: 10.w),
              Expanded(child: _buildPlanStat('Insights', 'Advanced')),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: AppOutlinedButton(
                  onPressed: () => _showInfoSheet(
                    title: 'Premium benefits',
                    message:
                        'Dietitian consultations, advanced AI optimization, long-term plans, unlimited chatbot access, priority support, and enhanced insights are included.',
                  ),
                  label: 'View perks',
                  foregroundColor: AppColors.textPrimaryOf(context),
                  borderColor: AppColors.borderOf(context),
                  borderRadius: 16,
                  paddingVertical: 14,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: AppFilledButton(
                  onPressed: () => Get.toNamed(AppRoutes.subscription),
                  label: 'View plan',
                  backgroundColor: AppColors.primaryGreenDark,
                  foregroundColor: AppColors.textWhite,
                  borderRadius: 16,
                  paddingVertical: 14,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanStat(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundOf(context),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSecondaryOf(context),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryOf(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.chipBackgroundOf(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryGreenDark,
        ),
      ),
    );
  }

  Widget _buildSecondaryAction({
    required IconData icon,
    required String label,
    required Color color,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: color == AppColors.error
                ? AppColors.error.withValues(alpha: 0.16)
                : AppColors.borderOf(context),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16.sp, color: color),
          ],
        ),
      ),
    );
  }

  void _showInfoSheet({required String title, required String message}) {
    Get.bottomSheet(
      _SettingsBottomSheet(
        title: title,
        message: message,
        primaryLabel: 'Close',
        onPrimaryTap: () => Get.back(),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showLanguageSheet(LocaleController localeController) {
    Get.bottomSheet(
      _SettingsBottomSheet(
        title: context.l10n.chooseLanguage,
        message: context.l10n.languageSubtitle,
        content: Column(
          children: [
            _buildLanguageOption(
              label: context.l10n.english,
              isSelected: !localeController.isUrdu,
              onTap: () =>
                  _updateLanguage(localeController, const Locale('en')),
            ),
            SizedBox(height: 10.h),
            _buildLanguageOption(
              label: context.l10n.urdu,
              isSelected: localeController.isUrdu,
              onTap: () =>
                  _updateLanguage(localeController, const Locale('ur')),
            ),
          ],
        ),
        primaryLabel: context.l10n.change,
        onPrimaryTap: () => Get.back(),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildLanguageOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.chipBackgroundOf(context)
              : AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryGreenDark.withValues(alpha: 0.24)
                : AppColors.borderOf(context),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimaryOf(context),
                ),
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected
                  ? AppColors.primaryGreenDark
                  : AppColors.textSecondaryOf(context),
            ),
          ],
        ),
      ),
    );
  }

  void _updateLanguage(LocaleController localeController, Locale locale) {
    localeController.updateLanguage(locale);
    AppSnackbar.success(
      context.l10n.languageChangedTitle,
      context.l10n.languageChangedMessage,
    );
    Get.back();
  }

  void _showChangePasswordSheet() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final accountController = AccountController.ensureRegistered();
    var obscureCurrent = true;
    var obscureNew = true;
    var obscureConfirm = true;
    var isUpdating = false;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setModalState) {
          return _SettingsBottomSheet(
            title: 'Change password',
            message:
                'Use at least 6 characters and confirm the same new password before saving.',
            content: Column(
              children: [
                _buildSheetField(
                  controller: currentPasswordController,
                  hintText: 'Current password',
                  obscureText: obscureCurrent,
                  onToggle: () {
                    setModalState(() => obscureCurrent = !obscureCurrent);
                  },
                ),
                SizedBox(height: 12.h),
                _buildSheetField(
                  controller: newPasswordController,
                  hintText: 'New password',
                  obscureText: obscureNew,
                  onToggle: () {
                    setModalState(() => obscureNew = !obscureNew);
                  },
                ),
                SizedBox(height: 12.h),
                _buildSheetField(
                  controller: confirmPasswordController,
                  hintText: 'Confirm new password',
                  obscureText: obscureConfirm,
                  onToggle: () {
                    setModalState(() => obscureConfirm = !obscureConfirm);
                  },
                ),
              ],
            ),
            primaryLabel: 'Update password',
            secondaryLabel: 'Cancel',
            isPrimaryLoading: isUpdating,
            onPrimaryTap: () async {
              final currentPasswordError = AppValidators.requiredPassword(
                currentPasswordController.text,
              );
              final newPasswordError = AppValidators.requiredPassword(
                newPasswordController.text,
              );
              final confirmPasswordError = AppValidators.confirmPassword(
                confirmPasswordController.text,
                originalPassword: newPasswordController.text,
              );

              if (currentPasswordError != null ||
                  newPasswordError != null ||
                  confirmPasswordError != null) {
                AppSnackbar.error(
                  'Check your password',
                  currentPasswordError ??
                      newPasswordError ??
                      confirmPasswordError!,
                );
                return;
              }

              setModalState(() => isUpdating = true);
              final result = await accountController.updatePassword(
                currentPassword: currentPasswordController.text,
                newPassword: newPasswordController.text,
              );
              if (!mounted) {
                return;
              }

              setModalState(() => isUpdating = false);
              if (!result.isSuccess) {
                AppSnackbar.error('Unable to update password', result.message);
                return;
              }

              Get.back();
              AppSnackbar.success('Password updated', result.message);
            },
            onSecondaryTap: isUpdating ? null : () => Get.back(),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showEditProfileSheet() {
    final authSessionController = AuthSessionController.ensureRegistered();
    final accountController = AccountController.ensureRegistered();
    final user = authSessionController.currentUser.value;

    if (user == null) {
      AppSnackbar.error(
        'Profile unavailable',
        'Please log in again to edit your profile.',
      );
      return;
    }

    final nameController = TextEditingController(text: user.name);
    final picker = ImagePicker();
    XFile? selectedImage;
    var isUpdating = false;

    Get.bottomSheet(
      StatefulBuilder(
        builder: (sheetContext, setModalState) {
          Future<void> pickProfileImage() async {
            final source = await _showProfileImageSourceSheet(sheetContext);
            if (source == null) {
              return;
            }

            try {
              final pickedImage = await picker.pickImage(
                source: source,
                maxWidth: 1400,
                imageQuality: 88,
              );

              if (pickedImage == null) {
                return;
              }

              setModalState(() => selectedImage = pickedImage);
            } catch (_) {
              AppSnackbar.error(
                'Unable to open picker',
                'Please check gallery or camera permissions and try again.',
              );
            }
          }

          final localImageProvider = selectedImage != null
              ? FileImage(File(selectedImage!.path)) as ImageProvider<Object>
              : null;
          final remoteImageUrl = (user.resolvedProfileImageUrl ?? '').trim();

          return _SettingsBottomSheet(
            title: 'Edit profile',
            message:
                'Update your display name and choose a profile photo that feels familiar.',
            primaryLabel: 'Update profile',
            secondaryLabel: 'Cancel',
            isPrimaryLoading: isUpdating,
            content: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          InkWell(
                            onTap: isUpdating ? null : pickProfileImage,
                            borderRadius: BorderRadius.circular(999),
                            child: Container(
                              width: 110.w,
                              height: 110.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.chipBackgroundOf(context),
                                border: Border.all(
                                  color: AppColors.primaryGreenDark.withValues(
                                    alpha: 0.16,
                                  ),
                                  width: 1.6,
                                ),
                              ),
                              alignment: Alignment.center,
                              clipBehavior: Clip.antiAlias,
                              child: localImageProvider != null
                                  ? DecoratedBox(
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: localImageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      child: const SizedBox.expand(),
                                    )
                                  : remoteImageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: remoteImageUrl,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      errorWidget: (_, _, _) => Center(
                                        child: Text(
                                          _resolveInitials(nameController.text),
                                          style: TextStyle(
                                            fontSize: 30.sp,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.primaryGreenDark,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Text(
                                      _resolveInitials(nameController.text),
                                      style: TextStyle(
                                        fontSize: 30.sp,
                                        fontWeight: FontWeight.w800,
                                        color: AppColors.primaryGreenDark,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            right: -2.w,
                            bottom: -2.h,
                            child: Container(
                              width: 34.w,
                              height: 34.w,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreenDark,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.surfaceOf(context),
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.camera_alt_outlined,
                                size: 16.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          if (selectedImage != null)
                            Positioned(
                              top: -6.h,
                              right: -4.w,
                              child: InkWell(
                                onTap: isUpdating
                                    ? null
                                    : () => setModalState(
                                        () => selectedImage = null,
                                      ),
                                borderRadius: BorderRadius.circular(999),
                                child: Container(
                                  width: 28.w,
                                  height: 28.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.surfaceOf(context),
                                      width: 2,
                                    ),
                                  ),
                                  child: Icon(
                                    Icons.close_rounded,
                                    size: 15.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Tap avatar to choose from camera or gallery',
                        style: AppTextStyles.body(context, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 18.h),
                AppTextFormField(
                  controller: nameController,
                  hintText: 'Full name',
                  prefixIcon: Icons.person_outline_rounded,
                  textCapitalization: TextCapitalization.words,
                ),
              ],
            ),
            onPrimaryTap: () async {
              final nameError = AppValidators.requiredFullName(
                nameController.text,
              );
              if (nameError != null) {
                AppSnackbar.error('Check your name', nameError);
                return;
              }

              setModalState(() => isUpdating = true);
              final result = await accountController.updateProfile(
                name: nameController.text,
                profileImagePath: selectedImage?.path,
              );

              if (!mounted) {
                return;
              }

              setModalState(() => isUpdating = false);
              if (!result.isSuccess) {
                AppSnackbar.error('Unable to update profile', result.message);
                return;
              }

              Get.back();
              AppSnackbar.success('Profile updated', result.message);
            },
            onSecondaryTap: isUpdating ? null : () => Get.back(),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<ImageSource?> _showProfileImageSourceSheet(BuildContext context) {
    return showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 26.h),
          decoration: BoxDecoration(
            color: AppColors.surfaceOf(context),
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          ),
          child: SafeArea(
            top: false,
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
                SizedBox(height: 18.h),
                Text(
                  'Choose profile photo',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Pick a new image from your gallery or capture one with the camera.',
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.5,
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
                SizedBox(height: 18.h),
                _ProfileImageSourceTile(
                  icon: Icons.photo_library_outlined,
                  title: 'Choose from gallery',
                  subtitle: 'Use an existing photo from your phone',
                  onTap: () => Navigator.of(context).pop(ImageSource.gallery),
                ),
                SizedBox(height: 10.h),
                _ProfileImageSourceTile(
                  icon: Icons.photo_camera_outlined,
                  title: 'Take a photo',
                  subtitle: 'Capture a new profile picture right away',
                  onTap: () => Navigator.of(context).pop(ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetField({
    required TextEditingController controller,
    required String hintText,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return AppTextFormField(
      controller: controller,
      hintText: hintText,
      obscureText: obscureText,
      suffixIcon: IconButton(
        onPressed: onToggle,
        icon: Icon(
          obscureText
              ? Icons.visibility_off_outlined
              : Icons.visibility_outlined,
          color: AppColors.textSecondaryOf(context),
        ),
      ),
      borderRadius: 16,
      horizontalPadding: 16,
      verticalPadding: 16,
      focusedBorderColor: AppColors.primaryGreen,
    );
  }

  void _openDeleteAccountScreen() {
    Get.toNamed(AppRoutes.deleteAccount);
  }

  Future<void> _logout() async {
    await AuthSessionController.ensureRegistered().clearSession();
    Get.offAllNamed(AppRoutes.login);
    AppSnackbar.info('Logged out', 'See you again soon.');
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: AppColors.chipBackgroundOf(context),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: AppColors.primaryGreenDark, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  SizedBox(height: 3.h),
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
            if (trailing case final Widget widget) widget,
            if (onTap != null) ...[
              SizedBox(width: 10.w),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16.sp,
                color: AppColors.textHintOf(context),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  const _SettingsSwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: AppColors.chipBackgroundOf(context),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(icon, color: AppColors.primaryGreenDark, size: 22.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
                SizedBox(height: 3.h),
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
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.primaryGreenDark,
          ),
        ],
      ),
    );
  }
}

class _SettingsBottomSheet extends StatelessWidget {
  const _SettingsBottomSheet({
    required this.title,
    this.message,
    this.content,
    required this.primaryLabel,
    this.secondaryLabel,
    this.isPrimaryLoading = false,
    required this.onPrimaryTap,
    this.onSecondaryTap,
  });

  final String title;
  final String? message;
  final Widget? content;
  final String primaryLabel;
  final String? secondaryLabel;
  final bool isPrimaryLoading;
  final VoidCallback onPrimaryTap;
  final VoidCallback? onSecondaryTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 14.h, 20.w, 26.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: SafeArea(
        top: false,
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
            SizedBox(height: 18.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimaryOf(context),
              ),
            ),
            if (message != null) ...[
              SizedBox(height: 8.h),
              Text(
                message!,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.5,
                  color: AppColors.textSecondaryOf(context),
                ),
              ),
            ],
            if (content != null) ...[SizedBox(height: 18.h), content!],
            SizedBox(height: 20.h),
            Row(
              children: [
                if (secondaryLabel != null) ...[
                  Expanded(
                    child: AppOutlinedButton(
                      onPressed: onSecondaryTap,
                      label: secondaryLabel!,
                      foregroundColor: AppColors.textPrimaryOf(context),
                      borderColor: AppColors.borderOf(context),
                      borderRadius: 16,
                      paddingVertical: 15,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
                Expanded(
                  child: AppFilledButton(
                    onPressed: onPrimaryTap,
                    label: primaryLabel,
                    backgroundColor: AppColors.primaryGreenDark,
                    foregroundColor: AppColors.textWhite,
                    isLoading: isPrimaryLoading,
                    borderRadius: 16,
                    paddingVertical: 15,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileImageSourceTile extends StatelessWidget {
  const _ProfileImageSourceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: AppColors.surfaceOf(context),
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: AppColors.borderOf(context)),
        ),
        child: Row(
          children: [
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: AppColors.chipBackgroundOf(context),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Icon(icon, color: AppColors.primaryGreenDark, size: 22.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimaryOf(context),
                    ),
                  ),
                  SizedBox(height: 4.h),
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
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16.sp,
              color: AppColors.textHintOf(context),
            ),
          ],
        ),
      ),
    );
  }
}
