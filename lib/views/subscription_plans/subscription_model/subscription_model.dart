class SubscriptionPlanModel {
  final int id;
  final String title;
  final String description;
  final String price;
  final String billingType;
  final String planType;
  final int? teamLimit;
  final bool isActive;

  SubscriptionPlanModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.billingType,
    required this.planType,
    this.teamLimit,
    required this.isActive,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '-1') ?? -1,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      price: json['price']?.toString() ?? '0.00',
      billingType: json['billing_type']?.toString().toUpperCase() ?? '',
      planType: json['plan_type']?.toString() ?? '',
      teamLimit: json['team_limit'] != null ? int.tryParse(json['team_limit'].toString()) : null,
      isActive: json['is_active'] == 1 || json['is_active'] == true || json['is_active'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'billing_type': billingType,
      'plan_type': planType,
      'team_limit': teamLimit,
      'is_active': isActive,
    };
  }
}
