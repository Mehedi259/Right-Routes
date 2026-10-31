import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/constants/api_config/home_api_constant/home_api_constant.dart';
import 'package:right_routes/core/constants/services/api_client.dart';
import 'package:right_routes/core/constants/services/auth_service.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';

class CustomNavbar extends StatefulWidget {
  const CustomNavbar({super.key});

  @override
  State<CustomNavbar> createState() => _CustomNavbarState();
}

class _CustomNavbarState extends State<CustomNavbar> {
  late NavController _navController;

  @override
  void initState() {
    super.initState();
    _navController = Get.put(NavController(), permanent: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _navController.updateFromCurrentRoute();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NavController>(
      id: 'navbar',
      builder: (controller) {
        return Container(
          height: context.h(60) + MediaQuery.of(context).padding.bottom,
          width: double.infinity,
          decoration: const BoxDecoration(
            color: Color(0xFF5A5A5A), // original color
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _navItem(
                  context: context,
                  controller: controller,
                  index: 0,
                  svgIcon: "assets/icons/New-Route-white.svg",
                  label: "New Route",
                  route: AppRoutes.homeScreen,
                ),
                _navItem(
                  context: context,
                  controller: controller,
                  index: 1,
                  svgIcon: "assets/icons/team_white.svg",
                  label: "Teams",
                  route: AppRoutes.teamManager,
                ),
                _navItem(
                  context: context,
                  controller: controller,
                  index: 2,
                  svgIcon: "assets/icons/History-white.svg",
                  label: "History",
                  route: AppRoutes.historyScreen,
                ),
                _navItem(
                  context: context,
                  controller: controller,
                  index: 3,
                  svgIcon: "assets/icons/Account-white.svg",
                  label: "Account",
                  route: AppRoutes.accountScreen,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _navItem({
    required BuildContext context,
    required NavController controller,
    required int index,
    required String svgIcon,
    required String label,
    required String route,
  }) {
    final bool isSelected = controller.selectedIndex.value == index;
    final bool isTeamsTab = index == 1;
    final bool isTeamsDisabled = isTeamsTab && !controller.isTeamPlan.value;

    return GestureDetector(
      onTap: () {
        if (isTeamsDisabled) {
          Get.dialog(
            AlertDialog(
              backgroundColor: const Color(0xFF2B2B2B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.r(8))),
              title: Text(
                'Team Plan Required',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Lato',
                  fontSize: context.sp(20),
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Text(
                'You currently have a Single user subscription. The Teams section is only accessible with an active Team plan.',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Lato',
                  fontSize: context.sp(16),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white70, fontSize: context.sp(16)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Get.back();
                    Get.toNamed(AppRoutes.chooseATeamPlan);
                  },
                  child: Text(
                    'Upgrade to Team',
                    style: TextStyle(
                      color: const Color(0xFFFF8742),
                      fontWeight: FontWeight.bold,
                      fontSize: context.sp(16),
                    ),
                  ),
                ),
              ],
            ),
          );
          return;
        }

        if (Get.currentRoute == route) return;
        controller.changeTab(index);
        Future.delayed(Duration.zero, () {
          Get.offAllNamed(route);
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(12),
          vertical: context.h(5),
        ),
        color: Colors.transparent,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                svgIcon,
                width: context.s(26),
                height: context.s(26),
                colorFilter: ColorFilter.mode(
                  isTeamsDisabled
                      ? Colors.white.withValues(alpha: 0.35)
                      : (isSelected
                          ? const Color(0xFFFF8742)
                          : Colors.white),
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(height: context.h(2)),
              Text(
                label,
                style: TextStyle(
                  fontSize: context.sp(12),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  color: isTeamsDisabled
                      ? Colors.white.withValues(alpha: 0.35)
                      : (isSelected
                          ? const Color(0xFFFF8742)
                          : Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// NavController
// ════════════════════════════════════════════════════════════════
class NavController extends GetxController {
  RxInt selectedIndex = 0.obs;
  RxBool isTeamPlan = false.obs;
  final List<String> _routeHistory = [];

  final Map<String, int> _routeToIndex = {
    AppRoutes.homeScreen: 0,
    AppRoutes.teamManager: 1,
    AppRoutes.historyScreen: 2,
    AppRoutes.accountScreen: 3,
  };

  @override
  void onInit() {
    super.onInit();
    isTeamPlan.value = AuthService.getIsTeamPlan();
    checkTeamSubscription();
  }

  Future<void> checkTeamSubscription() async {
    try {
      final token = await AuthService.getAccessToken();
      if (token == null || token.isEmpty) return;
      final uri = Uri.parse(HomeApiConstant.baseUrl + HomeApiConstant.currentPlan);
      final response = await ApiClient.get(uri);
      if (response.statusCode == 200) {
        final data = response.data is String ? jsonDecode(response.data) : response.data;
        if (data['success'] == true && data['data'] != null) {
          final pType = (data['data']['plan_type'] ?? '').toString().toUpperCase();
          final isTeam = (pType == 'TEAM');
          isTeamPlan.value = isTeam;
          await AuthService.saveIsTeamPlan(isTeam);
          update(['navbar']);
        }
      }
    } catch (_) {}
  }

  void updateTeamPlanStatus(bool isTeam) {
    isTeamPlan.value = isTeam;
    update(['navbar']);
  }

  void changeTab(int index) {
    selectedIndex.value = index;
    update(['navbar']);
  }

  void saveCurrentNavbarRoute() {
    final currentRoute = Get.currentRoute;
    if (_routeToIndex.containsKey(currentRoute)) {
      _routeHistory
        ..clear()
        ..add(currentRoute);
    }
  }

  void updateFromCurrentRoute() {
    final currentRoute = Get.currentRoute;

    if (_routeToIndex.containsKey(currentRoute)) {
      final index = _routeToIndex[currentRoute]!;
      if (selectedIndex.value != index) {
        selectedIndex.value = index;
        update(['navbar']);
      }
      if (_routeHistory.isEmpty || _routeHistory.last != currentRoute) {
        _routeHistory
          ..clear()
          ..add(currentRoute);
      }
    } else if (_routeHistory.isNotEmpty) {
      final lastNavbarRoute = _routeHistory.last;
      final index = _routeToIndex[lastNavbarRoute]!;
      if (selectedIndex.value != index) {
        selectedIndex.value = index;
        update(['navbar']);
      }
    }
  }
}
