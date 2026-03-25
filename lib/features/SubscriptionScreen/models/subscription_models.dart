class SubscriptionFeature {
  const SubscriptionFeature({required this.title, required this.description});

  final String title;
  final String description;
}

class SubscriptionPlan {
  const SubscriptionPlan({
    required this.title,
    required this.priceLabel,
    required this.billingLabel,
    required this.description,
    required this.highlights,
    required this.features,
  });

  final String title;
  final String priceLabel;
  final String billingLabel;
  final String description;
  final List<String> highlights;
  final List<SubscriptionFeature> features;
}

class ActiveSubscription {
  const ActiveSubscription({required this.plan, required this.nextBillingDate});

  final SubscriptionPlan plan;
  final DateTime nextBillingDate;
}
