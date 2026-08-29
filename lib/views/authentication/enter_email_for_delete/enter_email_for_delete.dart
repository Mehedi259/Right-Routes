import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/controllers/auth/enter_email_for_delete_controller.dart';
import 'package:right_routes/utils/responsive_ext.dart';

class EnterEmailForDelete extends StatelessWidget {
  const EnterEmailForDelete({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EnterEmailForDeleteController());

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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.w(15)),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: context.h(15)),


                  Container(
                    width: context.w(225),
                    height: context.h(112),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(ImageManager.splashScreenLogo),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  SizedBox(height: context.h(21)),


                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enter your email to continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.sp(25),
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: context.h(21)),
                      Text(
                        "Log in to your Right Route account. If you don't have one, you will be prompted to create one.",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.sp(18),
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: context.h(28)),


                  Container(
                    width: double.infinity,
                    constraints: BoxConstraints(
                      minHeight: context.h(50),
                      maxHeight: context.h(70),
                      maxWidth: context.w(500),
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.medGray,
                      borderRadius: BorderRadius.circular(context.r(10)),
                    ),
                    child: TextFormField(
                      controller: controller.emailController,
                      onChanged: (value) => controller.updateEmail(value),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: context.sp(16),
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                        height: 1.4,
                        letterSpacing: 0.2,
                      ),
                      cursorColor: const Color(0xFFFFFFFF),
                      cursorHeight: context.h(22),
                      decoration: InputDecoration(
                        hintText: "Email",
                        hintStyle: TextStyle(
                          color: const Color(0xFFBFBFBF),
                          fontSize: context.sp(16),
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w400,
                        ),
                        isDense: false,
                        contentPadding: EdgeInsets.only(
                          top: context.h(15),
                          left: context.w(15),
                          right: context.w(10),
                          bottom: context.h(10),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  SizedBox(height: context.h(25)),


                  CustomButton(
                    text: 'CONTINUE',
                    width: double.infinity,
                    height: context.h(57),
                    fontSize: 24,
                    onPressed: () {
                      Get.toNamed(AppRoutes.loginAccount);
                      print('button clicked');
                      print('Email: ${controller.emailController.text}');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
