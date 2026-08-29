import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import '../../global_widgets/button_reusable_short_width.dart';

class PasswordSaved extends StatelessWidget {
  const PasswordSaved({super.key});

  final String savedEmail = 'tanvirhasancr890890@gmail.com';

  // one return to back press
  void onReturnPressed(BuildContext context) {
    debugPrint('RETURN button pessed!');
  }

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
              ? _buildLandscapeLayout(context)
              : _buildPortraitLayout(context),
        ),
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PORTRAIT LAYOUT
  // ─────────────────────────────────────────────────────────────
  Widget _buildPortraitLayout(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: context.h(40)),
                  _buildLogo(context),
                  SizedBox(height: context.h(25)),
                  _buildBlueIcon(context),
                  SizedBox(height: context.h(21)),
                  _buildContent(context),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LANDSCAPE LAYOUT
  // ─────────────────────────────────────────────────────────────
  Widget _buildLandscapeLayout(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(context.s(12)),
      child: Flex(
        direction: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // LEFT — sticky logo
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.35,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(height: context.h(10)),
                _buildLogo(context),
                SizedBox(height: context.s(15)),
                _buildBlueIcon(context),
              ],
            ),
          ),
          SizedBox(width: context.w(15)),
          // RIGHT — content + button
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildContent(context),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SHARED WIDGETS
  // ─────────────────────────────────────────────────────────────

  Widget _buildLogo(BuildContext context) {
    return Center(
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
    );
  }

  Widget _buildBlueIcon(BuildContext context) {
    return Center(
      child: SizedBox(
        width: context.landscape ? context.s(50) : context.w(62),
        height: context.landscape ? context.s(50) : context.h(62),
        child: SvgPicture.asset(
          SvgManager.blueIcon,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your new Right Route password is saved',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(28),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: context.h(3)),
        Divider(color: AppColors.dividerColor, thickness: 1),
        SizedBox(height: context.h(28)),
        ButtonReusable(
          onPressed: () => Get.until((route) => route.settings.name == AppRoutes.accountScreen),
          text: 'RETURN',
          width: double.infinity,
        ),
        SizedBox(height: context.h(20)),
      ],
    );
  }
}
