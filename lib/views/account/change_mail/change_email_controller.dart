import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/constants/services/auth_service.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/views/account/change_mail/change_email_service.dart';

class ChangeEmailController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final isLoading = false.obs;
  final currentEmail = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCurrentEmail();
  }

  // 🔥 AuthService থেকে Current Email load
  Future<void> loadCurrentEmail() async {
    String? email = AuthService.getUserEmail();
    if (email != null) {
      currentEmail.value = email;
      print('📧 Current email loaded from AuthService: $email');
    } else {
      print('❌ No email found in AuthService');
    }
  }

  // 🔥 Change Email Function
  Future<void> changeEmail() async {
    // Validation
    String newEmail = emailController.text.trim();

    print('\n🔍 VALIDATION CHECK');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    if (newEmail.isEmpty) {
      print('❌ Email is empty');
      Get.snackbar(
        'Error',
        'Please enter new email',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    if (!GetUtils.isEmail(newEmail)) {
      print('❌ Email format is invalid: $newEmail');
      Get.snackbar(
        'Error',
        'Please enter a valid email',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    print('✅ Validation passed: $newEmail');
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Start loading
    isLoading.value = true;
    print('⏳ Loading started...\n');

    // 🔥 Call API (AuthService থেকে token automatically নেওয়া হবে)
    final result = await ChangeEmailService.changeEmail(newEmail);

    // Stop loading
    isLoading.value = false;
    print('⏳ Loading stopped\n');

    // Check result
    if (result['success']) {
      // ✅ Success
      print('🎉 Email change successful!');

      // Reload current email from AuthService
      await loadCurrentEmail();

      Get.snackbar(
        'Success',
        result['message'],
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 2),
      );

      // Navigate to success screen
      await Future.delayed(Duration(milliseconds: 500));
      Get.offNamed(AppRoutes.emailSaved);

    } else {
      // ❌ Error
      print('💥 Email change failed!');

      Get.snackbar(
        'Error',
        result['message'],
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 3),
      );
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
