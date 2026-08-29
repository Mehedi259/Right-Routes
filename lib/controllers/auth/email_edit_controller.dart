import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmailEditController extends GetxController {
  final editEmailController = TextEditingController();

  @override
  void onClose() {
    // Controller dispose করা important
    editEmailController.dispose();
    super.onClose();
  }
}
