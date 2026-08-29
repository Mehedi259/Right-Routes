import 'package:right_routes/core/constants/services/api_client.dart';
import '../../../core/constants/api_config/api_config.dart';

class RegisterApiService {
  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    bool isTouchIdEnabled = false,
    bool termsAgreed = true,
  }) async {
    try {
      final url = Uri.parse(ApiConfig.fullCreatePasswordUrl);
      debugLog('REGISTER', 'POST $url | email: $email');

      final response = await ApiClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: {
          'email': email,
          'password': password,
          'is_touch_id_enabled': isTouchIdEnabled,
          'terms_agreed': termsAgreed,
        },
        requireAuth: false,
      );

      debugLog('REGISTER', '${response.statusCode} | ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': _extractError(response.data, 'Registration failed')
        };
      }
    } catch (e) {
      debugLog('REGISTER', 'EXCEPTION: $e');
      return {
        'success': false,
        'message': 'Network error. Please check your connection.'
      };
    }
  }

  String _extractError(dynamic data, String fallback) {
    try {
      if (data is Map) {
        if (data['detail'] != null) {
          if (data['detail'] is Map) {
            final detail = data['detail'] as Map;
            final firstValue = detail.values.first;
            if (firstValue is List && firstValue.isNotEmpty) {
              return firstValue.first.toString();
            }
            return firstValue.toString();
          }
          return data['detail'].toString();
        }
        return data['message']?.toString() ??
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
