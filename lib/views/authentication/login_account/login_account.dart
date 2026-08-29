import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/views/authentication/enter_email_screen/enter_email_screen.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import '../../../global_widgets/custom_buttons.dart';
import '../../../global_widgets/custom_troggle_button.dart';
import '../../../utils/assets_manager.dart';
import 'package:get/get.dart';
import 'package:right_routes/controllers/auth/login_controller.dart';
import 'package:right_routes/controllers/auth/enter_email_controller.dart';

/// ═══════════════════════════════════════════════════════════
/// LoginAccount - Screen with Updated Controller Integration
/// Using StatefulWidget to properly manage LoginController
/// lifecycle and prevent TextEditingController disposal issues.
/// ═══════════════════════════════════════════════════════════
class LoginAccount extends StatefulWidget {
  const LoginAccount({super.key});

  @override
  State<LoginAccount> createState() => _LoginAccountState();
}

class _LoginAccountState extends State<LoginAccount> {
  late LoginController controller;
  late ToggleController loginTroggleController;

  @override
  void initState() {
    super.initState();
    // Delete any stale controller that may have a disposed passwordController,
    // then create a fresh one. This prevents "used after being disposed" errors
    // when navigating to this screen after OTP verification.
    Get.delete<LoginController>(force: true);
    controller = Get.put(LoginController());
    loginTroggleController = Get.put(ToggleController());
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
              final bool isLandscape = context.landscape;
              return Padding(
                padding: isLandscape
                    ? EdgeInsets.all(context.s(12))
                    : EdgeInsets.only(
                        top: context.h(20),
                        left: context.w(20),
                        right: context.w(20),
                        bottom: context.w(20),
                      ),
                child: isLandscape
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: _buildHeader(context, isLandscape),
                            ),
                          ),
                          SizedBox(width: context.w(15)),
                          Expanded(
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: _buildForm(context, isLandscape),
                            ),
                          ),
                        ],
                      )
                    : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeader(context, isLandscape),
                            SizedBox(height: context.h(14)),
                            _buildForm(context, isLandscape),
                          ],
                        ),
                      ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isLandscape) {
    return Column(
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
        SizedBox(height: isLandscape ? context.s(10) : context.h(21)),
        Text(
          'Good News you already have a Right Route account',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(25),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            height: 1.12,
          ),
        ),
        SizedBox(height: isLandscape ? context.s(12) : context.h(17)),
        Obx(() {
          final String email = controller.userEmail.value.trim();
          final String displayEmail = email.isEmpty ? 'Your email...' : email;

          return RichText(
            text: TextSpan(
              text:
                  'Since you\'ve already used your email to sign up for this service, you can now log in using ',
              style: TextStyle(
                color: Colors.white,
                fontSize: context.sp(18),
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
                height: 1.44,
              ),
              children: [
                TextSpan(
                  text: '$displayEmail ',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: context.sp(18),
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                    height: 1.44,
                  ),
                ),
                TextSpan(
                  text: 'edit.',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontSize: context.sp(18),
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                    height: 1.44,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Get.toNamed(AppRoutes.enterEmailScreen);
                    },
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _buildForm(BuildContext context, bool isLandscape) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLandscape) SizedBox(height: context.s(20)),
        Text(
          'Enter your current password to log in.',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(18),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
            height: 1.56,
          ),
        ),
        SizedBox(height: context.h(9)),

        /// PASSWORD FIELD
        Container(
          height: context.h(57),
          padding: EdgeInsets.symmetric(horizontal: context.w(14)),
          decoration: BoxDecoration(
            color: AppColors.medGray,
            borderRadius: BorderRadius.circular(context.r(10)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Obx(
                  () => TextField(
                    controller: controller.passwordController,
                    obscureText: controller.hidePassword.value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.sp(16),
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400,
                      height: 1.4,
                      letterSpacing: 0.2,
                    ),
                    onSubmitted: (_) {
                      if (!controller.isLoading.value) {
                        controller.login();
                      }
                    },
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'password',
                      hintStyle: TextStyle(
                        color: const Color(0xFFBFBFBF),
                        fontSize: context.sp(16),
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w400,
                      ),
                      isDense: true,
                      contentPadding:
                          EdgeInsets.symmetric(vertical: context.h(14)),
                    ),
                  ),
                ),
              ),
              Obx(
                () => IconButton(
                  icon: Icon(
                    controller.hidePassword.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.white54,
                    size: context.sp(24),
                  ),
                  onPressed: () => controller.togglePassword(),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: context.h(24)),

        /// LOGIN BUTTON + FINGERPRINT
        Row(
          children: [
            Expanded(
              child: Obx(
                () => CustomButton(
                  text: controller.isLoading.value ? 'LOADING...' : 'LOG IN',
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          controller.login();
                        },
                  isLoading: controller.isLoading.value,
                  showSpinner: false,
                  backgroundColor: controller.passwordText.value.isEmpty
                      ? AppColors.medGray
                      : AppColors.orange,
                  height: context.h(58),
                ),
              ),
            ),
            SizedBox(width: context.w(10)),
            Obx(
              () => GestureDetector(
                onTap: controller.isLoading.value
                    ? null
                    : () async {
                        print('\n👆 Fingerprint button pressed!');
                        await controller.authenticateWithBiometrics();
                      },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 150),
                  height: context.h(53),
                  width: context.w(55),
                  decoration: BoxDecoration(
                    color: controller.isLoading.value
                        ? AppColors.orange.withValues(alpha: 0.5)
                        : AppColors.orange,
                    borderRadius: BorderRadius.circular(context.r(50)),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.fingerprint,
                      color: AppColors.white,
                      size: context.r(45),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: context.h(15)),

        /// TOUCH ID SWITCH
        Row(
          children: [
            CustomToggleSwitchAdvanced(
              height: context.h(24),
              width: context.w(51),
              value: controller.isTouchIDEnabled,
              onChanged: (val) {
                controller.toggleTouchID(val);
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
        ),

        SizedBox(height: context.h(45)),

        /// TROUBLE LOGGING IN - OTP SEND
        Obx(
          () => GestureDetector(
            onTap: controller.isSendingOtp.value || controller.isLoading.value
                ? null
                : () async {
                    await controller.sendOtpAndNavigate();
                  },
            child: controller.isSendingOtp.value
                ? Row(
                    children: [
                      SizedBox(
                        width: context.w(16),
                        height: context.h(16),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF9DACF5),
                          ),
                        ),
                      ),
                      SizedBox(width: context.w(10)),
                      Text(
                        'Sending OTP...',
                        style: TextStyle(
                          color: const Color(0xFF9DACF5),
                          fontSize: context.sp(16),
                          fontFamily: 'Lato',
                          fontWeight: FontWeight.w500,
                          height: 1.38,
                        ),
                      ),
                    ],
                  )
                : Text(
                    'Having trouble logging in? Get a one time code.',
                    style: TextStyle(
                      color: const Color(0xFF9DACF5),
                      fontSize: context.sp(16),
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w500,
                      height: 1.38,
                    ),
                    textAlign: TextAlign.start,
                  ),
          ),
        ),

        SizedBox(height: context.h(20)),
      ],
    );
  }
}
