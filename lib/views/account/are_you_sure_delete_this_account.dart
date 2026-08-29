import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/controllers/account/account_delete_controller.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/button_reusable_short_width.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import '../../../utils/assets_manager.dart';
import '../../global_widgets/custom_navbar.dart';
import '../../utils/colors.dart';

class AreYouSureDeleteThisAccount extends StatelessWidget {
  AreYouSureDeleteThisAccount({super.key});

  final AccountDeleteController controller =
      Get.put(AccountDeleteController());

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
    return Column(
      children: [
        SizedBox(height: context.h(40)),
        _buildLogo(context),
        SizedBox(height: context.h(39)),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: context.w(20)),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildContent(context),
            ),
          ),
        ),
      ],
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
              ],
            ),
          ),
          SizedBox(width: context.w(15)),
          // RIGHT — scrollable content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(top: context.h(10)),
                child: _buildContent(context),
              ),
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

  Widget _buildContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Are you sure?',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(28),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        Divider(color: AppColors.dividerColor, thickness: 1),
        Text(
          'Right Route - Oversized Load Navigator',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(20),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: context.h(17)),

        // First IMPORTANT block
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "IMPORTANT: ",
                style: TextStyle(
                  color: AppColors.orange,
                  fontSize: context.sp(20),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              TextSpan(
                text:
                    "You need to cancel your subscription in the App or Google Play store first before deleting the account in this app. Deleting this account does not stop your subscription billing but you will lose app login access and all of your data including Route History.\n\n",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(20),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              TextSpan(
                text:
                    "When you have canceled your subscription, the routing features of this app will inactive but you will still have access to your Route History and Settings until you delete this account. You will no longer be billed.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(20),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: context.h(18)),

        // Second IMPORTANT block
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "IMPORTANT: ",
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: context.sp(20),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              TextSpan(
                text:
                    "If you purchased a single user Yearly plan, your subscription will terminated at the end of its billing cycle. We don't offer refunds for unused months.",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(18),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: context.h(20)),

        Obx(
          () => ButtonReusable(
            onPressed: controller.isDeleting.value
                ? null
                : () => controller.deleteAccount(),
            text: controller.isDeleting.value
                ? 'DELETING...'
                : 'YES, DELETE THIS ACCOUNT',
            width: double.infinity,
          ),
        ),

        SizedBox(height: context.h(21)),

        ButtonReusable(
          onPressed: () => Get.toNamed(AppRoutes.accountScreen),
          text: "NO. I'LL KEEP IT",
          width: double.infinity,
          fontSize: context.sp(24),
          backgroundColor: AppColors.medGray,
        ),

        SizedBox(height: context.h(20)),
      ],
    );
  }
}
