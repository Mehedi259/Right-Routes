import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/button_reusable_short_width.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import '../../../global_widgets/custom_navbar.dart';
import '../../../utils/assets_manager.dart';
import '../../../utils/colors.dart';
import 'package:right_routes/views/account/change_mail/change_email_controller.dart';

class ChangeEmail extends StatelessWidget {
  ChangeEmail({super.key});

  final emailController = Get.put(ChangeEmailController());

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
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.w(20)),
        child: Column(
          children: [
            SizedBox(height: context.h(20)),
            _buildLogo(context),
            SizedBox(height: context.h(20)),
            _buildFormContent(context),
          ],
        ),
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
              ],
            ),
          ),
          SizedBox(width: context.w(15)),
          // RIGHT — scrollable form
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: _buildFormContent(context),
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

  Widget _buildFormContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Change Email',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(28),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        SizedBox(height: context.h(5)),
        Divider(color: AppColors.dividerColor, thickness: 1),

        Text(
          'This replaces the email you use to log in to this app account.',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(18),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.h(15)),

        Text(
          'Current Right Route account email:',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(20),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
          ),
        ),

        Obx(() => Text(
              emailController.currentEmail.value.isEmpty
                  ? 'Loading...'
                  : emailController.currentEmail.value,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.sp(20),
                fontFamily: 'Lato',
                fontWeight: FontWeight.w800,
              ),
            )),

        SizedBox(height: context.h(30)),

        Center(child: _emailInputField(context, emailController)),
        SizedBox(height: context.h(20)),

        Obx(() => ButtonReusable(
              onPressed: emailController.isLoading.value
                  ? null
                  : () => emailController.changeEmail(),
              text: emailController.isLoading.value
                  ? 'SAVING...'
                  : 'SAVE & CONTINUE',
              width: double.infinity,
            )),

        SizedBox(height: context.h(20)),
        ButtonReusable(
          onPressed: () => Get.toNamed(AppRoutes.accountScreen),
          text: 'CANCEL',
          width: double.infinity,
          fontSize: context.sp(24),
          backgroundColor: AppColors.medGray,
        ),
        SizedBox(height: context.h(40)),
      ],
    );
  }

  Widget _emailInputField(
      BuildContext context, ChangeEmailController controller) {
    return Container(
      height: context.h(57),
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: context.w(16)),
      decoration: BoxDecoration(
        color: AppColors.medGray,
        borderRadius: BorderRadius.circular(context.r(10)),
      ),
      child: Center(
        child: TextFormField(
          controller: controller.emailController,
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(16),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w400,
          ),
          cursorColor: Colors.white,
          cursorHeight: context.h(20),
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            focusedErrorBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: "Enter new email",
            hintStyle: TextStyle(
              color: const Color(0xFFBFBFBF),
              fontSize: context.sp(16),
              fontFamily: 'Lato',
              fontWeight: FontWeight.w400,
            ),
            isDense: true,
          ),
        ),
      ),
    );
  }
}
