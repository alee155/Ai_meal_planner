import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AiChatComposer extends StatelessWidget {
  const AiChatComposer({
    super.key,
    required this.quickPrompts,
    required this.messageController,
    required this.isTyping,
    required this.onPromptTap,
    required this.onSend,
  });

  final List<String> quickPrompts;
  final TextEditingController messageController;
  final bool isTyping;
  final ValueChanged<String> onPromptTap;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceOf(context),
        border: Border(top: BorderSide(color: AppColors.borderOf(context))),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 34.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: quickPrompts.length,
                separatorBuilder: (context, index) => SizedBox(width: 8.w),
                itemBuilder: (context, index) {
                  final prompt = quickPrompts[index];
                  return ActionChip(
                    label: Text(prompt),
                    side: BorderSide(color: AppColors.borderOf(context)),
                    backgroundColor: AppColors.backgroundSecondaryOf(context),
                    labelStyle: AppTextStyles.label(
                      context,
                      fontSize: 11,
                      color: AppColors.textPrimaryOf(context),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () => onPromptTap(prompt),
                  );
                },
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    minLines: 1,
                    maxLines: 4,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => onSend(),
                    style: AppTextStyles.body(
                      context,
                      color: AppColors.textPrimaryOf(context),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Ask about meals or calories...',
                      hintStyle: AppTextStyles.body(
                        context,
                        color: AppColors.textHintOf(context),
                      ),
                      filled: true,
                      fillColor: AppColors.inputBackgroundOf(context),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 13.h,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.r),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.r),
                        borderSide: BorderSide(
                          color: AppColors.inputBorderOf(context),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18.r),
                        borderSide: const BorderSide(
                          color: AppColors.primaryGreenDark,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                InkWell(
                  onTap: onSend,
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreenDark,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: isTyping
                        ? Padding(
                            padding: EdgeInsets.all(13.w),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(
                            Icons.arrow_upward_rounded,
                            color: Colors.white,
                          ),
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
