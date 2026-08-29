// lib/bindings/otp_verification_binding.dart
import 'package:get/get.dart';
import 'package:right_routes/controllers/auth/otp_verification_controller.dart';

class OtpVerificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtpVerificationController>(
      () => OtpVerificationController(),
      fenix: true,
    );
  }
}
