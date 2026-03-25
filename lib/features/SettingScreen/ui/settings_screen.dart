import 'package:ai_meal_planner/core/animations/app_animations.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/localization/locale_controller.dart';
import 'package:ai_meal_planner/core/theme/theme_controller.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/core/utils/app_validators.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/controller/subscription_controller.dart';
import 'package:ai_meal_planner/features/SubscriptionScreen/widgets/subscription_status_card.dart';
import 'package:ai_meal_planner/l10n/l10n.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_icon_back_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_outlined_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_text_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
  bool _mealReminders = true;
  bool _waterReminders = true;
  bool _weeklyInsights = false;
  bool _biometricLock = true;
  bool _marketingEmails = false;

  @override
  Widget build(BuildContext context) {
    final localeController = LocaleController.ensureRegistered();
    final subscriptionController = SubscriptionController.ensureRegistered();
    final screenBackground = AppColors.backgroundSecondaryOf(context);
    final surfaceColor = AppColors.surfaceOf(context);
    final textPrimary = AppColors.textPrimaryOf(context);

    return Scaffold(
      backgroundColor: screenBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader().animateSettingsHeader(
                enabled: widget.playEntranceAnimation,
              ),
              SizedBox(height: 20.h),
              Obx(
                () =>
                    _buildProfileCard(
                      hasPremium: subscriptionController.hasPremium,
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
                        onTap: () => _showInfoSheet(
                          title: 'Personal details',
                          message:
                              'Connect this tile to your profile edit flow when you are ready.',
                        ),
                      ),
                      _SettingsTile(
                        icon: Icons.lock_outline_rounded,
                        title: 'Change password',
                        subtitle: 'Update your account password securely',
                        onTap: _showChangePasswordSheet,
                      ),
                      _SettingsTile(
                        icon: Icons.devices_outlined,
                        title: 'Connected devices',
                        subtitle: 'Manage sessions across your devices',
                        trailing: _buildBadge('2 active'),
                        onTap: () => _showInfoSheet(
                          title: 'Connected devices',
                          message:
                              'Phone and tablet are currently signed in to this account.',
                        ),
                      ),
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
                      _SettingsSwitchTile(
                        icon: Icons.restaurant_menu_outlined,
                        title: 'Meal reminders',
                        subtitle: 'Breakfast, lunch, dinner, and snack alerts',
                        value: _mealReminders,
                        onChanged: (value) {
                          setState(() => _mealReminders = value);
                        },
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
                      _SettingsSwitchTile(
                        icon: Icons.fingerprint,
                        title: 'Biometric lock',
                        subtitle: 'Require Face ID or fingerprint to open app',
                        value: _biometricLock,
                        onChanged: (value) {
                          setState(() => _biometricLock = value);
                        },
                      ),
                      _SettingsSwitchTile(
                        icon: Icons.email_outlined,
                        title: 'Marketing emails',
                        subtitle: 'Product updates, offers, and app news',
                        value: _marketingEmails,
                        onChanged: (value) {
                          setState(() => _marketingEmails = value);
                        },
                      ),
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        title: 'Privacy policy',
                        subtitle:
                            'How your nutrition data is used and protected',
                        onTap: () => _showInfoSheet(
                          title: 'Privacy policy',
                          message:
                              'This can later open a webview or markdown page with your policy.',
                        ),
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
                icon: Icons.logout_rounded,
                label: 'Log out',
                color: textPrimary,
                backgroundColor: surfaceColor,
                onTap: _logout,
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
                onTap: _openDeleteAccountScreen,
              ).animateSettingsAction(
                enabled: widget.playEntranceAnimation,
                delay: AppMotion.stagger(9, initialMs: 140),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        if (widget.showBackButton) ...[
          AppIconBackButton(onTap: Get.back),
          SizedBox(width: 14.w),
        ],
        Expanded(
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
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard({required bool hasPremium}) {
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
              child: Image.network(
                'https://i.pravatar.cc/150?img=3',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.white.withValues(alpha: 0.2),
                  alignment: Alignment.center,
                  child: Text(
                    'AK',
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
                        'Ali Abbas',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.edit, size: 16.sp, color: Colors.white),
                    ),
                  ],
                ),

                SizedBox(height: 4.h),

                Text(
                  'ali12@gmail.com',
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
                    _buildProfileChip('Fat Loss', Icons.local_fire_department),
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
    var obscureCurrent = true;
    var obscureNew = true;
    var obscureConfirm = true;

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
            onPrimaryTap: () {
              if (!AppValidators.isValidPassword(
                    currentPasswordController.text,
                  ) ||
                  !AppValidators.isValidPassword(newPasswordController.text) ||
                  AppValidators.confirmPassword(
                        confirmPasswordController.text,
                        originalPassword: newPasswordController.text,
                      ) !=
                      null) {
                AppSnackbar.error(
                  'Check your password',
                  'Make sure all password fields are valid before continuing.',
                );
                return;
              }

              Get.back();
              AppSnackbar.success(
                'Password updated',
                'Your password has been changed successfully.',
              );
            },
            onSecondaryTap: () => Get.back(),
          );
        },
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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

  void _logout() {
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
    required this.onPrimaryTap,
    this.onSecondaryTap,
  });

  final String title;
  final String? message;
  final Widget? content;
  final String primaryLabel;
  final String? secondaryLabel;
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
