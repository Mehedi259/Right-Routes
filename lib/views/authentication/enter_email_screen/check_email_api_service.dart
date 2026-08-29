import 'package:right_routes/core/constants/services/api_client.dart';
import '../../../core/constants/api_config/api_config.dart';

class CheckEmailApiService {
  Future<Map<String, dynamic>> checkEmail(String email) async {
    try {
      final url = Uri.parse(ApiConfig.fullCheckEmailUrl);

      debugLog('CHECK-EMAIL', 'POST $url | email: $email');

      final response = await ApiClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: {'email': email},
        requireAuth: false,
      );

      debugLog('CHECK-EMAIL', '${response.statusCode} | ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;
        return {
          'success': data is Map ? (data['success'] ?? true) : true,
          'data': data
        };
      } else {
        final errorMsg = _extractError(response.data, 'Failed to check email');
        return {'success': false, 'message': errorMsg};
      }
    } catch (e) {
      debugLog('CHECK-EMAIL', 'EXCEPTION: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.'
      };
    }
  }

  /// Extract error message from backend response
  String _extractError(dynamic data, String fallback) {
    try {
      if (data is Map) {
        return data['detail']?.toString() ??
            data['message']?.toString() ??
            data['error']?.toString() ??
            fallback;
      }
      return data.toString();
    } catch (_) {
      return fallback;
    }
  }

  void debugLog(String tag, String msg) {
    print('[$tag] $msg');
  }
}
