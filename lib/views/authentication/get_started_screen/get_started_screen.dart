import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/responsive_ext.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = context.landscape;

    final TextStyle titleStyle = TextStyle(
      color: Colors.white,
      fontSize: context.sp(32),
      fontFamily: 'League Gothic',
      fontWeight: FontWeight.w400,
      height: 1.25,
      letterSpacing: 1,
    );

    final TextStyle bodyStyle = TextStyle(
      color: Colors.white,
      fontSize: context.sp(20),
      fontFamily: 'Lato',
      fontWeight: FontWeight.w500,
      height: 1.40,
    );

    final TextStyle subBodyStyle = TextStyle(
      color: Colors.white,
      fontSize: context.sp(18),
      fontFamily: 'Lato',
      fontWeight: FontWeight.w500,
      height: 1.44,
    );

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
              ? _buildLandscape(context, titleStyle, bodyStyle, subBodyStyle)
              : _buildPortrait(context, titleStyle, bodyStyle, subBodyStyle),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PORTRAIT — unchanged
  // ─────────────────────────────────────────────────────────────
  Widget _buildPortrait(BuildContext context, TextStyle titleStyle,
      TextStyle bodyStyle, TextStyle subBodyStyle) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: context.h(30)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: context.w(15)),
                  child: Text.rich(
                    const TextSpan(
                      text:
                          'EXPERIENCE THE EASE OF\nAUTOMATED VISUAL AND VOICE\nGUIDED PERMITTED ROUTE\nNAVIGATION',
                    ),
                    style: titleStyle,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: context.h(19)),
                Text(
                  'Start automated routing with your 7-day\nfree trial, then \$14.99/mo for\nindividuals.',
                  style: bodyStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.h(19)),
                Text(
                  'Companies: See pricing tiers\nafter sign-up.',
                  style: subBodyStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.h(24)),
                CustomButton(
                  text: "GET STARTED",
                  width: context.w(234),
                  fontSize: 24,
                  onPressed: () => Get.toNamed(AppRoutes.enterEmailScreen),
                ),
                SizedBox(height: context.h(140)),
              ],
            ),
          ),
        ),
        _buildSignIn(context),
        SizedBox(height: context.h(20)),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LANDSCAPE — logo left, content right, scalable
  // ─────────────────────────────────────────────────────────────
  Widget _buildLandscape(BuildContext context, TextStyle titleStyle,
      TextStyle bodyStyle, TextStyle subBodyStyle) {
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
              right: context.w(20),
              bottom: context.h(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text.rich(
                  const TextSpan(
                    text:
                        'EXPERIENCE THE EASE OF\nAUTOMATED VISUAL AND VOICE\nGUIDED PERMITTED ROUTE\nNAVIGATION',
                  ),
                  style: titleStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.h(14)),
                Text(
                  'Start automated routing with your 7-day free trial, then \$14.99/mo for individuals.',
                  style: bodyStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.h(12)),
                Text(
                  'Companies: See pricing tiers after sign-up.',
                  style: subBodyStyle,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.h(16)),
                CustomButton(
                  text: "GET STARTED",
                  width: context.w(234),
                  fontSize: 24,
                  onPressed: () => Get.toNamed(AppRoutes.enterEmailScreen),
                ),
                SizedBox(height: context.h(20)),
                _buildSignIn(context),
                SizedBox(height: context.h(8)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SHARED: Sign In section
  // ─────────────────────────────────────────────────────────────
  Widget _buildSignIn(BuildContext context) {
    return Column(
      children: [
        Text(
          'Already a Subscriber?',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(16),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.h(5)),
        GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.getStartedSignInScreen),
          child: Text(
            'SIGN IN',
            style: TextStyle(
              color: AppColors.purple,
              fontSize: context.sp(18),
              fontFamily: 'League Gothic',
              fontWeight: FontWeight.w400,
              letterSpacing: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}
