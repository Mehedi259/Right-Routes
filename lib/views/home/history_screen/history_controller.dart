import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/core/constants/services/api_client.dart';
import 'package:right_routes/core/constants/api_config/home_api_constant/home_api_constant.dart';
import 'package:dio/dio.dart' as dio;

/// ---------------------------------------------------------------------------
/// CONTROLLER (GetX)
/// ---------------------------------------------------------------------------
class HistoryController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  RxString searchQuery = "".obs;
  RxBool selectAll = false.obs;
  RxBool isLoading = false.obs;
  bool _isDeleting = false;

  RxList<RouteItem> routes = <RouteItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchRoutes();
  }

  Future<void> fetchRoutes({String query = '', bool showLoading = true}) async {
    try {
      if (showLoading) isLoading.value = true;
      String urlStr = '${HomeApiConstant.baseUrl}${HomeApiConstant.routePost}';
      if (query.isNotEmpty) {
        urlStr += '?search=$query';
      }
      final url = Uri.parse(urlStr);
      final response = await ApiClient.get(url);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final List list = data['data'];
          routes.value = list
              .map((e) => RouteItem.fromJson(e))
              .toList()
              .reversed
              .toList();
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to load routes (Status: ${response.statusCode})',
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      debugPrint('Error fetching routes: $e');
      String errorMsg = 'An error occurred while fetching routes';
      if (e is dio.DioException) {
        if (e.type == dio.DioExceptionType.connectionError || e.type == dio.DioExceptionType.connectionTimeout || e.type == dio.DioExceptionType.unknown) {
          errorMsg = 'No internet connection. Please check your network and try again.';
        } else {
          errorMsg = 'Server Error: Unable to fetch history at this time.';
        }
      }
      Get.snackbar(
        'Error',
        errorMsg,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  void updateSearch(String value) {
    searchQuery.value = value;
  }

  void toggleSelectAll() {
    selectAll.value = !selectAll.value;
    for (var route in routes) {
      route.isSelected.value = selectAll.value;
    }
  }

  void cancel() {
    selectAll.value = false;
    for (var route in routes) {
      route.isSelected.value = false;
    }
  }

  void toggleRoute(int index) {
    routes[index].isSelected.value = !routes[index].isSelected.value;
    selectAll.value = routes.every((route) => route.isSelected.value);
  }

  void deleteSelected() {
    final selectedCount =
        routes.where((route) => route.isSelected.value).length;

    if (selectedCount == 0) {
      Get.snackbar(
        'No Selection',
        'Please select routes to delete',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: 15.w),
        child: Container(
          decoration: const BoxDecoration(color: Color(0xFFB71C1C)),
          padding: EdgeInsets.all(15.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Icon(Icons.notifications, color: Colors.white, size: 20),
                  GestureDetector(
                    onTap: () async {
                      if (_isDeleting) return;
                      _isDeleting = true;
                      
                      try {
                        Get.dialog(
                          const Center(child: CircularProgressIndicator(color: AppColors.orange)),
                          barrierDismissible: false,
                        );

                        final selectedIds = routes
                            .where((route) => route.isSelected.value)
                            .map((route) => int.tryParse(route.id) ?? 0)
                            .where((id) => id != 0)
                            .toList();

                        final url = Uri.parse('${HomeApiConstant.baseUrl}/route/bulk-delete/');
                        final response = await ApiClient.delete(
                          url,
                          body: {"route_ids": selectedIds},
                        );

                        Get.close(2); // Safely closes both the loader AND confirmation dialog together

                        if (response.statusCode == 200 || response.statusCode == 204) {
                          final data = response.data;
                          if (data['success'] == true) {
                            Get.snackbar(
                              'Success',
                              data['message'] ?? 'Routes deleted successfully',
                              backgroundColor: Colors.green.shade400,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                            );
                            selectAll.value = false;
                            await fetchRoutes(showLoading: false);
                          } else {
                            Get.snackbar(
                              'Error',
                              data['message'] ?? 'Failed to delete routes (Status: ${response.statusCode})',
                              backgroundColor: Colors.red.shade400,
                              colorText: Colors.white,
                              snackPosition: SnackPosition.TOP,
                            );
                          }
                        } else {
                          Get.snackbar(
                            'Error',
                            'Failed to delete routes (Status: ${response.statusCode})',
                            backgroundColor: Colors.red.shade400,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      } catch (e) {
                        Get.close(2); // Safely closes both dialogs on error
                        debugPrint('Error deleting routes: $e');
                        String errorMsg = 'An error occurred during deletion';
                        if (e is dio.DioException) {
                          errorMsg = 'Server Error (Status: ${e.response?.statusCode ?? "Unknown"}): ${e.message}';
                        }
                        Get.snackbar(
                          'Error',
                          errorMsg,
                          backgroundColor: Colors.red.shade400,
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                        );
                      } finally {
                        _isDeleting = false;
                      }
                    },
                    child: Container(
                      // ✅ UPDATED: Fluid padding instead of fixed height/width
                      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 6.r),
                      decoration: BoxDecoration(
                        color: AppColors.darkGray,
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Center(
                        child: Text(
                          'Confirm',
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Text(
                'Are you sure you want to delete $selectedCount Route(s)?',
                textAlign: TextAlign.start,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w400,
                  height: 1.5.h,
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> duplicateSelected() async {
    final selectedRoutes =
        routes.where((route) => route.isSelected.value).toList();

    if (selectedRoutes.isEmpty) {
      Get.snackbar(
        'No Selection',
        'Please select a route to duplicate',
        backgroundColor: Colors.orange.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (selectedRoutes.length > 1) {
      Get.dialog(
        AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          backgroundColor: AppColors.darkGray,
          title: Row(
            children: [
              const Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8.w),
              const Text('Error', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'You can only duplicate one route at a time. Please check one only.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
      return;
    }

    final routeToDuplicate = selectedRoutes.first;
    
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: AppColors.orange)),
        barrierDismissible: false,
      );

      final url = Uri.parse('${HomeApiConstant.baseUrl}/route/${routeToDuplicate.id}/duplicate-route/');
      final response = await ApiClient.post(url);

      if (Get.isDialogOpen ?? false) Get.back();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          Get.snackbar(
            'Success',
            data['message'] ?? 'Route duplicated successfully',
            backgroundColor: Colors.green.shade400,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
          await fetchRoutes();
          cancel();
        } else {
          Get.snackbar(
            'Error',
            data['message'] ?? 'Failed to duplicate route',
            backgroundColor: Colors.red.shade400,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        Get.snackbar(
          'Error',
          'Failed to duplicate route',
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      debugPrint('Error duplicating route: $e');
      Get.snackbar(
        'Error',
        'An error occurred',
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }



  void searchRoutes() {
    final query = searchController.text.trim(); 
    fetchRoutes(query: query);
  }

  void openRouteDetails(int index) {
    final route = routes[index];

    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.darkGray,
        title: const Text('Route Details', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ID: ${route.id}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            SizedBox(height: 8.h),
            Text('Date: ${route.date}', style: const TextStyle(color: Colors.white)),
            SizedBox(height: 8.h),
            Text('Title: ${route.title}', style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Close', style: TextStyle(color: Colors.white))),
          TextButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.confirmYourRoutes, arguments: {'routeId': route.id});
            },
            child: const Text('Edit Route', style: TextStyle(color: AppColors.orange)),
          ),
        ],
      ),
    );
  }

  @override
  void onClose() {
    searchController.dispose(); 
    super.onClose();
  }
}

class RouteItem {
  final String id;
  final String date;
  final String title;
  final RxBool isSelected;
  bool highlighted;

  RouteItem({
    required this.id,
    required this.date,
    required this.title,
    required this.isSelected,
    this.highlighted = false,
  });

  factory RouteItem.fromJson(Map<String, dynamic> json) {
    String formattedDate = '';
    if (json['created_at'] != null) {
      try {
        final dt = DateTime.parse(json['created_at']);
        formattedDate = '${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}/${dt.year}';
      } catch (e) {
        formattedDate = json['created_at'].toString();
      }
    }

    return RouteItem(
      id: json['id']?.toString() ?? '',
      title: json['name'] ?? 'Unknown',
      date: formattedDate,
      isSelected: false.obs,
    );
  }
}
