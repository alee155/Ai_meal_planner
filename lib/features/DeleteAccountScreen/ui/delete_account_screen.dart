import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/features/Account/controller/account_controller.dart';
import 'package:ai_meal_planner/features/DeleteAccountScreen/widget/delete_account_header.dart';
import 'package:ai_meal_planner/features/DeleteAccountScreen/widget/delete_account_warning_card.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:ai_meal_planner/shared/widgets/app_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final AccountController _accountController =
      AccountController.ensureRegistered();

  bool _isDeleting = false;
  bool _isDeactivating = false;

  Future<void> _handleDeleteAccount() async {
    FocusScope.of(context).unfocus();
    final confirmed = await _showConfirmationSheet(
      title: 'Delete account permanently',
      message:
          'This will permanently remove your account and all linked meal planning data.',
      confirmLabel: 'Delete account',
      confirmColor: AppColors.error,
    );
    if (confirmed != true) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() => _isDeleting = true);
    final result = await _accountController.deleteAccount();
    if (!mounted) {
      return;
    }

    setState(() => _isDeleting = false);
    if (!result.isSuccess) {
      AppSnackbar.error('Unable to delete account', result.message);
      return;
    }

    Get.offAllNamed(AppRoutes.login);
    AppSnackbar.error('Account deleted', result.message);
  }

  Future<void> _handleDeactivateAccount() async {
    FocusScope.of(context).unfocus();
    final confirmed = await _showConfirmationSheet(
      title: 'Deactivate account',
      message:
          'Your account access will be disabled for now, and you will be signed out immediately.',
      confirmLabel: 'Deactivate account',
      confirmColor: AppColors.warning,
    );
    if (confirmed != true) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() => _isDeactivating = true);
    final result = await _accountController.deactivateAccount();
    if (!mounted) {
      return;
    }

    setState(() => _isDeactivating = false);
    if (!result.isSuccess) {
      AppSnackbar.error('Unable to deactivate account', result.message);
      return;
    }

    Get.offAllNamed(AppRoutes.login);
    AppSnackbar.info('Account deactivated', result.message);
  }

  Future<bool?> _showConfirmationSheet({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
  }) {
    return showModalBottomSheet<bool>(
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
                  title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryOf(context),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  message,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.5,
                    color: AppColors.textSecondaryOf(context),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: AppOutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        label: 'Cancel',
                        foregroundColor: AppColors.textPrimaryOf(context),
                        borderColor: AppColors.borderOf(context),
                        borderRadius: 16,
                        paddingVertical: 15,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppFilledButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        label: confirmLabel,
                        backgroundColor: confirmColor,
                        foregroundColor: Colors.white,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondaryOf(context),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DeleteAccountHeader(onBackTap: Get.back),
              SizedBox(height: 20.h),
              const DeleteAccountWarningCard(),
              SizedBox(height: 24.h),
              AppOutlinedButton(
                onPressed: _isDeleting || _isDeactivating
                    ? null
                    : _handleDeactivateAccount,
                label: 'Deactivate account',
                foregroundColor: AppColors.warning,
                borderColor: AppColors.warning.withValues(alpha: 0.28),
                borderRadius: 18,
                paddingVertical: 16,
                fontSize: 15,
              ),
              SizedBox(height: 12.h),
              AppFilledButton(
                label: 'Delete account permanently',
                onPressed: _handleDeleteAccount,
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.textWhite,
                isLoading: _isDeleting || _isDeactivating,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
