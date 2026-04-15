import 'package:ai_meal_planner/core/auth/controller/auth_session_controller.dart';
import 'package:ai_meal_planner/core/auth/models/auth_user.dart';
import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/core/utils/app_snackbar.dart';
import 'package:ai_meal_planner/shared/widgets/app_icon_back_button.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});

  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  late final AuthSessionController _authSessionController;

  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _authSessionController = AuthSessionController.ensureRegistered();
    WidgetsBinding.instance.addPostFrameCallback((_) => _refreshProfile());
  }

  Future<void> _refreshProfile() async {
    if (_isRefreshing || !_authSessionController.isLoggedIn) {
      return;
    }

    setState(() => _isRefreshing = true);

    try {
      await _authSessionController.fetchAndStoreCurrentUser();
    } catch (error) {
      if (!mounted) {
        return;
      }

      AppSnackbar.error(
        'Unable to refresh profile',
        error.toString().replaceFirst('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaceColor = AppColors.surfaceOf(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundSecondaryOf(context),
      appBar: AppBar(
        backgroundColor: AppColors.backgroundSecondaryOf(context),
        surfaceTintColor: AppColors.backgroundSecondaryOf(context),
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: EdgeInsets.only(left: 14.w),
          child: AppIconBackButton(onTap: Get.back),
        ),
        leadingWidth: 64.w,
        titleSpacing: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personal details',
              style: AppTextStyles.headline(context, fontSize: 23),
            ),
            Text(
              'Your account identity and status',
              style: AppTextStyles.body(context, fontSize: 12),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: InkWell(
              onTap: _isRefreshing ? null : _refreshProfile,
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                width: 42.w,
                height: 42.w,
                decoration: BoxDecoration(
                  color: surfaceColor,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: AppColors.borderOf(context)),
                ),
                child: _isRefreshing
                    ? Padding(
                        padding: EdgeInsets.all(11.w),
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppColors.primaryGreenDark,
                        ),
                      )
                    : Icon(
                        Icons.refresh_rounded,
                        color: AppColors.textPrimaryOf(context),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        final user = _authSessionController.currentUser.value;

        return RefreshIndicator(
          onRefresh: _refreshProfile,
          color: AppColors.primaryGreenDark,
          child: ListView(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 28.h),
            children: [
              _buildHeroCard(context, user),
              SizedBox(height: 18.h),
              _buildSectionTitle(context, 'Contact'),
              _buildDetailsCard(
                context,
                children: [
                  _DetailTile(
                    icon: Icons.badge_outlined,
                    label: 'Full name',
                    value: _valueOrPlaceholder(user?.name),
                  ),
                  _DetailTile(
                    icon: Icons.email_outlined,
                    label: 'Email address',
                    value: _valueOrPlaceholder(user?.email),
                  ),
                  _DetailTile(
                    icon: Icons.tag_outlined,
                    label: 'User ID',
                    value: _valueOrPlaceholder(user?.id),
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              _buildSectionTitle(context, 'Account status'),
              _buildDetailsCard(
                context,
                children: [
                  _DetailTile(
                    icon: Icons.verified_user_outlined,
                    label: 'Email verification',
                    value: user == null
                        ? 'Unavailable'
                        : user.isEmailVerified
                        ? 'Verified'
                        : 'Pending verification',
                    valueColor: user == null
                        ? null
                        : user.isEmailVerified
                        ? AppColors.primaryGreenDark
                        : AppColors.warning,
                  ),
                  _DetailTile(
                    icon: Icons.workspace_premium_outlined,
                    label: 'Plan',
                    value: user == null
                        ? 'Unavailable'
                        : user.isPremium
                        ? 'Premium'
                        : 'Free',
                  ),
                  _DetailTile(
                    icon: Icons.shield_outlined,
                    label: 'Account status',
                    value: user == null
                        ? 'Unavailable'
                        : user.isActive
                        ? 'Active'
                        : 'Inactive',
                    valueColor: user == null
                        ? null
                        : user.isActive
                        ? AppColors.primaryGreenDark
                        : AppColors.error,
                  ),
                ],
              ),
              SizedBox(height: 18.h),
              _buildSectionTitle(context, 'Timeline'),
              _buildDetailsCard(
                context,
                children: [
                  _DetailTile(
                    icon: Icons.event_available_outlined,
                    label: 'Member since',
                    value: _formatDate(user?.createdAt),
                  ),
                  _DetailTile(
                    icon: Icons.update_outlined,
                    label: 'Last updated',
                    value: _formatDate(user?.updatedAt),
                  ),
                  _DetailTile(
                    icon: Icons.image_outlined,
                    label: 'Profile photo',
                    value: (user?.resolvedProfileImageUrl ?? '').isEmpty
                        ? 'Not uploaded yet'
                        : 'Uploaded',
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeroCard(BuildContext context, AuthUser? user) {
    final initials = _resolveInitials(user);
    final profileImageUrl = user?.resolvedProfileImageUrl?.trim() ?? '';

    return Container(
      padding: EdgeInsets.all(20.w),
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
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildAvatar(
                initials: initials,
                profileImageUrl: profileImageUrl,
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _valueOrPlaceholder(user?.name),
                      style: AppTextStyles.headline(
                        context,
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _valueOrPlaceholder(user?.email),
                      style: AppTextStyles.body(
                        context,
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 18.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildHeroChip(
                user == null
                    ? 'Profile unavailable'
                    : user.isEmailVerified
                    ? 'Email verified'
                    : 'Verification pending',
                user?.isEmailVerified == true
                    ? Icons.verified_rounded
                    : Icons.mark_email_unread_outlined,
              ),
              _buildHeroChip(
                user == null
                    ? 'No plan info'
                    : user.isPremium
                    ? 'Premium member'
                    : 'Free member',
                user?.isPremium == true
                    ? Icons.workspace_premium_rounded
                    : Icons.shield_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({
    required String initials,
    required String profileImageUrl,
  }) {
    return Container(
      width: 72.w,
      height: 72.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
          width: 2,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      alignment: Alignment.center,
      child: profileImageUrl.isEmpty
          ? _buildAvatarFallback(initials)
          : CachedNetworkImage(
              imageUrl: profileImageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              placeholder: (_, _) => _buildAvatarLoader(),
              errorWidget: (_, _, _) => _buildAvatarFallback(initials),
            ),
    );
  }

  Widget _buildAvatarFallback(String initials) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildAvatarLoader() {
    return Center(
      child: SizedBox(
        width: 22.w,
        height: 22.w,
        child: const CircularProgressIndicator(
          strokeWidth: 2.2,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildHeroChip(String label, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: Colors.white),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: EdgeInsets.only(left: 4.w, bottom: 10.h),
      child: Text(
        title,
        style: AppTextStyles.label(
          context,
          fontSize: 13,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildDetailsCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderOf(context)),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowOf(context).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  String _valueOrPlaceholder(String? value) {
    final resolved = value?.trim() ?? '';
    return resolved.isEmpty ? 'Not available' : resolved;
  }

  String _resolveInitials(AuthUser? user) {
    final name = user?.name.trim() ?? '';
    if (name.isEmpty) {
      return 'AI';
    }

    final parts = name.split(RegExp(r'\s+')).where((part) => part.isNotEmpty);
    final initials = parts.take(2).map((part) => part[0].toUpperCase()).join();
    return initials.isEmpty ? 'AI' : initials;
  }

  String _formatDate(DateTime? value) {
    if (value == null) {
      return 'Not available';
    }

    const months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = months[local.month - 1];
    final year = local.year.toString();
    final hour24 = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final hour12 = ((hour24 + 11) % 12 + 1).toString().padLeft(2, '0');

    return '$day $month $year, $hour12:$minute $period';
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.dividerOf(context), width: 0.8),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42.w,
            height: 42.w,
            decoration: BoxDecoration(
              color: AppColors.chipBackgroundOf(context),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(icon, color: AppColors.primaryGreenDark, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.label(context, fontSize: 12)),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: AppTextStyles.title(
                    context,
                    fontSize: 15,
                    color: valueColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
