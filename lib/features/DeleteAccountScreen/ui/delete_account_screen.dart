import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/features/DeleteAccountScreen/widget/delete_account_header.dart';
import 'package:ai_meal_planner/features/DeleteAccountScreen/widget/delete_account_password_card.dart';
import 'package:ai_meal_planner/features/DeleteAccountScreen/widget/delete_account_warning_card.dart';
import 'package:ai_meal_planner/routes/app_routes.dart';
import 'package:ai_meal_planner/shared/widgets/app_filled_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isDeleting = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleDeleteAccount() async {
    FocusScope.of(context).unfocus();
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      AppSnackbar.error(
        'Password required',
        'Enter your password before deleting the account.',
      );
      return;
    }

    if (password.length < 6) {
      AppSnackbar.error(
        'Password too short',
        'Password must be at least 6 characters.',
      );
      return;
    }

    setState(() => _isDeleting = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));

    if (!mounted) {
      return;
    }

    Get.offAllNamed(AppRoutes.login);
    AppSnackbar.error(
      'Account deleted',
      'Your account has been removed from this demo flow.',
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
              SizedBox(height: 18.h),
              DeleteAccountPasswordCard(
                controller: _passwordController,
                obscurePassword: _obscurePassword,
                onToggleVisibility: () {
                  setState(() => _obscurePassword = !_obscurePassword);
                },
              ),
              SizedBox(height: 24.h),
              AppFilledButton(
                label: 'Delete account permanently',
                onPressed: _handleDeleteAccount,
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.textWhite,
                isLoading: _isDeleting,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
