class SubscriptionPlanModel {
  final int id;
  final String productId;
  final String title;
  final String description;
  final String price;
  final String currency;
  final String billingType;
  final String planType;
  final int? teamLimit;
  final int trialDays;
  final Map<String, dynamic> featuresJson;
  final bool isActive;

  SubscriptionPlanModel({
    required this.id,
    this.productId = '',
    required this.title,
    required this.description,
    required this.price,
    this.currency = 'USD',
    required this.billingType,
    required this.planType,
    this.teamLimit,
    this.trialDays = 7,
    this.featuresJson = const {},
    required this.isActive,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    final rawFeatures = json['features_json'];
    return SubscriptionPlanModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '-1') ?? -1,
      productId: json['product_id']?.toString() ?? '',
      title: (json['title'] ?? json['name'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      price: json['price']?.toString() ?? '0.00',
      currency: (json['currency'] ?? 'USD').toString(),
      billingType: json['billing_type']?.toString().toUpperCase() ?? '',
      planType: json['plan_type']?.toString().toUpperCase() ?? '',
      teamLimit: json['team_limit'] != null ? int.tryParse(json['team_limit'].toString()) : null,
      trialDays: json['trial_days'] != null ? int.tryParse(json['trial_days'].toString()) ?? 7 : 7,
      featuresJson: rawFeatures is Map ? Map<String, dynamic>.from(rawFeatures) : const {},
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['is_active'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'title': title,
      'description': description,
      'price': price,
      'currency': currency,
      'billing_type': billingType,
      'plan_type': planType,
      'team_limit': teamLimit,
      'trial_days': trialDays,
      'features_json': featuresJson,
      'is_active': isActive,
    };
  }
}
