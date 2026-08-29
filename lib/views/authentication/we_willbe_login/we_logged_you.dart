import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import '../../../utils/assets_manager.dart';
import '../../../utils/colors.dart';
import 'we_logged_controller.dart';

class WeLoggedYou extends StatelessWidget {
  WeLoggedYou({super.key});

  final weLoggedController = Get.put(WeLoggedController());

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = context.landscape;

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
            padding: isLandscape
                ? EdgeInsets.all(context.sp(12))
                : EdgeInsets.only(
                    top: context.h(20),
                    left: context.w(20),
                    right: context.w(20),
                    bottom: context.h(20),
                  ),
            child: Flex(
              direction: isLandscape ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // HEADER SECTION (Logo)
                // ==========================================
                SizedBox(
                  width: isLandscape
                      ? MediaQuery.of(context).size.width * 0.40
                      : double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isLandscape) SizedBox(height: context.h(20)),
                      // Logo
                      Center(
                        child: Container(
                          width: context.w(225),
                          height: context.h(112),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(ImageManager.splashScreenLogo),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                      if (!isLandscape) SizedBox(height: context.h(21)),
                    ],
                  ),
                ),

                if (isLandscape) SizedBox(width: context.w(16)),

                // ==========================================
                // CONTENT SECTION
                // ==========================================
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isLandscape) SizedBox(height: context.h(20)),
                        Text(
                          'We’ve logged you in',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.sp(25),
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w700,
                            height: 1.12,
                          ),
                        ),
                        SizedBox(height: context.h(21)),
                        Text(
                          'You can now continue to Right Route. If you ve forgotten your password, you can choose a new one now or update it from your account Settings another time.',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.sp(18),
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: context.h(29)),

                        // ======================== BUTTONS ======================
                        /// CONTINUE BUTTON
                        Obx(() => CustomButton(
                              text: weLoggedController.isLoading.value
                                  ? 'LOADING...'
                                  : 'CONTINUE',
                              width: context.w(392),
                              backgroundColor: AppColors.orange,
                              isLoading: weLoggedController.isLoading.value,
                              showSpinner: false,
                              onPressed: weLoggedController.isLoading.value
                                  ? null
                                  : () async {
                                      await weLoggedController
                                          .fetchUserInfoAndRoute();
                                    },
                              fontSize: 24,
                            )),

                        SizedBox(height: context.h(25)),

                        /// CHANGE PASSWORD BUTTON
                        CustomButton(
                          text: 'CHANGE PASSWORD',
                          width: context.w(392),
                          backgroundColor: AppColors.medGray,
                          onPressed: () {
                            Get.toNamed(AppRoutes.changePassword);
                          },
                          fontSize: 24,
                        ),

                        SizedBox(height: context.h(50)),
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
