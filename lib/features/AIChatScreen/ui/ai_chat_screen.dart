import 'dart:async';

import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AiChatScreen extends StatefulWidget {
  const AiChatScreen({super.key, this.playEntranceAnimation = true});

  final bool playEntranceAnimation;

  @override
  State<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends State<AiChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_ChatMessage> _messages = [
    const _ChatMessage(
      text:
          'Welcome back. I can help with meal swaps, calories, cravings, hydration, and simple cooking guidance.',
      sender: _ChatSender.ai,
      timestamp: '9:02 AM',
    ),
    const _ChatMessage(
      text: 'I need a lighter dinner idea for today.',
      sender: _ChatSender.user,
      timestamp: '9:03 AM',
    ),
    const _ChatMessage(
      text:
          'Try grilled fish with sauteed vegetables and half a baked sweet potato. It keeps dinner around 430 kcal with strong protein.',
      sender: _ChatSender.ai,
      timestamp: '9:03 AM',
    ),
  ];

  final List<String> _quickPrompts = const [
    'Swap my lunch',
    'Low-cal dinner',
    'Explain my macros',
    'Healthy snack ideas',
  ];

  bool _isTyping = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? preset]) async {
    final input = (preset ?? _messageController.text).trim();
    if (input.isEmpty || _isTyping) {
      return;
    }

    setState(() {
      _messages.add(
        _ChatMessage(
          text: input,
          sender: _ChatSender.user,
          timestamp: _formatTime(DateTime.now()),
        ),
      );
      _messageController.clear();
      _isTyping = true;
    });

    _scrollToBottom();

    await Future<void>.delayed(const Duration(milliseconds: 650));

    if (!mounted) {
      return;
    }

    setState(() {
      _messages.add(
        _ChatMessage(
          text: _buildMockReply(input),
          sender: _ChatSender.ai,
          timestamp: _formatTime(DateTime.now()),
        ),
      );
      _isTyping = false;
    });

    _scrollToBottom();
  }

  String _buildMockReply(String input) {
    final normalized = input.toLowerCase();

    if (normalized.contains('lunch') || normalized.contains('swap')) {
      return 'Swap today\'s lunch with grilled chicken wrap, cucumber yogurt, and fruit. It stays balanced and easier to prep during work hours.';
    }

    if (normalized.contains('dinner')) {
      return 'For dinner, go with a protein-first plate: baked salmon or tofu, roasted vegetables, and a smaller carb portion to stay satisfied without overshooting calories.';
    }

    if (normalized.contains('macro') || normalized.contains('protein')) {
      return 'A practical split for fat-loss days is to keep protein highest, then carbs around activity needs, with fats steady but moderate. Your current mock plan already leans in that direction.';
    }

    if (normalized.contains('snack') || normalized.contains('craving')) {
      return 'Try Greek yogurt with berries, roasted chickpeas, cottage cheese with cucumber, or an apple with peanut butter. Those usually control cravings better than sugary snacks.';
    }

    if (normalized.contains('water') || normalized.contains('hydration')) {
      return 'Aim to spread hydration across the day instead of catching up late. A simple rule is one glass with each meal and one between meals.';
    }

    return 'I can help with meal swaps, calorie-conscious options, grocery ideas, macro guidance, and easier cooking choices. Try asking about your next meal.';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour == 0
        ? 12
        : time.hour > 12
        ? time.hour - 12
        : time.hour;
    final minutes = time.minute.toString().padLeft(2, '0');
    final period = time.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minutes $period';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) {
        return;
      }

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 120.h,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSecondaryOf(context),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'AI Nutrition Coach',
                              style: AppTextStyles.headline(
                                context,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Quick food guidance, meal swaps, and calorie-aware suggestions.',
                              style: AppTextStyles.body(
                                context,
                                fontSize: 13,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primarylightGreen,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'AI Online',
                          style: AppTextStyles.label(
                            context,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryGreenDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(18.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28.r),
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryGreenDark,
                          AppColors.primaryGreen,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreenDark.withValues(
                            alpha: 0.22,
                          ),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s coaching focus',
                          style: AppTextStyles.label(
                            context,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Fat-loss support with high-protein meals and lighter evening calories.',
                          style: AppTextStyles.title(
                            context,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: 14.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: const [
                            _InsightChip(label: 'Goal 1700 kcal'),
                            _InsightChip(label: 'Protein-first'),
                            _InsightChip(label: 'Easy prep'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 14.h),
                  SizedBox(
                    height: 42.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _quickPrompts.length,
                      separatorBuilder: (context, index) =>
                          SizedBox(width: 8.w),
                      itemBuilder: (context, index) {
                        final prompt = _quickPrompts[index];
                        return ActionChip(
                          label: Text(prompt),
                          side: BorderSide(color: AppColors.borderOf(context)),
                          backgroundColor: AppColors.surfaceOf(context),
                          labelStyle: AppTextStyles.label(
                            context,
                            fontSize: 12,
                            color: AppColors.textPrimaryOf(context),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          onPressed: () => _sendMessage(prompt),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 14.h),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: AppColors.surfaceOf(context),
                  borderRadius: BorderRadius.circular(30.r),
                  border: Border.all(color: AppColors.borderOf(context)),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.fromLTRB(14.w, 18.h, 14.w, 12.h),
                        itemCount: _messages.length + (_isTyping ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (_isTyping && index == _messages.length) {
                            return const _TypingBubble();
                          }

                          final message = _messages[index];
                          return _MessageBubble(message: message);
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 14.h),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceOf(context),
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(30.r),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              minLines: 1,
                              maxLines: 4,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                              style: AppTextStyles.body(
                                context,
                                color: AppColors.textPrimaryOf(context),
                              ),
                              decoration: InputDecoration(
                                hintText:
                                    'Ask about meals, calories, cravings...',
                                hintStyle: AppTextStyles.body(
                                  context,
                                  color: AppColors.textHintOf(context),
                                ),
                                filled: true,
                                fillColor: AppColors.inputBackgroundOf(context),
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 14.h,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                  borderSide: BorderSide(
                                    color: AppColors.inputBorderOf(context),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20.r),
                                  borderSide: const BorderSide(
                                    color: AppColors.primaryGreenDark,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          InkWell(
                            onTap: _sendMessage,
                            borderRadius: BorderRadius.circular(18.r),
                            child: Container(
                              width: 54.w,
                              height: 54.w,
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreenDark,
                                borderRadius: BorderRadius.circular(18.r),
                              ),
                              child: _isTyping
                                  ? Padding(
                                      padding: EdgeInsets.all(14.w),
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.sender == _ChatSender.user;

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

class _TypingBubble extends StatelessWidget {
  const _TypingBubble();

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

class _InsightChip extends StatelessWidget {
  const _InsightChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        label,
        style: AppTextStyles.label(context, fontSize: 12, color: Colors.white),
      ),
    );
  }
}

enum _ChatSender { ai, user }

class _ChatMessage {
  const _ChatMessage({
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  final String text;
  final _ChatSender sender;
  final String timestamp;
}
