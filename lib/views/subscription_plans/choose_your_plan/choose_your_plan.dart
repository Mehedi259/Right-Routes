import 'package:flutter/material.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:get/get.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'package:dio/dio.dart' as dio;
import 'package:right_routes/core/constants/services/api_client.dart';
import 'package:right_routes/core/constants/api_config/home_api_constant/home_api_constant.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import '../../../global_widgets/button_reusable_short_width.dart';
import '../../../utils/assets_manager.dart';
import '../subscription_model/subscription_model.dart';

class PlanController extends GetxController {
  var isLoadingPlans = false.obs;
  var isSubscribing = false.obs;
  
  // Storing the specific plans we find from the API
  var monthlyPlan = Rxn<SubscriptionPlanModel>();
  var annualPlan = Rxn<SubscriptionPlanModel>();

  var selected = "".obs;
  var selectedPlanId = (-1).obs;

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
        'plan_type': 'individual',
        'is_active': 'true',
      });

      final response = await ApiClient.get(uri);

      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        if (data['success'] == true) {
          final List list = data['data'] ?? [];
          
          for (var item in list) {
            final model = SubscriptionPlanModel.fromJson(item);
            final bType = model.billingType;
            if (bType == 'MONTHLY') {
              monthlyPlan.value = model;
            } else if (bType == 'ANNUAL') {
              annualPlan.value = model;
            }
          }
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch plans',
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
    if (selected.value == "monthly") {
      planId = monthlyPlan.value?.id ?? -1;
    } else if (selected.value == "annual") {
      planId = annualPlan.value?.id ?? -1;
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
              Get.offAllNamed(AppRoutes.homeScreen); // Redirect to Home or appropriate screen
            } else {
              Get.snackbar('Error', vData['message'] ?? 'Failed to verify purchase',
                  backgroundColor: Colors.red, colorText: Colors.white);
            }
          } else {
            Get.snackbar('Error', 'Failed to verify purchase with server',
                backgroundColor: Colors.red, colorText: Colors.white);
          }
        } else {
          Get.snackbar('Error', 'Failed to get purchase UUID',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } else {
        Get.snackbar('Error', 'Failed to initiate purchase',
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

class ChooseYourPlan extends StatelessWidget {
  const ChooseYourPlan({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PlanController());

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
          child: Column(
            children: [
              SizedBox(height: context.h(20)),
              
              /// Logo
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
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: context.w(15), right: context.w(15), top: context.w(20), bottom: context.w(20)),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        child: Column(
                          children: [
                            /// Title
                            Text(
                              'CHOOSE YOUR PLAN',
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
                            SizedBox(height: context.h(21)),

                            /// Subtitle
                            Text(
                              'Start your 7-day free trial and begin automating your routes. Cancel anytime.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.sp(18),
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w500,
                                height: context.h(1.56),
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: context.h(18)),

                            Text(
                              'Individual Plan Options',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.sp(20),
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w700,
                                height: context.h(1.10),
                              ),
                            ),

                            SizedBox(height: context.h(11)),

                            /// ============== ANNUAL PLAN TILE =================
                            Obx(() {
                              final price = controller.annualPlan.value?.price ?? "119.99";
                              return _planTile(context: context, 
                                title: "ANNUAL PLAN",
                                price: "\$$price/YR",
                                badge: "Save 33%",
                                selected: controller.selected.value == "annual",
                                onTap: () =>
                                    controller.selected.value = "annual",
                              );
                            }),

                            SizedBox(height: context.h(13)),

                            /// MONTHLY PLAN TILE
                            Obx(() {
                              final price = controller.monthlyPlan.value?.price ?? "14.99";
                              return _planTile(context: context, 
                                title: "MONTHLY PLAN",
                                price: "\$$price/MO",
                                badge: null,
                                selected:
                                    controller.selected.value == "monthly",
                                onTap: () =>
                                    controller.selected.value = "monthly",
                              );
                            }),

                            SizedBox(height: context.h(35)),
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
                            TextButton(
                              onPressed: () {
                                // planController.restoreSubscription();
                                Get.toNamed(AppRoutes.enterEmailScreen);
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "SIGN IN WITH DIFFERENT EMAIL",
                                    style: TextStyle(
                                      color: AppColors.purple,
                                      fontSize: context.sp(20),
                                      fontFamily: 'League Gothic',
                                      fontWeight: FontWeight.w400,
                                      height: context.h(1.50),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: context.h(85)),
                            TextButton(
                              onPressed: () {
                                // planController.restoreSubscription();
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Already a subscriber?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.sp(16),
                                      fontFamily: 'Lato',
                                      fontWeight: FontWeight.w500,
                                      height: context.h(1.75),
                                    ),
                                  ),
                                  Text(
                                    'RESTORE SUBSCRIPTION',
                                    style: TextStyle(
                                      color: AppColors.purple,
                                      fontSize: context.sp(20),
                                      fontFamily: 'League Gothic',
                                      fontWeight: FontWeight.w400,
                                      height: context.h(1.40),
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: context.h(49)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

/// REUSABLE PLAN TILE (STATIC INSIDE THIS FILE)
Widget _planTile({required BuildContext context,
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
      height: context.h(76),
      padding: EdgeInsets.symmetric(horizontal: context.w(13)),
      decoration: BoxDecoration(
        color: selected ? AppColors.orange : AppColors.darkGray,
        // borderRadius: BorderRadius.circular(context.r(10)),
        border: Border.all(width: context.w(1), color: AppColors.medGray),
      ),
      child: Row(
        children: [
          /// LEFT SIDE CIRCLE (CHECK)
          Container(
            width: context.w(24),
            height: context.h(24),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border:
                  selected ? Border.all(color: Colors.white, width: context.w(2)) : null,
              color: selected ? AppColors.checkBoxColor : Colors.grey.shade500,
            ),
            child: selected
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),

          SizedBox(width: context.w(15)),

          /// TITLE
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.sp(24),
              fontFamily: 'League Gothic',
              fontWeight: FontWeight.w400,
              height: context.h(1.17),
              letterSpacing: 1,
            ),
          ),

          const Spacer(),

          /// PRICE + OPTIONAL BADGE
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(30),
                  fontFamily: 'League Gothic',
                  fontWeight: FontWeight.w400,
                  height: context.h(0.88),
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
                      color: AppColors.darkGray,
                      fontSize: context.sp(16),
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                      height: context.h(1.75),
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
