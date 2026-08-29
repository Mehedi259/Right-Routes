import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import '../../../../core/constants/services/auth_service.dart';
import 'package:right_routes/views/authentication/login_account/login_api_service/login_api_service.dart';

import 'package:right_routes/views/authentication/login_account/send_otp_service/Trouble_Login_Otp_service.dart';

class OtpVerificationController extends GetxController {
  final LoginApiService _apiService = LoginApiService();
  final TroubleLoginOtpService _troubleLoginService = TroubleLoginOtpService();

  final RxString otp = ''.obs;
  final RxBool isVerifying = false.obs;
  final RxBool isResending = false.obs;

  String email = '';
  String nextRoute = AppRoutes.individualTeam;
  String purpose = 'REGISTER';

  @override
  void onInit() {
    super.onInit();
    _parseArguments();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void _parseArguments() {
    final args = Get.arguments;
    if (args != null) {
      if (args is String) {
        email = args;
      } else if (args is Map) {
        email = args['email']?.toString() ?? '';
        nextRoute = args['nextRoute']?.toString() ?? AppRoutes.individualTeam;
        purpose = args['purpose']?.toString() ?? 'REGISTER';
      }
    }
    if (email.isEmpty) {
      email = AuthService.getUserEmail() ?? '';
    }
    print('[OTP-CTRL] Initialized | email: $email | nextRoute: $nextRoute | purpose: $purpose');
  }

  void onOtpChanged(String value) {
    otp.value = value;
  }

  // ─── VERIFY OTP ───────────────────────────────────────────
  Future<void> verifyOtp() async {
    if (otp.value.length != 6) {
      _showError('Please enter 6-digit OTP');
      return;
    }

    if (email.isEmpty) {
      _showError('Email not found. Please restart the process.');
      return;
    }

    isVerifying.value = true;

    try {
      Map<String, dynamic> result;
      if (purpose == 'TROUBLE_LOGIN') {
        result = await _troubleLoginService.verifyOtp(
          email: email,
          otp: otp.value,
        );
      } else {
        result = await _apiService.verifyOtp(
          email: email, 
          otpCode: otp.value,
          purpose: purpose,
        );
      }

      if (result['success'] == true) {
        final rawData = result['data'];
        final data = rawData['data'] ?? rawData;
        final nextStep = data['next_step']?.toString();

        _showSuccess('Verification successful!');
        await Future.delayed(const Duration(milliseconds: 800));

        // Robust token extraction
        var accessToken = data['access'] ?? data['access_token'] ?? data['token'];
        if (accessToken == null && data['tokens'] != null) {
          accessToken = data['tokens']['access'] ?? data['tokens']['access_token'] ?? data['tokens']['token'];
        }
        if (accessToken == null) {
          accessToken = rawData['access'] ?? rawData['access_token'] ?? rawData['token'];
        }
        if (accessToken == null && rawData['tokens'] != null) {
          accessToken = rawData['tokens']['access'] ?? rawData['tokens']['access_token'] ?? rawData['tokens']['token'];
        }
        
        var refreshToken = data['refresh'] ?? data['refresh_token'];
        if (refreshToken == null && data['tokens'] != null) {
          refreshToken = data['tokens']['refresh'] ?? data['tokens']['refresh_token'];
        }
        if (refreshToken == null) {
          refreshToken = rawData['refresh'] ?? rawData['refresh_token'];
        }
        if (refreshToken == null && rawData['tokens'] != null) {
          refreshToken = rawData['tokens']['refresh'] ?? rawData['tokens']['refresh_token'];
        }

        // Check if API returned tokens
        if (accessToken != null) {
          await AuthService.saveAccessToken(accessToken);
          if (refreshToken != null) {
            await AuthService.saveRefreshToken(refreshToken);
          }

          if (data['user'] != null) {
            final user = data['user'];
            if (user['email'] != null) await AuthService.saveUserEmail(user['email']);
            if (user['name'] != null) await AuthService.saveUserName(user['name']);
            if (user['id'] != null) await AuthService.saveUserId(user['id'].toString());
          }

          await AuthService.saveLoginStatus(true);
          
          if (nextRoute == AppRoutes.weLoggedYou || purpose == 'LOGIN') {
            Get.offAllNamed(AppRoutes.weLoggedYou);
          } else {
            Get.offAllNamed(nextRoute);
          }
        } else {
          // Navigate based on next_step from the backend (Login Flow)
          if (nextStep == 'SUBMIT_PASSWORD') {
            Get.offAllNamed(AppRoutes.loginAccount, arguments: {'email': email});
          } else if (nextStep == 'CREATE_PASSWORD') {
            Get.offAllNamed(AppRoutes.createAccountScreen, arguments: {'email': email});
          } else if (nextRoute == AppRoutes.loginAccount) {
            Get.offAllNamed(nextRoute, arguments: {'email': email});
          } else {
            Get.offAllNamed(nextRoute);
          }
        }
      } else {
        _showError(result['message'] ?? 'Invalid OTP. Please try again.');
      }
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      isVerifying.value = false;
    }
  }

  // ─── RESEND OTP ───────────────────────────────────────────
  Future<void> resendOtp() async {
    if (email.isEmpty) {
      _showError('Email not found');
      return;
    }

    isResending.value = true;

    try {
      Map<String, dynamic> result;
      if (purpose == 'TROUBLE_LOGIN') {
        result = await _troubleLoginService.sendOtp(email: email);
      } else {
        result = await _apiService.sendOtp(email: email, purpose: purpose);
      }

      if (result['success'] == true) {
        otp.value = '';
        _showSuccess('OTP has been resent to your email');
      } else {
        _showError(result['message'] ?? 'Failed to resend OTP');
      }
    } catch (e) {
      _showError('Connection failed. Please try again.');
    } finally {
      isResending.value = false;
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
}
