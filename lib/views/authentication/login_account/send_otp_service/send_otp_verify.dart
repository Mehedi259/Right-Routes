import 'dart:convert';
import 'package:right_routes/core/constants/services/api_client.dart';
import '../../../../core/constants/api_config/api_config.dart';

class TroubleLoginOtpVerifyService {
  // -----------------------------------------------------------
  // ? VERIFY OTP (Trouble Login)
  // -----------------------------------------------------------
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otpCode,
  }) async {
    print('');
    print('---------------------------------------------------');
    print('? TROUBLE LOGIN - VERIFYING OTP');
    print('---------------------------------------------------');
    print('?? Email: $email');
    print('?? OTP: $otpCode');

    try {
      // Prepare request body
      final requestBody = {
        'email': email.trim(),
        'otp_code': otpCode.trim(),
      };

      print('?? Endpoint: ${ApiConfig.fullVerifyOtpUrl}');
      print('?? Request Body: $requestBody');

      // Make API call using ApiClient (No auth required for login endpoints)
      final response = await ApiClient.post(
        Uri.parse(ApiConfig.fullVerifyOtpUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: requestBody,
        requireAuth: false,
      );

      print('?? Response Status: ${response.statusCode}');
      print('?? Response Headers: ${response.headers}');

      final responsePreview = response.data.toString().length > 500
          ? '${response.data.toString().substring(0, 500)}...'
          : response.data.toString();
      print('?? Response Data: $responsePreview');

      // Try to parse JSON (Dio handles this automatically, so data should be a Map)
      Map<String, dynamic> data;
      try {
        if (response.data is Map) {
          data = Map<String, dynamic>.from(response.data);
        } else if (response.data is String) {
          data = jsonDecode(response.data);
        } else {
          data = {};
        }
      } catch (e) {
        print('? ERROR: Failed to parse JSON response');
        print('? Parse error: $e');
        print('? Response was: ${response.data}');
        print('---------------------------------------------------');
        print('');

        return {
          'success': false,
          'message': 'Invalid server response format',
        };
      }

      if ((response.statusCode == 200 || response.statusCode == 201) &&
          (data['success'] == null || data['success'] == true)) {
        print('✅ OTP verified successfully');
        print('✅ Response data keys: ${data.keys.join(", ")}');
        print('═══════════════════════════════════════════════════');
        print('');

        return {
          'success': true,
          'message': data['message'] ?? 'OTP verified successfully',
          'data': data,
        };
      } else {
        String errorMessage = 'Failed to verify OTP';
        if (data['message'] != null) {
          errorMessage = data['message'];
        } else if (data['error'] != null) {
          errorMessage = data['error'];
        } else if (data['detail'] != null) {
          if (data['detail'] is Map && data['detail']['otp'] != null) {
            errorMessage = data['detail']['otp'];
          } else if (data['detail'] is String) {
            errorMessage = data['detail'];
          }
        }

        print('❌ Error Response: $errorMessage');
        print('❌ Status Code: ${response.statusCode}');
        print('═══════════════════════════════════════════════════');
        print('');

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('?? EXCEPTION in verifyOtp: $e');
      print('?? Stack trace: ${StackTrace.current}');
      print('---------------------------------------------------');
      print('');

      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
}
