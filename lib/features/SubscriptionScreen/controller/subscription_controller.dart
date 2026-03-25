import 'package:ai_meal_planner/features/SubscriptionScreen/models/subscription_models.dart';
import 'package:get/get.dart';

class SubscriptionController extends GetxController {
  static SubscriptionController ensureRegistered() {
    if (Get.isRegistered<SubscriptionController>()) {
      return Get.find<SubscriptionController>();
    }

    return Get.put(SubscriptionController(), permanent: true);
  }

  static const SubscriptionPlan premiumPlan = SubscriptionPlan(
    title: 'Premium Plan',
    priceLabel: '\$9.99/mo',
    billingLabel: 'Monthly billing',
    description:
        'Unlock expert guidance, deeper AI personalization, and long-term planning tools built for measurable progress.',
    highlights: ['Unlimited AI chat', 'Dietitian consults', 'Priority support'],
    features: [
      SubscriptionFeature(
        title: 'Professional Dietitian Consultations',
        description: 'Direct access to certified nutrition experts.',
      ),
      SubscriptionFeature(
        title: 'Advanced AI Optimization',
        description:
            'AI-generated meal plans with enhanced personalization and efficiency for faster results.',
      ),
      SubscriptionFeature(
        title: 'Personalized Long-Term Plans',
        description:
            'Customized weekly or monthly diet plans tailored to user health goals.',
      ),
      SubscriptionFeature(
        title: 'Unlimited AI Chatbot Access',
        description:
            'Full access to AI guidance without the limitations guest or free users have.',
      ),
      SubscriptionFeature(
        title: 'Priority Support',
        description: 'Faster responses and support for app-related issues.',
      ),
      SubscriptionFeature(
        title: 'Enhanced Analytics & Insights',
        description:
            'Advanced progress tracking, trend analysis, and richer nutrition insights.',
      ),
    ],
  );

  final Rxn<ActiveSubscription> activeSubscription = Rxn<ActiveSubscription>();

  bool get hasPremium => activeSubscription.value != null;

  SubscriptionPlan get availablePlan => premiumPlan;

  void activatePremium() {
    activeSubscription.value = ActiveSubscription(
      plan: premiumPlan,
      nextBillingDate: DateTime.now().add(const Duration(days: 30)),
    );
  }

  void cancelPremium() {
    activeSubscription.value = null;
  }

  String formatDate(DateTime date) {
    const months = [
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

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }
}
