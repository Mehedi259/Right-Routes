import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/constants/services/auth_service.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/constants/services/device_storage_service.dart';
import '../../../../core/routes/all_routes.dart';

class AuthController extends GetxController {
  final AuthRepository _authRepository;
  final DeviceStorageService _deviceStorage;

  AuthController({
    required AuthRepository authRepository,
    required DeviceStorageService deviceStorage,
  })  : _authRepository = authRepository,
        _deviceStorage = deviceStorage;

  // UI States
  final RxBool isLoading = false.obs;

  // OTP Timer State
  final RxInt otpTimerSeconds = 120.obs;
  Timer? _timer;

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCENARIO 1: App Launch (Check Trusted & Logged In)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> checkAppLaunch() async {
    isLoading.value = true;
    try {
      // 1. Get or Create Device ID FIRST
      final deviceId = await _deviceStorage.getOrCreateDeviceId();
      debugPrint('\n===================================================');
      debugPrint('📱 Device Id: $deviceId');
      debugPrint('===================================================\n');

      // 2. Call device-info API to check device status (GET)
      if (deviceId != null) {
        try {
          final checkResult = await _authRepository.checkDeviceInfo({
            'device_id': deviceId,
          });

          if (checkResult.success) {
            final data = checkResult.data;
            bool isDeviceRegister = data['device_register'] == true;
            
            if (isDeviceRegister) {
              debugPrint('✅ [AuthController] Device is already registered.');
              if (data['device_user_email'] != null) {
                await AuthService.saveDeviceUserEmail(data['device_user_email']);
              }
              // Mark as trusted for routing
              await _deviceStorage.saveTrustedStatus(true);
            } else {
              debugPrint('⚠️ [AuthController] Device not registered. Will route to Get Started.');
              // We do not auto-register here anymore, user must go through Get Started
              await _deviceStorage.saveTrustedStatus(false);
            }
          } else {
            debugPrint('⚠️ [AuthController] checkDeviceInfo failed: ${checkResult.message}');
          }
        } catch (e) {
          debugPrint('⚠️ [AuthController] checkDeviceInfo exception (ignoring): $e');
        }
      } else {
        debugPrint('❌ [AuthController] Failed to get Device ID!');
      }

      // 3. Check local trusted status & token
      final isTrusted = await _deviceStorage.readTrustedStatus();
      final accessToken = await _deviceStorage.readAccessToken();

      if (isTrusted && accessToken != null && accessToken.isNotEmpty) {
        // TODO: Replace with actual user type check from your local storage/API
        bool isBusinessOwner = false;

        if (isBusinessOwner) {
          Get.offAllNamed(AppRoutes.teamManager);
        } else {
          String? lastRoute = AuthService.getLastRoute();
          if (lastRoute != null && lastRoute.isNotEmpty) {
            Map<String, dynamic>? lastArgs = AuthService.getLastRouteArgs();
            Get.offAllNamed(lastRoute, arguments: lastArgs);
          } else {
            Get.offAllNamed(AppRoutes.homeScreen);
          }
        }
      } else {
        // Route based on device trust status
        if (isTrusted) {
          Get.offAllNamed(AppRoutes.enterEmailScreen);
        } else {
          Get.offAllNamed(AppRoutes.getStartedScreen);
        }
      }
    } catch (e) {
      debugPrint("❌ [AuthController] Error on App Launch: $e");
      Get.offAllNamed(AppRoutes.enterEmailScreen); // Fallback
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCENARIO 2: Logged Out but Trusted Device (Check Email)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> checkEmailAndContinue(String email) async {
    isLoading.value = true;
    try {
      final result = await _authRepository.continueWithEmail(email);

      if (result.success) {
        final String nextStep = result.nextStep ?? '';

        if (nextStep == 'LOGIN_PASSWORD') {
          // Returning user -> go to login password
          Get.toNamed(AppRoutes.loginAccount, arguments: {'email': email});
        } else if (nextStep == 'CREATE_PASSWORD') {
          // New user -> go to create password
          Get.toNamed(AppRoutes.createAccountScreen,
              arguments: {'email': email});
        } else if (nextStep == 'VERIFY_OTP') {
          // Needs OTP verification (e.g. untrusted device)
          startOtpTimer();
          Get.toNamed(AppRoutes.otpVerificationScreen,
              arguments: {'email': email, 'purpose': 'REGISTER'});
        } else {
          // Fallback or untrusted device flow
          Get.toNamed(AppRoutes.enterEmailScreen, arguments: {'email': email});
        }
      } else {
        _showError(result.message ?? 'An error occurred');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCENARIO 2.5: Create Password (For New Users)
  // ═══════════════════════════════════════════════════════════════════════════
  Future<void> createPassword(String email, String password) async {
    isLoading.value = true;
    try {
      final result = await _authRepository.createPassword(email, password);

      if (result.success) {
        if (result.message != null) _showSuccess(result.message!);

        if (result.nextStep == 'VERIFY_OTP') {
          startOtpTimer();
          Get.toNamed(AppRoutes.otpVerificationScreen,
              arguments: {'email': email, 'purpose': 'REGISTER'});
        } else {
          // Direct login fallback if OTP is not required
          Get.toNamed(AppRoutes.loginAccount);
        }
      } else {
        _showError(result.message ?? 'An error occurred');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // SCENARIO 3: Untrusted Device (OTP Flow & Login)
  // ═══════════════════════════════════════════════════════════════════════════

  /// Sends the OTP and starts the timer
  Future<void> sendOtp(String email, {String purpose = 'REGISTER'}) async {
    isLoading.value = true;
    try {
      // In this scenario, we might be verifying the device itself
      final result =
          await _authRepository.resendOtp(email: email, purpose: purpose);

      if (result.success) {
        if (result.message != null) _showSuccess(result.message!);
        startOtpTimer();
        Get.toNamed(AppRoutes.otpVerificationScreen,
            arguments: {'email': email, 'purpose': purpose});
      } else {
        _showError(result.message ?? 'An error occurred');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Verifies the OTP Code
  Future<void> verifyOtp(String email, String otpCode, String purpose) async {
    isLoading.value = true;
    try {
      final result = await _authRepository.verifyOtp(
        email: email,
        otpCode: otpCode,
        purpose: purpose,
      );

      if (result.success) {
        _timer?.cancel();
        if (result.message != null) _showSuccess(result.message!);

        // Mark device as trusted
        await _deviceStorage.saveTrustedStatus(true);

        if (result.nextStep == 'CREATE_PASSWORD') {
          Get.toNamed(AppRoutes.createAccountScreen,
              arguments: {'email': email});
        } else {
          Get.toNamed(AppRoutes.loginAccount, arguments: {'email': email});
        }
      } else {
        _showError(result.message ?? 'An error occurred');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Final Login Step
  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final result = await _authRepository.login(email, password);

      if (result.success) {
        final token = result.data['token'] ?? result.data['access_token'];
        if (token != null) {
          await _deviceStorage.saveAccessToken(token);
        }

        // Mark device as trusted since login succeeded
        await _deviceStorage.saveTrustedStatus(true);

        if (result.message != null) _showSuccess(result.message!);

        // Route dynamically based on User Type (needs implementation based on your data)
        bool isBusinessOwner = result.data['user_type'] == 'BUSINESS_OWNER';
        if (isBusinessOwner) {
          Get.offAllNamed(AppRoutes.teamManager);
        } else {
          Get.offAllNamed(AppRoutes.homeScreen);
        }
      } else {
        _showError(result.message ?? 'An error occurred');
      }
    } finally {
      isLoading.value = false;
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // UTILITIES
  // ═══════════════════════════════════════════════════════════════════════════

  void startOtpTimer() {
    _timer?.cancel();
    otpTimerSeconds.value = 120;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (otpTimerSeconds.value > 0) {
        otpTimerSeconds.value--;
      } else {
        _timer?.cancel();
      }
    });
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.withValues(alpha: 0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
    );
  }

  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent.withValues(alpha: 0.8),
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
      borderRadius: 8,
    );
  }
}
