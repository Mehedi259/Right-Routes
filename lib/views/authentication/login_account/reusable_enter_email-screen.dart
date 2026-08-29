// file: views/common/reusable_enter_email_screen.dart  (নতুন ফোল্ডারে রাখতে পারো যাতে বোঝা যায় এটা reusable)

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/utils/colors.dart';

class ReusableEnterEmailScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onContinue;
  final Function(String)? onEmailSubmitted;

  const ReusableEnterEmailScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onContinue,
    this.onEmailSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EnterEmailController());
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
                ? EdgeInsets.all(context.s(12))
                : EdgeInsets.only(
                    top: context.h(20),
                    left: context.w(20),
                    right: context.w(20),
                    bottom: context.w(20),
                  ),
            child: Flex(
              direction: isLandscape ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // HEADER SECTION (Logo + Title)
                // ==========================================
                SizedBox(
                  width: isLandscape
                      ? MediaQuery.of(context).size.width * 0.45
                      : double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isLandscape) SizedBox(height: context.h(20)),
                      Center(
                        child: Container(
                          width: isLandscape
                              ? MediaQuery.of(context).size.width * 0.25
                              : context.w(225),
                          height: isLandscape
                              ? MediaQuery.of(context).size.height * 0.25
                              : context.h(112),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(ImageManager.splashScreenLogo),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: isLandscape ? context.s(10) : context.h(21)),
                      Text(
                        title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.sp(25),
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                          height: isLandscape ? context.s(12) : context.h(21)),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.sp(18),
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (!isLandscape) SizedBox(height: context.h(28)),
                    ],
                  ),
                ),

                if (isLandscape) SizedBox(width: context.w(15)),

                // ==========================================
                // FORM SECTION
                // ==========================================
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isLandscape) SizedBox(height: context.s(20)),
                        Container(
                          width: double.infinity,
                          height: context.h(57),
                          decoration: BoxDecoration(
                            color: AppColors.medGray,
                            borderRadius: BorderRadius.circular(context.r(10)),
                          ),
                          child: TextFormField(
                            controller: controller.emailController,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: context.sp(16),
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                              letterSpacing: 0.2,
                            ),
                            cursorColor: Colors.white,
                            cursorHeight: context.h(22),
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              hintText: "Email",
                              hintStyle: TextStyle(
                                color: Color(0xFFBFBFBF),
                                fontSize: context.sp(16),
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w400,
                              ),
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  vertical: context.h(14),
                                  horizontal: context.w(15)),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                            ),
                          ),
                        ),
                        SizedBox(height: context.h(25)),
                        CustomButton(
                          text: buttonText,
                          width: double.infinity,
                          height: context.h(57),
                          onPressed: () {
                            String email =
                                controller.emailController.text.trim();

                            if (email.isEmpty) {
                              Get.snackbar("Error", "Please enter your email",
                                  backgroundColor:
                                      Colors.red.withValues(alpha: 0.8),
                                  colorText: Colors.white);
                              return;
                            }

                            onEmailSubmitted?.call(email);
                            onContinue();
                            controller.emailController.clear();
                          },
                        ),
                        SizedBox(height: context.h(20)),
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

class EnterEmailController extends GetxController {
  final emailController = TextEditingController();

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
