import 'dart:async';

import 'package:ai_meal_planner/core/constants/app_colors.dart';
import 'package:ai_meal_planner/features/AIChatScreen/models/ai_chat_models.dart';
import 'package:ai_meal_planner/features/AIChatScreen/widgets/ai_chat_app_bar_title.dart';
import 'package:ai_meal_planner/features/AIChatScreen/widgets/ai_chat_composer.dart';
import 'package:ai_meal_planner/features/AIChatScreen/widgets/ai_chat_message_bubble.dart';
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

  final List<ChatMessage> _messages = [
    const ChatMessage(
      text:
          'Welcome back. I can help with meal swaps, calories, cravings, hydration, and simple cooking guidance.',
      sender: ChatSender.ai,
      timestamp: '9:02 AM',
    ),
    const ChatMessage(
      text: 'I need a lighter dinner idea for today.',
      sender: ChatSender.user,
      timestamp: '9:03 AM',
    ),
    const ChatMessage(
      text:
          'Try grilled fish with sauteed vegetables and half a baked sweet potato. It keeps dinner around 430 kcal with strong protein.',
      sender: ChatSender.ai,
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
        ChatMessage(
          text: input,
          sender: ChatSender.user,
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
        ChatMessage(
          text: _buildMockReply(input),
          sender: ChatSender.ai,
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
      appBar: AppBar(
        backgroundColor: AppColors.backgroundSecondaryOf(context),
        surfaceTintColor: AppColors.backgroundSecondaryOf(context),
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        titleSpacing: 20.w,
        title: const AiChatAppBarTitle(),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping && index == _messages.length) {
                  return const AiChatTypingBubble();
                }

                final message = _messages[index];
                return AiChatMessageBubble(message: message);
              },
            ),
          ),
          AiChatComposer(
            quickPrompts: _quickPrompts,
            messageController: _messageController,
            isTyping: _isTyping,
            onPromptTap: _sendMessage,
            onSend: _sendMessage,
          ),
        ],
      ),
    );
  }
}
