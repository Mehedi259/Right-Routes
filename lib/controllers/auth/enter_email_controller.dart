import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import '../../../core/constants/services/auth_service.dart';
import 'package:right_routes/views/authentication/enter_email_screen/check_email_api_service.dart';

class EnterEmailController extends GetxController {
  final CheckEmailApiService _apiService = Get.put(CheckEmailApiService());

  var email = "".obs;
  final emailController = TextEditingController();

  final RxBool isLoading = false.obs;

  final RxString message = ''.obs;
  final RxString action = ''.obs;
  final RxBool exists = false.obs;
  final RxString emailToken = ''.obs;
  final RxString userEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    emailController.addListener(() {
      email.value = emailController.text;
    });
  }

  Future<void> checkEmail() async {
    if (emailController.text.trim().isEmpty) {
      _showError('Please enter email address');
      return;
    }

    if (!GetUtils.isEmail(emailController.text)) {
      _showError('Please enter a valid email address');
      return;
    }

    final inputEmail = emailController.text.trim();
    final savedDeviceEmail = AuthService.getDeviceUserEmail();

    // Flowchart logic: If device is registered to an email, enforce using that email
    if (savedDeviceEmail != null && savedDeviceEmail.isNotEmpty && savedDeviceEmail != inputEmail) {
      _showError('This device is registered to another email. You cannot continue.');
      return;
    }

    isLoading.value = true;

    try {
      final result = await _apiService.checkEmail(inputEmail);

      if (result['success'] == true) {
        final data = result['data'];

        message.value = data['message'] ?? 'Email verified successfully';
        action.value = data['next_step'] ?? '';
        exists.value = data['is_registered'] ?? false;
        userEmail.value = data['email'] ?? emailController.text.trim();
        emailToken.value = '';

        // Save to AuthService
        if (userEmail.value.isNotEmpty) {
          await AuthService.saveUserEmail(userEmail.value);
        }

        if (action.value == 'OTP_VERIFY') {
          Get.toNamed(AppRoutes.otpVerificationScreen, arguments: {
            'email': userEmail.value,
            'purpose': 'LOGIN',
            'nextRoute': AppRoutes.loginAccount,
          });
        } else if (action.value == 'SUBMIT_PASSWORD') {
          Get.toNamed(AppRoutes.loginAccount, arguments: {
            'email': userEmail.value,
          });
        } else if (action.value == 'CREATE_PASSWORD') {
          Get.toNamed(AppRoutes.createAccountScreen, arguments: {
            'email': userEmail.value,
          });
        } else {
          // Fallback based on exists flag if next_step is missing or unrecognized
          if (exists.value == true) {
            Get.toNamed(AppRoutes.loginAccount, arguments: {
              'email': userEmail.value,
              'token': '',
            });
          } else {
            Get.toNamed(AppRoutes.createAccountScreen, arguments: {
              'email': userEmail.value,
              'token': '',
            });
          }
        }
      } else {
        _showError(result['message'] ?? 'Something went wrong');
      }
    } catch (e) {
      _showError('Connection failed. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void _showError(String msg) {
    Get.snackbar('Error', msg,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2));
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
