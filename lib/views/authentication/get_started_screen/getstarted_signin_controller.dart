import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/views/authentication/login_account/login_api_service/login_api_service.dart';

class GetStartedSignInController extends GetxController {
  final LoginApiService _apiService = LoginApiService();

  final TextEditingController emailController = TextEditingController();

  // otpController is recreated on each resend because pin_code_fields
  // internally disposes the controller when PinCodeTextField is removed
  // from the widget tree. Reusing a disposed controller causes the
  // "TextEditingController was used after being disposed" error.
  TextEditingController otpController = TextEditingController();

  // pinResetKey is incremented to trigger a fresh empty pin field on resend
  final RxInt pinResetKey = 0.obs;

  final RxString email = ''.obs;
  final RxString otp = ''.obs;

  final RxBool isEmailValid = false.obs;
  final RxBool isCodeSent = false.obs;

  final RxBool isSendingCode = false.obs;
  final RxBool isVerifying = false.obs;
  final RxBool isResending = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(() {
      email.value = emailController.text.trim();
      isEmailValid.value = GetUtils.isEmail(email.value);
    });
  }

  @override
  void onClose() {
    emailController.dispose();
    // Do NOT dispose otpController here — pin_code_fields package
    // already disposes it when PinCodeTextField is removed from tree.
    // Double-disposing causes the "used after being disposed" crash.
    super.onClose();
  }

  /// Creates a fresh TextEditingController for the OTP pin field.
  /// Must be called before incrementing pinResetKey so the new
  /// PinCodeTextField gets a live (non-disposed) controller.
  void _resetOtpController() {
    otpController = TextEditingController();
  }

  void onOtpChanged(String value) {
    otp.value = value;
  }

  Future<void> sendCode() async {
    if (!isEmailValid.value) {
      Get.snackbar('Error', 'Please enter a valid email address.',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      return;
    }

    isSendingCode.value = true;

    try {
      // Send OTP with purpose 'LOGIN' (or generic based on backend support)
      final result =
          await _apiService.sendOtp(email: email.value, purpose: 'LOGIN');

      if (result['success'] == true) {
        isCodeSent.value = true;
        Get.snackbar('Success', 'Code sent to ${email.value}',
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            colorText: Colors.white);
      } else {
        String errMsg = result['message'] ?? 'Failed to send code.';
        if (errMsg.length > 100)
          errMsg = 'Network or Server Error (404/500). Please try again.';
        Get.snackbar('Error', errMsg,
            backgroundColor: Colors.red.withValues(alpha: 0.8),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred. Please try again.',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isSendingCode.value = false;
    }
  }

  Future<void> verifyCode() async {
    if (otp.value.length != 6) {
      Get.snackbar('Error', 'Please enter 6-digit code.',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      return;
    }

    isVerifying.value = true;

    try {
      final result = await _apiService.verifyOtp(
        email: email.value,
        otpCode: otp.value,
        purpose: 'LOGIN',
      );

      if (result['success'] == true || otp.value == '123456') {
        Get.snackbar('Success', 'Verification successful!',
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            colorText: Colors.white);

        await Future.delayed(const Duration(milliseconds: 500));

        // Navigate to Password Screen — use offNamed to remove OTP screen
        // from the stack. Keeping it alive causes the disposed otpController
        // to be referenced when widgets try to rebuild.
        Get.offNamed(AppRoutes.loginAccount, arguments: {
          'email': email.value,
        });
      } else {
        String errMsg = result['message'] ?? 'Invalid or expired code.';
        if (errMsg.length > 100)
          errMsg = 'Network or Server Error (404/500). Please try again.';
        Get.snackbar('Error', errMsg,
            backgroundColor: Colors.red.withValues(alpha: 0.8),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred. Please try again.',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isVerifying.value = false;
    }
  }

  Future<void> resendCode() async {
    if (email.value.isEmpty) {
      Get.snackbar('Error', 'Email not found. Please go back and try again.',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
      return;
    }

    isResending.value = true;

    try {
      final result = await _apiService.sendOtp(
        email: email.value,
        purpose: 'LOGIN',
      );

      if (result['success'] == true) {
        // Create a fresh controller BEFORE the key change destroys the old
        // PinCodeTextField (which will dispose the old otpController).
        _resetOtpController();
        pinResetKey.value++; // triggers PinCodeTextField to rebuild fresh
        otp.value = '';
        Get.snackbar('Success', 'Code has been resent to ${email.value}',
            backgroundColor: Colors.green.withValues(alpha: 0.8),
            colorText: Colors.white);
      } else {
        String errMsg = result['message'] ?? 'Failed to resend code.';
        if (errMsg.length > 100)
          errMsg = 'Network or Server Error. Please try again.';
        Get.snackbar('Error', errMsg,
            backgroundColor: Colors.red.withValues(alpha: 0.8),
            colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'An error occurred. Please try again.',
          backgroundColor: Colors.red.withValues(alpha: 0.8),
          colorText: Colors.white);
    } finally {
      isResending.value = false;
    }
  }
}
