import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:right_routes/core/routes/all_routes.dart';
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

    return GestureDetector(
      onTap: () {
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
                width: context.s(26),  // original: 26.w
                height: context.s(26), // original: 26.h — square তাই s()
                colorFilter: ColorFilter.mode(
                  isSelected
                      ? const Color(0xFFFF8742)
                      : Colors.white, // original: no opacity
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(height: context.h(2)), // original: 2.h
              Text(
                label,
                style: TextStyle(
                  fontSize: context.sp(12), // original: 12.sp
                  fontWeight: isSelected
                      ? FontWeight.w600
                      : FontWeight.w400,
                  color: isSelected
                      ? const Color(0xFFFF8742)
                      : Colors.white, // original: no opacity
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
  final List<String> _routeHistory = [];

  final Map<String, int> _routeToIndex = {
    AppRoutes.homeScreen: 0,
    AppRoutes.teamManager: 1,
    AppRoutes.historyScreen: 2,
    AppRoutes.accountScreen: 3,
  };

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
