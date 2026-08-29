import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EnterEmailForDeleteController extends GetxController {
  final TextEditingController emailController = TextEditingController();

  RxString email = ''.obs;

  void updateEmail(String value) {
    email.value = value;
  }

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }
}
