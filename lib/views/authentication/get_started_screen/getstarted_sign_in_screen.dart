import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:right_routes/views/authentication/get_started_screen/getstarted_signin_controller.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';

/// ═══════════════════════════════════════════════════════════
/// GetStartedSignInScreen — StatefulWidget
/// Using StatefulWidget to keep PinCodeTextField stable
/// across orientation changes (prevents TextEditingController
/// disposed error from pin_code_fields package).
/// ═══════════════════════════════════════════════════════════
class GetStartedSignInScreen extends StatefulWidget {
  const GetStartedSignInScreen({super.key});

  @override
  State<GetStartedSignInScreen> createState() => _GetStartedSignInScreenState();
}

class _GetStartedSignInScreenState extends State<GetStartedSignInScreen> {
  late GetStartedSignInController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(GetStartedSignInController());
  }

  @override
  Widget build(BuildContext context) {
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
          child: Builder(
            builder: (context) {
              final isLandscape = context.landscape;
              return isLandscape
                  ? _buildLandscape(context)
                  : _buildPortrait(context);
            },
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PORTRAIT
  // ─────────────────────────────────────────────────────────────
  Widget _buildPortrait(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: context.h(20)),
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
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: context.w(15)),
            child: _buildContent(context),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LANDSCAPE
  // ─────────────────────────────────────────────────────────────
  Widget _buildLandscape(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── LEFT: Logo ──
        Container(
          width: MediaQuery.of(context).size.width * 0.32,
          alignment: Alignment.center,
          padding: EdgeInsets.all(context.s(16)),
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

        // ── RIGHT: Content ──
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              top: context.h(16),
              left: context.w(20),
              right: context.w(20),
              bottom: context.h(16),
            ),
            child: _buildContent(context),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SHARED CONTENT (PinCodeTextField stays in one place)
  // ─────────────────────────────────────────────────────────────
  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: context.h(20)),

        /// TITLE
        Text(
          "Check your email inbox",
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(25),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            height: 1.12,
          ),
        ),

        SizedBox(height: context.h(21)),

        /// SUBTITLE
        Text(
          "We need you to verify your email address.\nEnter an email to send a 6-digit code to:",
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(18),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            height: 1.44,
          ),
        ),

        SizedBox(height: context.h(15)),

        /// EMAIL INPUT FIELD
        Container(
          height: context.h(50),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.r(5)),
          ),
          child: TextField(
            controller: controller.emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(
                  horizontal: context.w(15), vertical: context.h(15)),
              border: InputBorder.none,
              hintText: 'Email',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontSize: context.sp(16),
              ),
            ),
            style: TextStyle(
              color: Colors.black,
              fontSize: context.sp(18),
            ),
          ),
        ),

        SizedBox(height: context.h(15)),

        /// SEND CODE BUTTON
        Obx(
          () => CustomButton(
            text: controller.isSendingCode.value ? 'SENDING...' : 'SEND CODE',
            width: context.w(120),
            height: context.h(40),
            backgroundColor: controller.isEmailValid.value
                ? AppColors.orange
                : AppColors.medGray,
            fontSize: 16,
            onPressed:
                controller.isEmailValid.value && !controller.isSendingCode.value
                    ? () {
                        controller.sendCode();
                      }
                    : null,
            showSpinner: false,
          ),
        ),

        SizedBox(height: context.h(25)),

        /// INSTRUCTIONS FOR CODE
        Text(
          "The code expires in 4 minutes. Please enter code below.",
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(18),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            height: 1.44,
          ),
        ),

        SizedBox(height: context.h(20)),

        /// PIN CODE FIELD — Obx+ValueKey so orientation rebuilds don't dispose controllers
        Obx(() => Builder(
              key: ValueKey('pin_${controller.pinResetKey.value}'),
              builder: (ctx) {
                final isLandscape = ctx.landscape;
                final screenW = MediaQuery.of(ctx).size.width;
                final availableW = isLandscape
                    ? (screenW * 0.68) - 40
                    : screenW - 30;
                final boxW = ((availableW / 6) - 4).clamp(40.0, 59.0);
                final boxH = boxW.clamp(40.0, 59.0);

                return PinCodeTextField(
                  length: 6,
                  appContext: ctx,
                  controller: controller.otpController,
                  animationType: AnimationType.fade,
                  keyboardType: TextInputType.number,
                  obscureText: false,
                  cursorColor: Colors.black,
                  textStyle: TextStyle(
                    color: Colors.black,
                    fontSize: context.sp(20),
                    fontWeight: FontWeight.bold,
                  ),
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    fieldHeight: boxH,
                    fieldWidth: boxW,
                    inactiveColor: Colors.transparent,
                    selectedColor: AppColors.orange,
                    activeColor: Colors.white,
                    inactiveFillColor: AppColors.medGray,
                    activeFillColor: Colors.white.withValues(alpha: 0.85),
                    selectedFillColor: Colors.white,
                  ),
                  enableActiveFill: true,
                  onChanged: controller.onOtpChanged,
                  onCompleted: (value) {
                    controller.verifyCode();
                  },
                );
              },
            )),

        SizedBox(height: context.h(18)),

        /// CONTINUE BUTTON
        Obx(
          () {
            bool isActive = controller.otp.value.length == 6;
            return CustomButton(
              text: controller.isVerifying.value ? 'LOADING...' : 'CONTINUE',
              backgroundColor: isActive ? AppColors.orange : AppColors.medGray,
              onPressed: isActive && !controller.isVerifying.value
                  ? () {
                      controller.verifyCode();
                    }
                  : null,
              isLoading: controller.isVerifying.value,
              showSpinner: false,
              height: context.h(58),
            );
          },
        ),

        SizedBox(height: context.h(29)),

        /// CANCEL BUTTON
        CustomButton(
          text: 'CANCEL',
          backgroundColor: AppColors.medGray,
          onPressed: () {
            Get.back();
          },
          height: context.h(55),
        ),

        SizedBox(height: context.h(50)),

        /// RESEND OTP
        Obx(
          () => RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Didn't receive the email? Check your spam folder or ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.sp(15),
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w500,
                    height: 1.38,
                  ),
                ),
                TextSpan(
                  text: controller.isResending.value ? "Sending..." : "resend",
                  style: TextStyle(
                    color: controller.isResending.value
                        ? AppColors.purple.withValues(alpha: 0.5)
                        : AppColors.purple,
                    fontSize: context.sp(16),
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w500,
                    height: 1.38,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = controller.isResending.value
                        ? null
                        : () {
                            controller.resendCode();
                          },
                ),
              ],
            ),
          ),
        ),

        SizedBox(height: context.h(40)),
      ],
    );
  }
}
