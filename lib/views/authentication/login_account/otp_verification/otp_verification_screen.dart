import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import '../../../../utils/assets_manager.dart';
import '../../../../utils/colors.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/controllers/auth/otp_verification_controller.dart';
import 'package:right_routes/utils/responsive_ext.dart';

/// ═══════════════════════════════════════════════════════════
/// OtpVerificationScreen — StatefulWidget
/// Using StatefulWidget to keep PinCodeTextField stable
/// across orientation changes (prevents TextEditingController
/// disposed error from pin_code_fields package).
/// ═══════════════════════════════════════════════════════════
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  late OtpVerificationController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<OtpVerificationController>();
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
        SizedBox(height: context.h(40)),
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
        SizedBox(height: context.h(21)),

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

        /// SUBTITLE WITH EMAIL
        Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text:
                    "We'll need you to verify your email address. We've sent a 6-digit code to ",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(18),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: controller.email,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(18),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.bold,
                  height: 1.44,
                ),
              ),
              TextSpan(
                text: ' The code expires in 15 minutes. Please enter it below.',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(18),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                  height: 1.44,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: context.h(28)),

        /// PIN CODE FIELD
        Builder(
          builder: (ctx) {
            final orientation = MediaQuery.of(ctx).orientation;
            final screenW = MediaQuery.of(ctx).size.width;
            final availableW = orientation == Orientation.landscape
                ? (screenW * 0.68) - 40
                : screenW - 30;
            final boxW = ((availableW / 6) - 4).clamp(40.0, 59.0);
            final boxH = boxW.clamp(40.0, 59.0);

            return PinCodeTextField(
              length: 6,
              appContext: ctx,
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
                // Auto verify when 6 digits entered
                controller.verifyOtp();
              },
            );
          },
        ),

        SizedBox(height: context.h(18)),

        /// CONTINUE BUTTON
        Obx(
          () => CustomButton(
            text: controller.isVerifying.value ? 'LOADING...' : 'CONTINUE',
            onPressed: controller.isVerifying.value
                ? null
                : () {
                    // ✅ Call verify OTP API
                    controller.verifyOtp();
                  },
            isLoading: controller.isVerifying.value,
            showSpinner: false,
            backgroundColor: controller.otp.value.length == 6
                ? AppColors.orange
                : AppColors.medGray,
            height: context.h(58),
          ),
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

        SizedBox(height: context.h(53)),

        /// RESEND OTP
        Obx(
          () => RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "Didn't receive the mail? Check your spam folder or ",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.sp(15),
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w500,
                    height: 1.38,
                  ),
                ),
                TextSpan(
                  text: controller.isResending.value ? "Sending..." : "Resend",
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
                            controller.resendOtp();
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
