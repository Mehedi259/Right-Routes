import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/utils/colors.dart';
import '../../../core/constants/services/auth_service.dart';
import 'package:right_routes/views/authentication/create_an_account/register_api_service.dart';
import 'package:right_routes/views/authentication/privacy_policy/privacy_policy.dart';
import 'package:right_routes/views/authentication/terms_of_service/terms_of_service.dart';
import 'package:right_routes/views/authentication/disclaimer/disclaimer.dart';

class CreatePasswordController extends GetxController {
  final RegisterApiService _apiService = Get.put(RegisterApiService());

  final TextEditingController passwordController = TextEditingController();

  final RxString email = ''.obs;
  final RxString emailToken = ''.obs;

  final RxString password = ''.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isSixChars = false.obs;
  final RxBool hasNumberOrSpecial = false.obs;
  final RxBool useTouchId = false.obs;
  final RxBool agreeTerms = false.obs;
  final RxBool agreePrivacy = false.obs;

  final RxBool isLoading = false.obs;

  final RxString strengthLabel = "".obs;
  final RxDouble strengthProgress = 0.0.obs;
  final Rx<Color> strengthColor = AppColors.medGray.obs;

  bool get isFormValid =>
      isSixChars.value &&
          hasNumberOrSpecial.value &&
          agreeTerms.value &&
          agreePrivacy.value;

  @override
  void onInit() {
    super.onInit();
    
    useTouchId.value = AuthService.getTouchIDEnabled();

    final args = Get.arguments;
    if (args != null) {
      email.value = args['email'] ?? '';
      emailToken.value = args['token'] ?? '';
    }

    if (email.value.isEmpty) {
      email.value = AuthService.getUserEmail() ?? '';
    }

    if (emailToken.value.isEmpty) {
      AuthService.getEmailToken().then((token) {
        if (token != null) emailToken.value = token;
      });
    }

    password.listen((_) {
      validatePassword();
      updatePasswordStrength();
    });
  }

  void validatePassword() {
    isSixChars.value = password.value.length >= 6;
    final hasLetter = RegExp(r'[a-zA-Z]').hasMatch(password.value);
    final hasNumberOrChar = RegExp(r'[0-9!@#\$%^&*(),.?":{}|<>]').hasMatch(password.value);
    hasNumberOrSpecial.value = hasLetter && hasNumberOrChar;
  }

  void updatePasswordStrength() {
    if (password.value.isEmpty) {
      strengthLabel.value = '';
      strengthProgress.value = 0.0;
      strengthColor.value = Color(0xFF4A4A4A);
      return;
    }

    int strength = 0;
    if (password.value.length >= 6) strength++;
    if (password.value.length >= 8) strength++;
    if (RegExp(r'[a-z]').hasMatch(password.value)) strength++;
    if (RegExp(r'[A-Z]').hasMatch(password.value)) strength++;
    if (RegExp(r'[0-9]').hasMatch(password.value)) strength++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password.value)) strength++;

    if (strength <= 2) {
      strengthLabel.value = 'Weak';
      strengthProgress.value = 0.33;
      strengthColor.value = Color(0xFFE20202);
    } else if (strength <= 4) {
      strengthLabel.value = 'Fair';
      strengthProgress.value = 0.66;
      strengthColor.value = Color(0xFFFFC700);
    } else {
      strengthLabel.value = 'Strong';
      strengthProgress.value = 1.0;
      strengthColor.value = Color(0xFF19D503);
    }
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void editEmail() {
    Get.back();
  }

  void viewTermsOfUse() {
    Get.to(() => TermsModal());
  }

  void viewPrivacyPolicy() {
    Get.to(() => PrivacyPolicy());
  }

  void viewDisclaimer() {
    Get.to(() => DisclaimerModal());
  }

  Future<void> createAccount() async {
    if (!isFormValid) {
      _showError('Please complete all requirements');
      return;
    }

    if (email.value.isEmpty) {
      _showError('Email is missing. Please restart the process.');
      return;
    }

    isLoading.value = true;

    try {
      final result = await _apiService.register(
        email: email.value,
        password: password.value,
        isTouchIdEnabled: useTouchId.value,
        termsAgreed: agreeTerms.value && agreePrivacy.value,
      );

      if (result['success'] == true) {
        final data = result['data'];
        await AuthService.saveUserEmail(email.value);

        if (useTouchId.value) {
          await AuthService.saveTouchIDEnabled(true);
          await AuthService.saveUserPassword(password.value);
        } else {
          await AuthService.saveTouchIDEnabled(false);
          await AuthService.removeUserPassword();
        }

        _showSuccess(data['detail'] ?? 'Account created successfully!');

        Get.toNamed(AppRoutes.otpVerificationScreen, arguments: {
          'email': email.value,
          'purpose': 'REGISTER',
          'nextRoute': AppRoutes.loginAccount,
        });
      } else {
        _showError(result['message'] ?? 'Registration failed');
      }
    } catch (e) {
      _showError('Connection failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  // ─── SNACKBAR HELPERS ─────────────────────────────────────
  void _showError(String msg) {
    Get.snackbar('Error', msg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2));
  }

  void _showSuccess(String msg) {
    Get.snackbar('Success', msg,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2));
  }

  @override
  void onClose() {
    passwordController.dispose();
    super.onClose();
  }
}
