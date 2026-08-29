import 'package:flutter/material.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/core/constants/services/api_client.dart';
import 'package:right_routes/core/constants/api_config/home_api_constant/home_api_constant.dart';
import '../../../global_widgets/button_reusable_short_width.dart';
import '../../../utils/assets_manager.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:dio/dio.dart' as dio;
// ─── Controller ─────────────────────────────────────────────────────────────

import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:right_routes/core/constants/services/api_client.dart';
import 'package:right_routes/core/constants/api_config/home_api_constant/home_api_constant.dart';
import '../subscription_model/subscription_model.dart';

class ChooseTeamPlanController extends GetxController {
  var isLoadingPlans = false.obs;
  var isSubscribing = false.obs;

  var plan5 = Rxn<SubscriptionPlanModel>();
  var plan10 = Rxn<SubscriptionPlanModel>();
  var plan25 = Rxn<SubscriptionPlanModel>();
  var plan50 = Rxn<SubscriptionPlanModel>();
  var plan100 = Rxn<SubscriptionPlanModel>();

  var selected = "".obs;

  @override
  void onInit() {
    super.onInit();
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
          
          for (var item in list) {
            final model = SubscriptionPlanModel.fromJson(item);
            final limitStr = model.teamLimit?.toString() ?? '';
            if (limitStr == '5') {
              plan5.value = model;
            } else if (limitStr == '10') {
              plan10.value = model;
            } else if (limitStr == '25') {
              plan25.value = model;
            } else if (limitStr == '50') {
              plan50.value = model;
            } else if (limitStr == '100') {
              plan100.value = model;
            }
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch team plans',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoadingPlans.value = false;
    }
  }

  Future<void> subscribe() async {
    if (selected.value.isEmpty) {
      Get.snackbar('Error', 'Please select a plan',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    int planId = -1;
    if (selected.value == "plan5") {
      planId = plan5.value?.id ?? -1;
    } else if (selected.value == "plan10") {
      planId = plan10.value?.id ?? -1;
    } else if (selected.value == "plan25") {
      planId = plan25.value?.id ?? -1;
    } else if (selected.value == "plan50") {
      planId = plan50.value?.id ?? -1;
    } else if (selected.value == "plan100") {
      planId = plan100.value?.id ?? -1;
    }

    if (planId == -1) {
      Get.snackbar('Error', 'This plan is currently unavailable.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isSubscribing.value = true;
    try {
      final purchaseUrl = Uri.parse(HomeApiConstant.baseUrl + HomeApiConstant.purchasePlan);

      final purchaseResponse = await ApiClient.post(
        purchaseUrl,
        body: dio.FormData.fromMap({'plan_id': planId.toString()}),
      );

      if (purchaseResponse.statusCode == 201 || purchaseResponse.statusCode == 200) {
        final pData = purchaseResponse.data is String
            ? jsonDecode(purchaseResponse.data)
            : purchaseResponse.data;

        if (pData['success'] == true && pData['data'] != null && pData['data']['uuid'] != null) {
          final String uuid = pData['data']['uuid'];

          final verifyUrl = Uri.parse(HomeApiConstant.baseUrl + HomeApiConstant.purchaseVerify);
          final String platformStr = GetPlatform.isIOS ? 'ios' : 'android';

          final verifyResponse = await ApiClient.post(
            verifyUrl,
            body: dio.FormData.fromMap({
              'plan_id': planId.toString(),
              'subscription_plan_uuid': uuid,
              'platform': platformStr,
            }),
          );

          if (verifyResponse.statusCode == 201 || verifyResponse.statusCode == 200) {
            final vData = verifyResponse.data is String
                ? jsonDecode(verifyResponse.data)
                : verifyResponse.data;
                
            if (vData['success'] == true) {
              Get.snackbar('Success', 'Subscription purchased successfully!',
                  backgroundColor: Colors.green, colorText: Colors.white);
              Get.offAllNamed(AppRoutes.teamManager);
            } else {
              Get.snackbar('Error', vData['message'] ?? 'Failed to verify purchase',
                  backgroundColor: Colors.red, colorText: Colors.white);
            }
          } else {
            final errorData = verifyResponse.data is String ? jsonDecode(verifyResponse.data) : verifyResponse.data;
            Get.snackbar('Error', errorData['message'] ?? 'Failed to verify purchase with server',
                backgroundColor: Colors.red, colorText: Colors.white);
          }
        } else {
          Get.snackbar('Error', pData['message'] ?? 'Failed to get purchase UUID',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        final errorData = purchaseResponse.data is String ? jsonDecode(purchaseResponse.data) : purchaseResponse.data;
        Get.snackbar('Error', errorData['message'] ?? 'Failed to initiate purchase',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred during subscription',
          backgroundColor: Colors.red, colorText: Colors.white);
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
                        'Plans include dashboard, seat\nmanagement, support, and on-\nboarding. Cancel anytime.',
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

                      /// 🔹 Plan Tiles (Set 1)
                      Obx(() {
                        final price = controller.plan5.value?.price ?? "69.00";
                        return _planTile(context: context, 
                          title: "UP TO 5 DRIVERS",
                          price: "\$$price/MO",
                          badge: null,
                          selected: controller.selected.value == "plan5",
                          onTap: () => controller.selected.value = "plan5",
                        );
                      }),
                      SizedBox(height: context.h(12)),

                      Obx(() {
                        final price = controller.plan10.value?.price ?? "119.00";
                        return _planTile(context: context, 
                          title: "UP TO 10 DRIVERS",
                          price: "\$$price/MO",
                          badge: null,
                          selected: controller.selected.value == "plan10",
                          onTap: () => controller.selected.value = "plan10",
                        );
                      }),
                      SizedBox(height: context.h(12)),

                      Obx(() {
                        final price = controller.plan25.value?.price ?? "249.00";
                        return _planTile(context: context, 
                          title: "UP TO 25 DRIVERS",
                          price: "\$$price/MO",
                          badge: null,
                          selected: controller.selected.value == "plan25",
                          onTap: () => controller.selected.value = "plan25",
                        );
                      }),
                      SizedBox(height: context.h(12)),
                      /// 🔹 Plan Tiles (Set 2) – optional duplicate, different keys
                      Obx(() {
                        final price = controller.plan50.value?.price ?? "449.00";
                        return _planTile(context: context, 
                          title: "UP TO 50 DRIVERS",
                          price: "\$$price/MO",
                          badge: null,
                          selected: controller.selected.value == "plan50",
                          onTap: () => controller.selected.value = "plan50",
                        );
                      }),
                      SizedBox(height: context.h(12)),

                      Obx(() {
                        final price = controller.plan100.value?.price ?? "749.00";
                        return _planTile(context: context, 
                          title: "UP TO 100 DRIVERS",
                          price: "\$$price/MO",
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
                              onPressed: () {},
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

          /// Title
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.sp(24),
              fontFamily: 'League Gothic',
              fontWeight: FontWeight.w400,
              letterSpacing: 1,
              height: 1.17,
            ),
          ),

          const Spacer(),

          /// Price + Badge
          Column(
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
        ],
      ),
    ),
  );
}
