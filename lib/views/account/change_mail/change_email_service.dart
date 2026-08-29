import 'package:dio/dio.dart';
import 'package:get/get.dart' hide FormData, Response;
import '../../../core/constants/services/auth_service.dart';
import '../../../core/constants/api_config/api_config.dart';
import '../../home/account_screen/account_screen_for_team.dart';
import '../../home/account_screen/single_subscriber_screen.dart';
import '../../home/account_screen/team_user_screen.dart';

class ChangeEmailService {
  // 🔥 Change Email API Call
  static Future<Map<String, dynamic>> changeEmail(String newEmail) async {
    try {
      // 🔑 AuthService থেকে Access Token নিচ্ছি
      String? token = await AuthService.getAccessToken();

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 API REQUEST (DIO)');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🌐 URL: ${ApiConfig.fullChangeEmailUrl}');
      print('📧 New Email: $newEmail');
      print('🔑 Token: ${token ?? "❌ No token found"}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      final dio = Dio();
      final formData = FormData.fromMap({
        'new_email': newEmail,
      });

      final response = await dio.post(
        ApiConfig.fullChangeEmailUrl,
        data: formData,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
          validateStatus: (status) => status != null && status < 500, // handle 4xx as normal response
        ),
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📥 API RESPONSE');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Data: ${response.data}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // ✅ Success Response
        final data = response.data;

        print('✅ SUCCESS: Email changed successfully!\n');

        // 💾 AuthService এ email update করছি
        await AuthService.updateUserEmail(newEmail);

        // 🔄 Update active GetX Controllers so the UI refreshes instantly
        if (Get.isRegistered<ManageAccountController>()) {
          Get.find<ManageAccountController>().userEmail.value = newEmail;
        }
        if (Get.isRegistered<SingleSubscriberManageAccountController>()) {
          Get.find<SingleSubscriberManageAccountController>().userEmail.value = newEmail;
        }
        if (Get.isRegistered<TeamUserManageAccountController>()) {
          Get.find<TeamUserManageAccountController>().userEmail.value = newEmail;
        }

        return {
          'success': true,
          'message': data is Map ? (data['detail'] ?? data['message'] ?? 'Email updated successfully.') : 'Email updated successfully.',
          'data': data,
        };
      } else {
        // ❌ Error Response from Server
        final error = response.data;

        print('❌ ERROR: $error\n');

        String errorMessage = 'Failed to change email';
        if (error is Map) {
          if (error['detail'] != null && error['detail'] is String) {
            errorMessage = error['detail'];
          } else if (error['message'] != null && error['message'] is String) {
            errorMessage = error['message'];
          } else if (error['new_email'] != null && error['new_email'] is List) {
            errorMessage = error['new_email'].first.toString();
          }
        } else if (error is String) {
          errorMessage = error;
        }

        return {
          'success': false,
          'message': errorMessage,
        };
      }
    } on DioException catch (e) {
      // ❌ Dio Error
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ DIO EXCEPTION OCCURRED');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Error: ${e.message}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      String errorMessage = 'Network error. Please check your connection.';
      if (e.response != null && e.response?.data is Map) {
         final errorData = e.response?.data as Map;
         errorMessage = errorData['detail'] ?? errorData['message'] ?? errorData['new_email']?.first?.toString() ?? errorMessage;
      }

      return {
        'success': false,
        'message': errorMessage,
      };
    } catch (e) {
      // ❌ Generic Error
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ EXCEPTION OCCURRED');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('Error: $e');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      return {
        'success': false,
        'message': 'An unexpected error occurred.',
      };
    }
  }
}
