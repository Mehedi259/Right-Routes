import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:right_routes/views/home/offline_routes_screen.dart' as right_routes_offline;
import 'history_controller.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  HistoryController get controller => Get.put(HistoryController());

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = context.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1129),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageManager.mapBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: isLandscape
                ? EdgeInsets.all(context.s(12))
                : EdgeInsets.only(
                    top: context.h(20),
                    left: context.w(20),
                    right: context.w(20),
                    bottom: context.w(20),
                  ),
            child: Flex(
              direction: isLandscape ? Axis.horizontal : Axis.vertical,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==========================================
                // HEADER SECTION
                // ==========================================
                SizedBox(
                  width: isLandscape
                      ? MediaQuery.of(context).size.width * 0.45
                      : double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Logo
                      Center(
                        child: Container(
                          width: isLandscape
                              ? MediaQuery.of(context).size.width * 0.25
                              : context.w(225),
                          height: isLandscape
                              ? MediaQuery.of(context).size.height * 0.25
                              : context.h(112),
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(ImageManager.splashScreenLogo),
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                          height: isLandscape ? context.s(10) : context.h(18)),

                      // Title
                      Text(
                        "My Routes History",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: context.sp(30),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(
                          height: isLandscape ? context.s(12) : context.h(22)),

                      // Checkbox + Buttons row
                      Row(
                        children: [
                          Obx(() => GestureDetector(
                                onTap: controller.toggleSelectAll,
                                child: Container(
                                  alignment: Alignment.center,
                                  width: 26.0,
                                  height: 26.0,
                                  decoration: BoxDecoration(
                                    color: controller.selectAll.value
                                        ? const Color(0xFFFF6B35)
                                        : AppColors.medGray,
                                    border: Border.all(
                                      color: controller.selectAll.value
                                          ? const Color(0xFFFF6B35)
                                          : AppColors.medGray,
                                      width: 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  child: controller.selectAll.value
                                      ? const Icon(Icons.check,
                                          color: Colors.white, size: 18.0)
                                      : null,
                                ),
                              )),
                          SizedBox(width: context.w(12)),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _smallButton(context, "Delete",
                                      onTap: controller.deleteSelected),
                                  SizedBox(width: context.w(8)),
                                  _smallButton(context, "Duplicate",
                                      onTap: controller.duplicateSelected),
                                  SizedBox(width: context.w(8)),
                                  _smallButton(context, "Cancel",
                                      onTap: controller.cancel),
                                  SizedBox(width: context.w(8)),
                                  _smallButton(context, "Exit",
                                      onTap: () => Get.back()),
                                  SizedBox(width: context.w(8)),
                                  _smallButton(context, "Offline",
                                      onTap: () => Get.to(() => const right_routes_offline.OfflineRoutesScreen())),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.h(15)),
                      Divider(color: AppColors.white, thickness: 1),
                      SizedBox(
                          height: isLandscape ? context.s(10) : context.h(5)),
                    ],
                  ),
                ),

                if (isLandscape) SizedBox(width: context.w(15)),

                // ==========================================
                // SEARCH & LIST SECTION
                // ==========================================
                Expanded(
                  child: Column(
                    children: [
                      // Search row — original: right aligned, search box fixed width
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(Icons.search,
                              color: Colors.white, size: context.sp(28)),
                          SizedBox(width: context.w(2)),
                          isLandscape
                              ? Expanded(
                                  child: _buildSearchBox(context, isLandscape))
                              : _buildSearchBox(context, isLandscape),
                          SizedBox(width: context.w(3)),
                          GestureDetector(
                            onTap: controller.searchRoutes,
                            child: Container(
                              width: context.w(33),
                              height: context.h(32),
                              decoration: BoxDecoration(
                                color: AppColors.medGray,
                                borderRadius:
                                    BorderRadius.circular(context.r(4)),
                              ),
                              child: Center(
                                child: Text(
                                  'GO',
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontSize: context.sp(18),
                                    fontWeight: FontWeight.w700,
                                    // height: 2.h ← original e chilo, TextStyle.height e .h lagano thik na
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.h(12)),

                      // List
                      Expanded(
                        child: Obx(() {
                          if (controller.isLoading.value) {
                            return const Center(
                              child: CircularProgressIndicator(color: AppColors.orange),
                            );
                          }
                          if (controller.routes.isEmpty) {
                            return RefreshIndicator(
                              color: AppColors.orange,
                              onRefresh: () async {
                                await controller.fetchRoutes(showLoading: false);
                              },
                              child: CustomScrollView(
                                physics: const AlwaysScrollableScrollPhysics(),
                                slivers: [
                                  SliverFillRemaining(
                                    child: Center(
                                      child: Text(
                                        'No routes found',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: context.sp(16)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }
                          return RefreshIndicator(
                            color: AppColors.orange,
                            onRefresh: () async {
                              await controller.fetchRoutes(showLoading: false);
                            },
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: controller.routes.length,
                              itemBuilder: (context, index) =>
                                  _routeItem(context, index),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // WIDGETS
  // ─────────────────────────────────────────────────────────────

  Widget _buildSearchBox(BuildContext context, bool isLandscape) {
    return Container(
      width: isLandscape ? null : context.w(195),
      height: context.h(32),
      padding: EdgeInsets.symmetric(horizontal: context.w(12)),
      decoration: BoxDecoration(
        color: AppColors.medGray,
        borderRadius: BorderRadius.circular(context.r(4)),
      ),
      child: Center(
        child: Material(
          color: Colors.transparent,
          child: TextField(
            controller: controller.searchController,
            cursorColor: AppColors.white,
            cursorHeight: context.h(18),
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: context.sp(16),
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintStyle: GoogleFonts.lato(
                color: Colors.white,
                fontSize: context.sp(16),
                fontWeight: FontWeight.w500,
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            onChanged: controller.updateSearch,
          ),
        ),
      ),
    );
  }

  Widget _smallButton(BuildContext context, String text,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: context.w(7),
          vertical: context.h(1),
        ),
        decoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: BorderRadius.circular(context.r(3)),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: context.sp(16),
              fontFamily: 'Lato',
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Widget _routeItem(BuildContext context, int index) {
    final route = controller.routes[index];
    return Obx(() {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: context.h(12)),
            decoration: BoxDecoration(
              color: route.isSelected.value
                  ? const Color(0xFF3A4A6B).withValues(alpha: 0.3)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(context.r(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Checkbox
                GestureDetector(
                  onTap: () => controller.toggleRoute(index),
                  child: Container(
                    alignment: Alignment.center,
                    width: 26.0,
                    height: 26.0,
                    decoration: BoxDecoration(
                      color: route.isSelected.value
                          ? const Color(0xFFFF6B35)
                          : AppColors.medGray,
                      border: Border.all(
                        color: route.isSelected.value
                            ? const Color(0xFFFF6B35)
                            : Colors.transparent,
                        width: 2.0,
                      ),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: route.isSelected.value
                        ? const Icon(Icons.check,
                            color: Colors.white, size: 18.0)
                        : null,
                  ),
                ),
                SizedBox(width: context.w(12)),

                // Route info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${index + 1}. ${route.date}",
                        style: TextStyle(
                          color: route.isSelected.value
                              ? const Color(0xFFFF6B35)
                              : Colors.white,
                          fontSize: context.sp(18),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: context.h(4)),
                      Text(
                        route.title,
                        style: TextStyle(
                          color: route.isSelected.value
                              ? const Color(0xFFFF6B35).withValues(alpha: 0.8)
                              : Colors.white70,
                          fontSize: context.sp(16),
                        ),
                      ),
                    ],
                  ),
                ),

                // Arrow
                GestureDetector(
                  onTap: () => controller.openRouteDetails(index),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: route.isSelected.value
                        ? const Color(0xFFFF6B35)
                        : AppColors.white,
                    size: context.sp(26),
                  ),
                ),
              ],
            ),
          ),
          if (index < controller.routes.length - 1)
            Divider(
              color: AppColors.dividerColor,
              thickness: 1,
              height: context.h(1),
            ),
        ],
      );
    });
  }
}
