import 'package:flutter/material.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/utils/colors.dart';
import '../../../utils/assets_manager.dart';
import '../../global_widgets/button_reusable_short_width.dart';

class IndividualTeam extends StatelessWidget {
  const IndividualTeam({super.key});

  @override
  Widget build(BuildContext context) {
    // final planController = Get.put(PlanController());

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
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: context.h(29)),

                      /// Title
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: context.w(16)),
                        child: Text(
                          'INDIVIDUAL OR TEAM?',
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
                      ),
                      SizedBox(height: context.h(20)),

                      /// Subtitle
                      Text(
                        'Choose an option to start your 7-day free trial and begin automating your routes. Cancel anytime ',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.sp(18),
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: context.h(20)),

                      /// Individual Button
                      ButtonReusable(
                        text: "INDIVIDUAL",
                        width: context.w(250),
                        height: context.h(55),
                        fontSize: context.sp(24),
                        onPressed: () {
                          // planController.selectIndividual();
                          Get.toNamed(AppRoutes.chooseYourPlan);
                        },
                      ),
                      SizedBox(height: context.h(23)),

                      /// Team Button
                      ButtonReusable(
                        text: "TEAM",
                        width: context.w(250),
                        height: context.h(55),
                        fontSize: context.sp(24),
                        onPressed: () {
                          // planController.selectIndividual();
                          Get.toNamed(AppRoutes.chooseATeamPlan);
                        },
                      ),
                      SizedBox(height: context.h(206)),

                      /// Restore Subscription
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
                                color:AppColors.purple,
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
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

class IndividualTeamController extends GetxController {
  var selectedPlan = ''.obs;

  void selectIndividual() => selectedPlan.value = 'individual';
  void selectTeam() => selectedPlan.value = 'team';

  void restoreSubscription() {
    // Implement restore logic here
  }
}
