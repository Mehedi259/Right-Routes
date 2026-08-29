import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import '../../../global_widgets/custom_troggle_button.dart';
import 'package:right_routes/views/authentication/create_an_account/email_edit_widgets.dart';
import '../../../utils/assets_manager.dart';
import 'package:right_routes/controllers/auth/create_password_controller.dart';

class CreateAnAccount extends StatelessWidget {
  CreateAnAccount({super.key});

  final controller = Get.put(CreatePasswordController());
  final troggleController = Get.put(ToggleController());

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
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: _buildFormContent(context),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  children: [
                    SizedBox(height: context.h(40)),
                    Center(child: _buildLogo(context)),
                    SizedBox(height: context.h(20)),
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: context.w(15)),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: _buildFormContent(context),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildFormContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create an account to continue',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(25),
            fontFamily: 'Lato',
            fontWeight: FontWeight.bold,
            height: 1.12,
          ),
        ),
        SizedBox(height: context.h(18)),
        Text(
          'Creating an account gives you full functionality, '
          'access to your route history, account settings and subscription status.',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(18),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            height: 1.44,
          ),
        ),
        SizedBox(height: context.h(17)),
        Obx(
          () => EmailEditWidgets(
            email: controller.email.value,
            onEditTap: () {
              Get.toNamed(AppRoutes.enterEmailScreen);
            },
          ),
        ),
        SizedBox(height: context.h(32)),
        _buildPasswordField(context),
        _buildProgressBar(context),
        Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ruleTile(
                context,
                controller.isSixChars.value,
                "Use a minimum of six characters ( Case sensitive )",
              ),
              SizedBox(height: context.h(12)),
              _ruleTile(
                context,
                controller.hasNumberOrSpecial.value,
                "Use letters with at least one number or special character",
              ),
            ],
          ),
        ),
        SizedBox(height: context.h(28)),
        _buildTouchIDSwitch(context),
        SizedBox(height: context.h(28)),
        Obx(() => _buildTermsCheckbox(context)),
        SizedBox(height: context.h(12)),
        Obx(() => _buildPrivacyCheckbox(context)),
        SizedBox(height: context.h(28)),
        Obx(() => _buildContinueButton(context)),
        SizedBox(height: context.h(80)),
      ],
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

  Widget _buildProgressBar(BuildContext context) {
    return Obx(() {
      final progress = controller.strengthProgress.value;
      final color = controller.strengthColor.value;
      final label = controller.strengthLabel.value;

      return Padding(
        padding: EdgeInsets.only(
            top: context.h(7), bottom: context.h(15), right: context.w(70)),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: context.h(8),
                decoration: BoxDecoration(
                  color: AppColors.medGray,
                  borderRadius: BorderRadius.circular(context.r(10)),
                ),
                child: Stack(
                  children: [
                    AnimatedFractionallySizedBox(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(context.r(10)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: context.w(12)),
            SizedBox(
              width: context.w(60),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  color: color,
                  fontSize: context.sp(16),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w600,
                ),
                child: Text(label, textAlign: TextAlign.left),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPasswordField(BuildContext context) {
    return Obx(
      () => Container(
        width: double.infinity,
        height: context.h(57),
        decoration: ShapeDecoration(
          color: AppColors.medGray,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(context.r(10)),
          ),
        ),
        child: Row(
          children: [
            SizedBox(width: context.w(16)),
            Expanded(
              child: TextField(
                controller: controller.passwordController,
                obscureText: controller.isPasswordHidden.value,
                onChanged: (v) => controller.password.value = v,
                cursorColor: Colors.white,
                cursorWidth: 2,
                cursorHeight: 20,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(16),
                  fontFamily: 'Lato',
                ),
                decoration: InputDecoration(
                  hintText: "Create a password",
                  hintStyle: TextStyle(
                    color: const Color(0xffBFBFBF),
                    fontWeight: FontWeight.w400,
                    fontSize: context.sp(16),
                    fontFamily: 'Lato',
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: context.h(14)),
                ),
              ),
            ),
            GestureDetector(
              onTap: controller.togglePasswordVisibility,
              child: Padding(
                padding: EdgeInsets.only(right: context.w(16)),
                child: Icon(
                  controller.isPasswordHidden.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.white.withValues(alpha: 0.6),
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ruleTile(BuildContext context, bool active, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: context.w(20),
          height: context.h(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.orange : AppColors.medGray,
            border: Border.all(
              color: active ? AppColors.orange : AppColors.medGray,
              width: context.w(2),
            ),
          ),
          child: active
              ? const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 12,
                  fontWeight: FontWeight.bold,
                )
              : null,
        ),
        SizedBox(width: context.w(7)),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.sp(16),
              fontFamily: 'Lato',
              // NO context.h
              height: 1.25,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTouchIDSwitch(BuildContext context) {
    return Row(
      children: [
        CustomToggleSwitchAdvanced(
          height: context.h(24),
          width: context.w(51),
          value: controller.useTouchId,
          onChanged: (val) {
            controller.useTouchId.value = val;
          },
          activeSvgPath: 'assets/icons/Check-orange.svg',
          svgColor: AppColors.orange,
          activeColor: AppColors.orange,
          inactiveColor: Colors.white.withValues(alpha: 0.3),
        ),
        SizedBox(width: context.w(7)),
        Text(
          'Use touch ID',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(16),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCustomCheckbox(
          context,
          controller.agreeTerms.value,
          () => controller.agreeTerms.value = !controller.agreeTerms.value,
        ),
        SizedBox(width: context.w(7)),
        Expanded(
          child: Text(
            "I consent to receive emails, OTPs, push notifications, and SMS/text messages from RightRoute related to my account and use of the app. Message and data rates may apply.",
            style: TextStyle(
              color: Colors.white,
              fontSize: context.sp(14),
              fontFamily: 'Lato',
              height: 1.38,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyCheckbox(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCustomCheckbox(
            context,
            controller.agreePrivacy.value,
            () =>
                controller.agreePrivacy.value = !controller.agreePrivacy.value,
          ),
          SizedBox(width: context.w(7)),
          Expanded(
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "I have read, understand and agree to the ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.sp(14),
                      fontFamily: 'Lato',
                      height: 1.38,
                    ),
                  ),
                  TextSpan(
                    text: "Terms of Service",
                    style: TextStyle(
                      color: AppColors.purple,
                      fontSize: context.sp(14),
                      fontFamily: 'Lato',
                      height: 1.38,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = controller.viewTermsOfUse,
                  ),
                  TextSpan(
                    text: ", ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.sp(14),
                      fontFamily: 'Lato',
                      height: 1.38,
                    ),
                  ),
                  TextSpan(
                    text: "Privacy Policy",
                    style: TextStyle(
                      color: AppColors.purple,
                      fontSize: context.sp(14),
                      fontFamily: 'Lato',
                      height: 1.38,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = controller.viewPrivacyPolicy,
                  ),
                  TextSpan(
                    text: ", and ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.sp(14),
                      fontFamily: 'Lato',
                      height: 1.38,
                    ),
                  ),
                  TextSpan(
                    text: "Disclaimer",
                    style: TextStyle(
                      color: AppColors.purple,
                      fontSize: context.sp(14),
                      fontFamily: 'Lato',
                      height: 1.38,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = controller.viewDisclaimer,
                  ),
                  TextSpan(
                    text:
                        ". I understand the nature of my consent to the collection, use and/or disclosure of my personal data and the consequences of such consent.",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.sp(14),
                      fontFamily: 'Lato',
                      height: 1.38,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomCheckbox(
      BuildContext context, bool value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.w(20),
        height: context.h(20),
        margin: EdgeInsets.only(top: context.h(2)),
        decoration: BoxDecoration(
          color: value ? AppColors.orange : AppColors.medGray,
          border: Border.all(
            color: value ? AppColors.orange : Colors.transparent,
            width: context.w(2),
          ),
          borderRadius: BorderRadius.circular(context.r(3)),
        ),
        child: value
            ? SvgPicture.asset(
                "assets/icons/Check-Box-orange.svg",
                width: context.w(12),
                height: context.h(12),
              )
            : null,
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    final isEnabled = controller.isFormValid;
    return CustomButton(
      text: controller.isLoading.value ? 'LOADING...' : 'AGREE & CONTINUE',
      width: double.infinity,
      height: context.h(55),
      fontSize: 24,
      borderRadius: 10,
      isLoading: controller.isLoading.value,
      showSpinner: false,
      backgroundColor: isEnabled ? const Color(0xffF58842) : AppColors.medGray,
      onPressed: isEnabled && !controller.isLoading.value
          ? () {
              controller.createAccount();
            }
          : null,
    );
  }
}
