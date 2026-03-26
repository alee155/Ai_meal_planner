import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:ai_meal_planner/features/AIChatScreen/models/ai_chat_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AiChatMessageBubble extends StatelessWidget {
  const AiChatMessageBubble({super.key, required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == ChatSender.user;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: isUser
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isUser
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 0.76.sw),
                child: Container(
                  padding: EdgeInsets.all(14.w),
                  decoration: BoxDecoration(
                    color: isUser
                        ? AppColors.primaryGreenDark
                        : AppColors.cardBackgroundOf(context),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.r),
                      topRight: Radius.circular(20.r),
                      bottomLeft: Radius.circular(isUser ? 20.r : 6.r),
                      bottomRight: Radius.circular(isUser ? 6.r : 20.r),
                    ),
                    border: isUser
                        ? null
                        : Border.all(color: AppColors.borderOf(context)),
                  ),
                  child: Text(
                    message.text,
                    style: AppTextStyles.body(
                      context,
                      height: 1.5,
                      color: isUser
                          ? Colors.white
                          : AppColors.textPrimaryOf(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Text(
            message.timestamp,
            style: AppTextStyles.caption(context, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class AiChatTypingBubble extends StatelessWidget {
  const AiChatTypingBubble({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              color: AppColors.cardBackgroundOf(context),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.borderOf(context)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                3,
                (index) => Container(
                  width: 8.w,
                  height: 8.w,
                  margin: EdgeInsets.only(right: index == 2 ? 0 : 6.w),
                  decoration: BoxDecoration(
                    color: AppColors.textHintOf(context),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 5.h),
          Text(
            'AI is typing...',
            style: AppTextStyles.caption(context, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
