import 'package:flutter/material.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/core/constants/services/api_client.dart';
import 'package:right_routes/core/constants/services/subscription_billing_service.dart';
import 'package:right_routes/core/constants/api_config/home_api_constant/home_api_constant.dart';
import '../../../global_widgets/button_reusable_short_width.dart';
import '../../../utils/assets_manager.dart';
import 'dart:convert';
import '../subscription_model/subscription_model.dart';

// ─── Controller ─────────────────────────────────────────────────────────────

class ChooseTeamPlanController extends GetxController {
  var isLoadingPlans = false.obs;
  var isSubscribing = false.obs;
  final _billing = SubscriptionBillingService.instance;

  var plan5 = Rxn<SubscriptionPlanModel>();
  var plan10 = Rxn<SubscriptionPlanModel>();
  var plan25 = Rxn<SubscriptionPlanModel>();
  var plan50 = Rxn<SubscriptionPlanModel>();
  var plan100 = Rxn<SubscriptionPlanModel>();

  var selected = "".obs;

  @override
  void onInit() {
    super.onInit();
    _billing.ensureInitialized();
    fetchPlans();
  }

  Future<void> fetchPlans() async {
    isLoadingPlans.value = true;
    try {
      final uri = Uri.parse(
        HomeApiConstant.baseUrl + HomeApiConstant.subscriptionPlans,
      ).replace(queryParameters: {
        'plan_type': 'team',
        'billing_type': 'monthly',
        'is_active': 'true',
      });

      final response = await ApiClient.get(uri);

      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        if (data['success'] == true) {
          final List list = data['data'] ?? [];
          final Set<String> productIds = {
            SubscriptionBillingService.productTeam5Monthly,
            SubscriptionBillingService.productTeam10Monthly,
            SubscriptionBillingService.productTeam25Monthly,
            SubscriptionBillingService.productTeam50Monthly,
            SubscriptionBillingService.productTeam100Monthly,
          };

          for (var item in list) {
            final model = SubscriptionPlanModel.fromJson(item);
            if (model.productId.isNotEmpty) {
              productIds.add(model.productId);
            }
            final limitStr = model.teamLimit?.toString() ?? '';
            if (limitStr == '5' || model.productId == SubscriptionBillingService.productTeam5Monthly) {
              plan5.value = model;
            } else if (limitStr == '10' || model.productId == SubscriptionBillingService.productTeam10Monthly) {
              plan10.value = model;
            } else if (limitStr == '25' || model.productId == SubscriptionBillingService.productTeam25Monthly) {
              plan25.value = model;
            } else if (limitStr == '50' || model.productId == SubscriptionBillingService.productTeam50Monthly) {
              plan50.value = model;
            } else if (limitStr == '100' || model.productId == SubscriptionBillingService.productTeam100Monthly) {
              plan100.value = model;
            }
          }

          await _billing.loadStoreProducts(productIds);
          plan5.refresh();
          plan10.refresh();
          plan25.refresh();
          plan50.refresh();
          plan100.refresh();
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch team plans',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoadingPlans.value = false;
    }
  }

  String displayPriceFor({
    required SubscriptionPlanModel? plan,
    required String fallbackProductId,
    required String fallbackPrice,
  }) {
    final pid = (plan != null && plan.productId.isNotEmpty) ? plan.productId : fallbackProductId;
    final storePrice = _billing.storePriceFor(pid);
    if (storePrice != null && storePrice.isNotEmpty) {
      return '$storePrice/MO';
    }
    final raw = (plan?.price.isNotEmpty ?? false) ? plan!.price : fallbackPrice;
    return '\$$raw/MO';
  }

  Future<void> subscribe() async {
    if (selected.value.isEmpty) {
      Get.snackbar('Error', 'Please select a plan',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final SubscriptionPlanModel? chosenPlan = switch (selected.value) {
      'plan5' => plan5.value,
      'plan10' => plan10.value,
      'plan25' => plan25.value,
      'plan50' => plan50.value,
      'plan100' => plan100.value,
      _ => null,
    };

    if (chosenPlan == null || chosenPlan.id <= 0) {
      Get.snackbar('Error', 'This plan is currently unavailable.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isSubscribing.value = true;
    try {
      await _billing.purchasePlan(chosenPlan, isTeamFlow: true);
    } finally {
      isSubscribing.value = false;
    }
  }

  Future<void> restoreSubscription() async {
    if (isSubscribing.value) return;
    isSubscribing.value = true;
    try {
      await _billing.restoreSubscriptions();
    } finally {
      isSubscribing.value = false;
    }
  }
}

// ─── Screen ─────────────────────────────────────────────────────────────────

class ChooseATeamPlan extends StatelessWidget {
  const ChooseATeamPlan({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChooseTeamPlanController());

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageManager.mapBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(15)),
            child: Column(
              children: [
                SizedBox(height: context.h(20)),
              /// 🔥 FIXED LOGO (STICKY – does not scroll)
              Center(
                child: Container(
                  width: context.w(225),
                  height: context.h(112),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(ImageManager.splashScreenLogo),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              SizedBox(height: context.h(29)),

              /// 🔥 SCROLLABLE CONTENT (everything below logo)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      /// TITLE
                      Text(
                        'CHOOSE A TEAM PLAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.sp(32),
                          fontFamily: 'League Gothic',
                          fontWeight: FontWeight.w400,
                          height: context.h(0.88),
                          letterSpacing: 1,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: context.h(22)),

                      /// Subtitle
                      Text(
                        'Start your 7-day free trial. Plans include\ndashboard, seat management, support,\nand onboarding. Cancel anytime.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.sp(18),
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          height: 1.44,
                        ),
                      ),

                      SizedBox(height: context.h(19)),

                      /// 🔹 Plan Tiles
                      Obx(() {
                        final price = controller.displayPriceFor(
                          plan: controller.plan5.value,
                          fallbackProductId: SubscriptionBillingService.productTeam5Monthly,
                          fallbackPrice: "69.00",
                        );
                        return _planTile(context: context,
                          title: "UP TO 5 DRIVERS",
                          price: price,
                          badge: null,
                          selected: controller.selected.value == "plan5",
                          onTap: () => controller.selected.value = "plan5",
                        );
                      }),
                      SizedBox(height: context.h(12)),

                      Obx(() {
                        final price = controller.displayPriceFor(
                          plan: controller.plan10.value,
                          fallbackProductId: SubscriptionBillingService.productTeam10Monthly,
                          fallbackPrice: "119.00",
                        );
                        return _planTile(context: context,
                          title: "UP TO 10 DRIVERS",
                          price: price,
                          badge: null,
                          selected: controller.selected.value == "plan10",
                          onTap: () => controller.selected.value = "plan10",
                        );
                      }),
                      SizedBox(height: context.h(12)),

                      Obx(() {
                        final price = controller.displayPriceFor(
                          plan: controller.plan25.value,
                          fallbackProductId: SubscriptionBillingService.productTeam25Monthly,
                          fallbackPrice: "249.00",
                        );
                        return _planTile(context: context,
                          title: "UP TO 25 DRIVERS",
                          price: price,
                          badge: null,
                          selected: controller.selected.value == "plan25",
                          onTap: () => controller.selected.value = "plan25",
                        );
                      }),
                      SizedBox(height: context.h(12)),
                      Obx(() {
                        final price = controller.displayPriceFor(
                          plan: controller.plan50.value,
                          fallbackProductId: SubscriptionBillingService.productTeam50Monthly,
                          fallbackPrice: "449.00",
                        );
                        return _planTile(context: context,
                          title: "UP TO 50 DRIVERS",
                          price: price,
                          badge: null,
                          selected: controller.selected.value == "plan50",
                          onTap: () => controller.selected.value = "plan50",
                        );
                      }),
                      SizedBox(height: context.h(12)),

                      Obx(() {
                        final price = controller.displayPriceFor(
                          plan: controller.plan100.value,
                          fallbackProductId: SubscriptionBillingService.productTeam100Monthly,
                          fallbackPrice: "749.00",
                        );
                        return _planTile(context: context,
                          title: "UP TO 100 DRIVERS",
                          price: price,
                          badge: null,
                          selected: controller.selected.value == "plan100",
                          onTap: () => controller.selected.value = "plan100",
                        );
                      }),
                      SizedBox(height: context.h(10)),

                      SizedBox(
                        width: context.w(392),
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'Have more than 100 drivers? Contact sales or fill out the Fleet Pricing Request form on our website:\n',
                                style: TextStyle(color: Colors.white, fontSize: context.sp(16), fontFamily: 'Lato', fontWeight: FontWeight.w400, height: 1.44),
                              ),
                              TextSpan(
                                text: 'sales@getrightroute.app\n',
                                style: TextStyle(color: Colors.white, fontSize: context.sp(16), fontFamily: 'Lato', fontWeight: FontWeight.w700, decoration: TextDecoration.underline, height: 1.44),
                              ),
                              TextSpan(
                                text: 'https://getrightroute.app',
                                style: TextStyle(color: Colors.white, fontSize: context.sp(16), fontFamily: 'Lato', fontWeight: FontWeight.w700, decoration: TextDecoration.underline, height: 1.44),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      SizedBox(height: context.h(25)),

                      /// AGREEMENT + BUTTONS
                      TextButton(
                        onPressed: () {},
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'By clicking "Subscribe", you agree to\nour',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.sp(16),
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                                height: 1.20,
                              ),
                            ),
                            SizedBox(height: context.h(8)),

                            GestureDetector(
                              onTap: () {
                                Get.toNamed(AppRoutes.subscriberAgreement);
                              },
                              child: Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'DISCLAIMER ',
                                      style: TextStyle(
                                        color: AppColors.purple,
                                        fontSize: context.sp(20),
                                        fontFamily: 'League Gothic',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'and ',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: context.sp(16),
                                        fontFamily: 'Lato',
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'TERMS OF SERVICE',
                                      style: TextStyle(
                                        color: AppColors.purple,
                                        fontSize: context.sp(20),
                                        fontFamily: 'League Gothic',
                                        fontWeight: FontWeight.w400,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            SizedBox(height: context.h(23)),

                            /// SUBSCRIBE BUTTON
                            Obx(() => ButtonReusable(
                              text: controller.isSubscribing.value ? 'PLEASE WAIT...' : 'SUBSCRIBE',
                              onPressed: () {
                                if (!controller.isSubscribing.value) {
                                  controller.subscribe();
                                }
                              },
                              width: context.w(250),
                              height: context.h(55),
                            )),

                            SizedBox(height: context.h(6)),

                            // TextButton(
                            //   onPressed: () {},
                            //   child: Text(
                            //     'RIGHT ROUTE SUB SCRIBER AGREEMENT',
                            //     style: TextStyle(
                            //       color: AppColors.purple,
                            //       fontSize: context.sp(20),
                            //       fontFamily: 'League Gothic',
                            //       fontWeight: FontWeight.w400,
                            //       height: context.h(1.50),
                            //     ),
                            //   ),
                            // ),

                            SizedBox(height: context.h(47)),

                            /// RESTORE SUBSCRIPTION
                            TextButton(
                              onPressed: () {
                                controller.restoreSubscription();
                              },
                              child: Column(
                                children: [
                                  Text(
                                    'Already a subscriber?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.sp(16),
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w500,
                                      height: 1.75,
                                    ),
                                  ),
                                  Text(
                                    'RESTORE SUBSCRIPTION',
                                    style: TextStyle(
                                      color: AppColors.purple,
                                      fontSize: context.sp(20),
                                      fontFamily: 'League Gothic',
                                      fontWeight: FontWeight.w400,
                                      height: 1.40,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: context.h(70)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

// ─── Plan Tile — original design হুবহু same ──────────────────────────────────

Widget _planTile({
  required BuildContext context,
  required String title,
  required String price,
  required bool selected,
  required VoidCallback onTap,
  String? badge,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: context.w(392),
      height: context.h(53),
      padding: EdgeInsets.symmetric(horizontal: context.w(8)),
      decoration: BoxDecoration(
        color: selected ? AppColors.orange : AppColors.darkGray,
        border: Border.all(width: context.w(1), color: AppColors.medGray),
      ),
      child: Row(
        children: [
          /// Check circle
          Container(
            width: context.w(24),
            height: context.h(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: selected
                  ? Border.all(color: Colors.white, width: context.w(2))
                  : null,
              color: selected ? AppColors.checkBoxColor : Colors.grey.shade500,
            ),
            child: selected
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),

          SizedBox(width: context.w(7)),

          /// TITLE
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.sp(24),
                fontFamily: 'League Gothic',
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
                height: 1.17,
              ),
            ),
          ),

          SizedBox(width: context.w(8)),

          /// Price + Badge
          Flexible(
            fit: FlexFit.loose,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.sp(24),
                      fontFamily: 'League Gothic',
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                    ),
                  ),
                  if (badge != null)
                    Container(
                      margin: EdgeInsets.only(top: context.h(6)),
                      padding: EdgeInsets.symmetric(horizontal: context.w(9)),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(context.r(5)),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          color: AppColors.medGray,
                          fontSize: context.sp(16),
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
