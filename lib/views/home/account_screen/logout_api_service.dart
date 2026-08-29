import 'package:right_routes/core/constants/services/api_client.dart';
import '../../../../core/constants/api_config/api_config.dart';

class LogoutApiService {
  static Future<Map<String, dynamic>> logout() async {
    try {
      final url = Uri.parse(ApiConfig.fullLogoutUrl);

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📤 API REQUEST - LOGOUT');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('🌐 URL: $url');
      
      final response = await ApiClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
      );

      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📥 API RESPONSE - LOGOUT');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('📊 Status Code: ${response.statusCode}');
      print('📦 Response Data: ${response.data}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

      if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 204) {
        return {'success': true, 'message': 'Logout successful'};
      } else {
        return {'success': false, 'message': 'Failed to logout on server'};
      }
    } catch (e) {
      print('❌ EXCEPTION: $e');
      return {'success': false, 'message': 'Network error'};
    }
  }
}
