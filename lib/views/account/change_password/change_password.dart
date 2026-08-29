import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/button_reusable_short_width.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import '../../../../utils/assets_manager.dart';
import 'change_password_service.dart';

class ChangePassword extends StatelessWidget {
  ChangePassword({super.key});

  final changePassController = Get.put(ChangePasswordController());

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = context.landscape;

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Change Password',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(28),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
        Divider(color: AppColors.white, thickness: 1),
        SizedBox(height: context.h(5)),
        Text(
          'This replaces the password you use to log in to this app account.',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(18),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.h(27)),

        _buildPasswordField(context),
        _buildProgressBar(context),

        Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ruleTile(
                  context,
                  changePassController.isSixChars.value,
                  "Use a minimum of six characters (Case sensitive)",
                ),
                SizedBox(height: context.h(12)),
                _ruleTile(
                  context,
                  changePassController.hasNumberOrSpecial.value,
                  "Use letters with at least one number or special character",
                ),
              ],
            )),

        SizedBox(height: context.h(28)),

        Obx(() => ButtonReusable(
              onPressed: changePassController.isLoading.value
                  ? null
                  : () => changePassController.changePassword(),
              text: changePassController.isLoading.value
                  ? 'SAVING...'
                  : 'SAVE & CONTINUE',
              width: double.infinity,
            )),

        SizedBox(height: context.h(20)),
        ButtonReusable(
          onPressed: () => Get.back(),
          text: 'CANCEL',
          width: double.infinity,
          fontSize: context.sp(24),
          backgroundColor: AppColors.medGray,
        ),
        SizedBox(height: context.h(40)),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PASSWORD FIELD
  // ─────────────────────────────────────────────────────────────
  Widget _buildPasswordField(BuildContext context) {
    return Obx(() => Container(
          width: double.infinity,
          height: context.h(48),
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
                  controller: changePassController.changeEditing,
                  obscureText: changePassController.isPasswordHidden.value,
                  onChanged: (v) => changePassController.password.value = v,
                  cursorColor: Colors.white,
                  cursorWidth: 2,
                  cursorHeight: context.h(20),
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
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: context.h(14)),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                  ),
                ),
              ),
              GestureDetector(
                onTap: changePassController.togglePasswordVisibility,
                child: Padding(
                  padding: EdgeInsets.only(right: context.w(16)),
                  child: Icon(
                    changePassController.isPasswordHidden.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.white.withValues(alpha: 0.6),
                    size: context.s(22),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  // ─────────────────────────────────────────────────────────────
  // PROGRESS BAR
  // ─────────────────────────────────────────────────────────────
  Widget _buildProgressBar(BuildContext context) {
    return Obx(() {
      final progress = changePassController.strengthProgress.value;
      final color = changePassController.strengthColor.value;
      final label = changePassController.strengthLabel.value;

      return Padding(
        padding: EdgeInsets.only(
          top: context.h(15),
          bottom: context.h(15),
          right: context.w(70),
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: context.h(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A4A4A),
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

  // ─────────────────────────────────────────────────────────────
  // RULE TILE
  // ─────────────────────────────────────────────────────────────
  Widget _ruleTile(BuildContext context, bool active, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: context.w(20),
          height: context.h(20),
          margin: EdgeInsets.only(top: context.h(2)),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? AppColors.orange : AppColors.medGray,
            border: Border.all(
              color: active ? AppColors.orange : AppColors.medGray,
              width: context.w(2),
            ),
          ),
          child: active
              ? Icon(Icons.check, color: Colors.white, size: context.s(14))
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
            ),
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// CONTROLLER — unchanged (no screenutil here)
// =============================================================================
class ChangePasswordController extends GetxController {
  final TextEditingController changeEditing = TextEditingController();
  var password = ''.obs;
  var isPasswordValid = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isLoading = false.obs;

  var isSixChars = false.obs;
  var hasNumberOrSpecial = false.obs;

  var strengthProgress = 0.0.obs;
  var strengthColor = AppColors.medGray.obs;
  var strengthLabel = ''.obs;

  @override
  void onInit() {
    super.onInit();
    password.listen((_) {
      validatePassword();
      updateStrength();
    });
  }

  @override
  void onClose() {
    changeEditing.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void validatePassword() {
    isSixChars.value = password.value.length >= 6;
    final hasNumber = RegExp(r'\d').hasMatch(password.value);
    final hasSpecial =
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password.value);
    hasNumberOrSpecial.value = hasNumber || hasSpecial;
    isPasswordValid.value = isSixChars.value && hasNumberOrSpecial.value;
  }

  void updateStrength() {
    final len = password.value.length;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password.value);
    final hasLower = RegExp(r'[a-z]').hasMatch(password.value);
    final hasNumber = RegExp(r'\d').hasMatch(password.value);
    final hasSpecial =
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password.value);

    int strength = 0;
    if (len >= 6) strength++;
    if (len >= 10) strength++;
    if (hasUpper && hasLower) strength++;
    if (hasNumber) strength++;
    if (hasSpecial) strength++;

    if (strength <= 1) {
      strengthProgress.value = 0.3;
      strengthColor.value = Colors.red;
      strengthLabel.value = 'Weak';
    } else if (strength == 2 || strength == 3) {
      strengthProgress.value = 0.6;
      strengthColor.value = Colors.yellow;
      strengthLabel.value = 'Fair';
    } else if (strength >= 4) {
      strengthProgress.value = 1.0;
      strengthColor.value = Colors.green;
      strengthLabel.value = 'Strong';
    }

    if (len == 0) {
      strengthProgress.value = 0.0;
      strengthColor.value = AppColors.medGray;
      strengthLabel.value = '';
    }
  }

  Future<void> changePassword() async {
    String newPassword = password.value.trim();

    if (newPassword.isEmpty) {
      Get.snackbar('Error', 'Please enter a password',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      return;
    }

    if (!isPasswordValid.value) {
      Get.snackbar('Error', 'Password must meet all requirements',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
      return;
    }

    isLoading.value = true;
    final result = await ChangePasswordService.changePassword(newPassword);
    isLoading.value = false;

    if (result['success']) {
      Get.snackbar('Success', result['message'],
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2));
      await Future.delayed(const Duration(milliseconds: 500));
      Get.offNamed(AppRoutes.passwordSaved);
    } else {
      Get.snackbar('Error', result['message'],
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3));
    }
  }
}
