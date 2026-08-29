import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import '../../../core/constants/services/auth_service.dart';
import '../../../utils/assets_manager.dart';
import 'logout_api_service.dart';

// -----------------------------------------------------------------------------
// CONTROLLER (GetX)
// -----------------------------------------------------------------------------
class SingleSubscriberManageAccountController extends GetxController {
  RxBool showPassword = false.obs;
  RxString userEmail = "".obs;
  RxString userPassword = "".obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    userEmail.value = AuthService.getUserEmail() ?? "";
    userPassword.value = await AuthService.getUserPassword() ?? "";
  }

  void togglePassword() {
    showPassword.value = !showPassword.value;
  }
}

// -----------------------------------------------------------------------------
// COLOR PALETTE
// -----------------------------------------------------------------------------
class RRColors {
  static const Color bgDarkBlue = Color(0xFF020B2E);
  static const Color accentOrange = Color(0xFFFF7A29);
  static const Color white = Colors.white;
}

// -----------------------------------------------------------------------------
// REUSABLE WIDGETS
// -----------------------------------------------------------------------------
class RRRightArrowTile extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  final FontWeight fontWeight;

  const RRRightArrowTile({
    super.key,
    required this.title,
    this.onTap,
    this.fontWeight = FontWeight.w700,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.h(5)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(19),
                  fontFamily: 'Lato',
                  fontWeight: fontWeight,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios,
                color: RRColors.white, size: context.sp(26)),
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// MAIN SCREEN
// -----------------------------------------------------------------------------
class SingleSubscriberScreen extends StatelessWidget {
  SingleSubscriberScreen({super.key});

  final c = Get.put(SingleSubscriberManageAccountController());

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
        SizedBox(height: context.h(20)),
        _buildLogo(context),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: context.w(20)),
            child: _buildScrollContent(context),
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
              child: _buildScrollContent(context),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SHARED SCROLL CONTENT
  // ─────────────────────────────────────────────────────────────
  Widget _buildScrollContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: context.h(20)),
        _buildSectionTitle(context, "Manage Account"),
        _buildDivider(),
        _buildEmailSection(context),
        SizedBox(height: context.h(6)),
        _buildPasswordSection(context),
        SizedBox(height: context.h(4)),
        _buildRouteHistory(context),
        SizedBox(height: context.h(1)),
        _buildDivider(),
        _buildCurrentPlan(context),
        _buildDivider(),
        _buildCustomerCare(context),
        _buildDivider(),
        _buildLegalSection(context),
        _buildDivider(),
        SizedBox(height: context.h(12)),
        _buildVersion(context),
        SizedBox(height: context.h(12)),
        _buildDivider(),
        _buildLogoutSection(context),
        SizedBox(height: context.h(18)),
        _buildExitButton(context),
        SizedBox(height: context.h(60)),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // WIDGETS
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

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.white,
        fontSize: context.sp(28),
        fontFamily: 'Lato',
        fontWeight: FontWeight.w700,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(color: AppColors.white, thickness: 1);
  }

  Widget _buildEmailSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Email",
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(18),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
          ),
        ),
        Obx(() => RRRightArrowTile(
          title: c.userEmail.value.isNotEmpty ? c.userEmail.value : "No Email",
          onTap: () => Get.toNamed(AppRoutes.changeEmail),
        )),
      ],
    );
  }

  Widget _buildPasswordSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              "Password",
              style: TextStyle(
                color: Colors.white,
                fontSize: context.sp(18),
                fontFamily: 'Lato',
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: context.w(7)),
            Obx(() => GestureDetector(
                  onTap: c.togglePassword,
                  child: SvgPicture.asset(
                    c.showPassword.value
                        ? SvgManager.eyeSlashBigPupil
                        : SvgManager.eyeBigPupil,
                    width: context.w(24),
                    height: context.h(24),
                    colorFilter: const ColorFilter.mode(
                      AppColors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                )),
          ],
        ),
        SizedBox(height: context.h(1)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => Padding(
                  padding: EdgeInsets.symmetric(vertical: context.h(5)),
                  child: Text(
                    c.showPassword.value ? (c.userPassword.value.isNotEmpty ? c.userPassword.value : "No Password") : "**********",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.sp(18),
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )),
            Expanded(
              child: RRRightArrowTile(
                title: "",
                onTap: () => Get.toNamed(AppRoutes.changePassword),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteHistory(BuildContext context) {
    return RRRightArrowTile(
      title: "My Route History",
      fontWeight: FontWeight.w500,
      onTap: () => Get.toNamed(AppRoutes.historyScreen),
    );
  }

  Widget _buildCurrentPlan(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: context.h(8)),
        Text(
          "CURRENT PLAN",
          style: TextStyle(
            color: AppColors.orange,
            fontSize: context.sp(24),
            fontFamily: 'League Gothic',
            fontWeight: FontWeight.w400,
            letterSpacing: 1.50,
          ),
        ),
        SizedBox(height: context.h(10)),
        Text(
          "sub.monthly",
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(18),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.h(10)),
        Text(
          "Renewal Date: 07/03/2026",
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(18),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.h(4)),
        RRRightArrowTile(
          title: "Change Plan",
          fontWeight: FontWeight.w500,
          onTap: () => Get.toNamed(AppRoutes.chooseYourPlan),
        ),
      ],
    );
  }

  Widget _buildCustomerCare(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: context.h(10)),
        Text(
          "CUSTOMER CARE",
          style: TextStyle(
            color: AppColors.orange,
            fontSize: context.sp(24),
            fontFamily: 'League Gothic',
            fontWeight: FontWeight.w400,
            letterSpacing: 1.50,
          ),
        ),
        SizedBox(height: context.h(10)),
        RRRightArrowTile(
          title: "Contact Support",
          fontWeight: FontWeight.w500,
          onTap: () => Get.toNamed(AppRoutes.contactSupport),
        ),
      ],
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: context.h(17)),
        Text(
          "LEGAL",
          style: TextStyle(
            color: const Color(0xFFF58842),
            fontSize: context.sp(24),
            fontFamily: 'League Gothic',
            fontWeight: FontWeight.w400,
            letterSpacing: 1.50,
          ),
        ),
        SizedBox(height: context.h(10)),
        RRRightArrowTile(
          title: "Privacy Policy",
          fontWeight: FontWeight.w500,
          onTap: () => Get.toNamed(AppRoutes.privacyPolicy),
        ),
        RRRightArrowTile(
          title: "Terms of Use",
          fontWeight: FontWeight.w500,
          onTap: () => Get.toNamed(AppRoutes.termsModal),
        ),
        RRRightArrowTile(
          title: "Disclaimer",
          fontWeight: FontWeight.w500,
          onTap: () => Get.toNamed(AppRoutes.disclaimer),
        ),
      ],
    );
  }

  Widget _buildVersion(BuildContext context) {
    return Text(
      "Version 1.00.0",
      style: TextStyle(
        color: AppColors.orange,
        fontSize: context.sp(18),
        fontFamily: 'Lato',
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RRRightArrowTile(
          title: "Logout",
          fontWeight: FontWeight.w500,
          onTap: () {
            Get.dialog(
              Dialog(
                backgroundColor: Colors.transparent,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFB71C1C),
                    borderRadius: BorderRadius.circular(context.r(4)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: context.w(12),
                          vertical: context.h(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.notifications,
                                color: Colors.white, size: context.s(20)),
                            const Spacer(),
                            TextButton(
                              onPressed: () => Get.back(),
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                  horizontal: context.w(12),
                                  vertical: context.h(4),
                                ),
                                minimumSize: Size.zero,
                              ),
                              child: Text(
                                'CANCEL',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: context.sp(12),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.fromLTRB(
                          context.w(16),
                          context.h(8),
                          context.w(16),
                          context.h(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'NOTE: ',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.sp(14),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  TextSpan(
                                    text: 'Are you sure you want to logout?',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: context.sp(14),
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: context.h(16)),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () async {
                                  Get.back();
                                  await LogoutApiService.logout();
                                  await AuthService.logout();
                                  Get.offAllNamed(AppRoutes.enterEmailScreen);
                                  Get.snackbar(
                                    'Logged Out',
                                    'You have been logged out successfully',
                                    backgroundColor: Colors.green,
                                    colorText: Colors.white,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFFB71C1C),
                                  padding: EdgeInsets.symmetric(
                                      vertical: context.h(12)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(context.r(4)),
                                  ),
                                ),
                                child: Text(
                                  'LOGOUT',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: context.sp(14),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        RRRightArrowTile(
          title: "Delete Account",
          fontWeight: FontWeight.w500,
          onTap: () => Get.toNamed(AppRoutes.areYouSureDeleteThisAccount),
        ),
      ],
    );
  }

  Widget _buildExitButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => Get.toNamed(AppRoutes.homeScreen),
        child: Container(
          width: double.infinity,
          height: context.h(58),
          decoration: BoxDecoration(
            color: AppColors.orange,
            borderRadius: BorderRadius.circular(context.r(10)),
          ),
          alignment: Alignment.center,
          child: Text(
            'EXIT',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.sp(24),
              fontFamily: 'League Gothic',
              fontWeight: FontWeight.w400,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}
