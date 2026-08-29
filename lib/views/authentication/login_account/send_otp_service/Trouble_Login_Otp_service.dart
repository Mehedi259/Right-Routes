import 'package:right_routes/core/constants/services/api_client.dart';
import '../../../../core/constants/services/auth_service.dart';
import '../../../../core/constants/api_config/api_config.dart';

/// ═══════════════════════════════════════════════════════════
/// TroubleLoginOtpService - Send OTP for Trouble Login
/// ✅ FIXED: All endpoints have trailing slash (/)
/// ═══════════════════════════════════════════════════════════
class TroubleLoginOtpService {
  // ═══════════════════════════════════════════════════════════
  // 📤 SEND OTP - ✅ WITH TRAILING SLASH
  // ═══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> sendOtp({
    required String email,
    String? emailToken,
  }) async {
    try {
      // ✅ IMPORTANT: Trailing slash added
      final url = Uri.parse(ApiConfig.fullDirectLoginOtpSendUrl);

      print('');
      print('═══════════════════════════════════════════════════');
      print('📤 TROUBLE LOGIN - SENDING OTP');
      print('═══════════════════════════════════════════════════');
      print('📧 Email: $email');
      print('📍 Endpoint: $url');

      // Prepare request body
      final requestBody = {'email': email};
      print('📋 Request Body: $requestBody');

      // Prepare headers
      final headers = <String, String>{
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      // Add email token if provided or get from AuthService
      String? token = emailToken;
      if (token == null || token.isEmpty) {
        token = await AuthService.getEmailToken();
      }

      if (token != null && token.isNotEmpty) {
        headers['X-Email-Token'] = token;
        print('🔑 Email Token: Present');
      }

      print('📋 Headers: ${headers.keys.join(', ')}');

      // Make API call
      final response = await ApiClient.post(
        url,
        headers: headers,
        body: requestBody,
      );

      print('');
      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        // Save email token from response
        if (data['email_token'] != null) {
          await AuthService.saveEmailToken(data['email_token']);
          print('✅ Email token saved: ${data['email_token']}');
        }

        // Save email
        await AuthService.saveUserEmail(email);
        print('✅ Email saved: $email');

        print('✅ OTP sent successfully');
        print('═══════════════════════════════════════════════════');
        print('');

        return {
          'success': true,
          'message': data['message'] ?? 'OTP sent successfully',
          'data': data,
        };
      } else {
        // Handle error response
        String errorMessage = 'Failed to send OTP';

        try {
          final errorData = response.data;
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (e) {
          print('❌ ERROR: Failed to parse response data');
          print('❌ Parse error: $e');
          print('❌ Response was: ${response.data}');
          errorMessage = 'Server error. Please try again.';
        }

        print('❌ Error: $errorMessage');
        print('═══════════════════════════════════════════════════');
        print('');

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('❌ Exception: $e');
      print('═══════════════════════════════════════════════════');
      print('');

      return {
        'success': false,
        'message': 'Network error: $e',
      };
    }
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ VERIFY OTP - ✅ WITH TRAILING SLASH
  // ═══════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      // ✅ IMPORTANT: Trailing slash added
      final url = Uri.parse(ApiConfig.fullDirectLoginOtpVerifyUrl);

      print('');
      print('═══════════════════════════════════════════════════');
      print('✅ TROUBLE LOGIN - VERIFYING OTP');
      print('═══════════════════════════════════════════════════');
      print('🔐 OTP: $otp');
      print('📍 Endpoint: $url');

      // Prepare headers
      final headers = {
        'Content-Type': 'application/json',
      };

      // Prepare body
      final body = {'email': email, 'otp_code': otp};
      print('📋 Request Body: $body');

      // Make API call
      final response = await ApiClient.post(
        url,
        headers: headers,
        body: body,
      );

      print('');
      print('📊 Response Status: ${response.statusCode}');
      print('📄 Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;

        print('✅ OTP verified successfully');
        print('═══════════════════════════════════════════════════');
        print('');

        return {
          'success': true,
          'message': data['message'] ?? 'OTP verified successfully',
          'data': data,
        };
      } else {
        final errorData = response.data;
        final errorMessage = errorData['message'] ?? 'Failed to verify OTP';

        print('❌ Error: $errorMessage');
        print('═══════════════════════════════════════════════════');
        print('');

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } catch (e) {
      print('❌ Exception: $e');
      print('═══════════════════════════════════════════════════');
      print('');

      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}
