import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/views/authentication/login_account/login_api_service/login_api_service.dart';

class WeLoggedController extends GetxController {
  final LoginApiService _apiService = LoginApiService();
  final isLoading = false.obs;

  // ─── FETCH USER INFO & ROUTE ──────────────────────────────
  Future<void> fetchUserInfoAndRoute() async {
    isLoading.value = true;
    try {
      final userResponse = await _apiService.getUserInfo();

      if (userResponse['success'] == true && userResponse['data'] != null) {
        final userData = userResponse['data'];
        final currentPlanType =
            userData['current_plan_type']?.toString().toUpperCase();

        if (currentPlanType == 'BUSINESS_OWNER' ||
            currentPlanType == 'TEAM_OWNER' ||
            currentPlanType == 'TEAM_MANAGER') {
          Get.offAllNamed(AppRoutes.teamManager);
        } else if (currentPlanType == 'INDIVIDUAL') {
          Get.offAllNamed(AppRoutes.homeScreen);
        } else {
          // No valid plan type (New user, Subscription ended, or null)
          Get.offAllNamed(AppRoutes.individualTeam);
        }
      } else {
        // Failed to get user data
        Get.offAllNamed(AppRoutes.individualTeam);
      }
    } catch (e) {
      Get.offAllNamed(AppRoutes.individualTeam);
    } finally {
      isLoading.value = false;
    }
  }
}
