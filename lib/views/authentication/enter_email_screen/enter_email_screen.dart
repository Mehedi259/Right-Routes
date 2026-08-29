import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/global_widgets/email_input_field.dart';
import 'package:right_routes/controllers/auth/enter_email_controller.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';

class EnterEmailScreen extends StatelessWidget {
  final controller = Get.put(EnterEmailController());

  EnterEmailScreen({super.key});

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
          child: isLandscape
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(width: context.w(20)),
                    // Logo — left side in landscape
                    _buildLogo(context),
                    SizedBox(width: context.w(20)),
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: context.w(15)),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.6,
                            ),
                            child: SingleChildScrollView(
                              child:
                                  _buildFormContent(context, showLogo: false),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Align(
                  alignment: Alignment.topCenter,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: context.w(20)),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: context.w(450)),
                      child: _buildFormContent(context, showLogo: true),
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Container(
      width: context.w(225),
      height: context.h(112),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(ImageManager.splashScreenLogo),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context, {required bool showLogo}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLogo) ...[
          SizedBox(height: context.h(40)),
          _buildLogo(context),
          SizedBox(height: context.h(21)),
        ],

        // Title + Description
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

        // Email input — reusable EmailInputField, fixed height 57
        EmailInputField(
          controller: controller.emailController,
        ),
        SizedBox(height: context.h(25)),

        // Continue Button — fontSize raw number, sp() CustomButton এ হবে
        Obx(() => CustomButton(
              text: controller.isLoading.value ? 'LOADING...' : 'CONTINUE',
              width: double.infinity,
              height: context.h(57),
              fontSize: 24, // ✅ raw number — CustomButton ভেতরে sp() করবে
              backgroundColor: controller.email.value.trim().isEmpty
                  ? AppColors.medGray
                  : AppColors.orange,
              isLoading: controller.isLoading.value,
              showSpinner: false,
              onPressed: controller.isLoading.value
                  ? null
                  : () => controller.checkEmail(),
            )),
      ],
    );
  }
}
