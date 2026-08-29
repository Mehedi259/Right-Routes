import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:dio/dio.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/core/constants/api_config/home_api_constant/home_api_constant.dart';
import 'package:right_routes/core/constants/services/api_client.dart';
import 'package:right_routes/core/constants/services/auth_service.dart';

import '../history_screen/history_controller.dart';

// ─── Model ───────────────────────────────────────────────────────────────────
class DraftRouteModel {
  final String name;
  final String date;
  final int stops;
  const DraftRouteModel({
    required this.name,
    required this.date,
    required this.stops,
  });
}

// ─── Service ─────────────────────────────────────────────────────────────────
class CreateRouteService {
  static String _parseDioError(dynamic errBody) {
    if (errBody is Map) {
      if (errBody['message'] != null) {
        return errBody['message'].toString();
      } else if (errBody['detail'] != null) {
        final detail = errBody['detail'];
        if (detail is String) {
          return detail;
        } else if (detail is Map && detail.isNotEmpty) {
          final firstKey = detail.keys.first;
          final firstVal = detail[firstKey];
          if (firstVal is List && firstVal.isNotEmpty) {
            return '$firstKey: ${firstVal[0]}';
          }
          return '$firstKey: $firstVal';
        } else {
          return detail.toString();
        }
      }
    }
    return 'Server error';
  }

  static Future<Map<String, dynamic>> createRoute({
    required String name,
    required String startLocation,
    required String startLatitude,
    required String startLongitude,
    required String endLocation,
    required String endLatitude,
    required String endLongitude,
    required String permitText,
    File? permitFile,
  }) async {
    try {
      final url = Uri.parse(
        '${HomeApiConstant.baseUrl}${HomeApiConstant.routePost}',
      );

      debugPrint('🚀 [CreateRoute] Requesting: $url');

      Map<String, dynamic> dataMap = {
        'name': name,
        'start_location': startLocation,
        'start_latitude': startLatitude,
        'start_longitude': startLongitude,
        'end_location': endLocation,
        'end_latitude': endLatitude,
        'end_longitude': endLongitude,
        'permit_text': permitText,
      };

      if (permitFile != null) {
        dataMap['permit_file'] = await MultipartFile.fromFile(
          permitFile.path,
          filename: permitFile.path.split('/').last,
        );
      }

      FormData formData = FormData.fromMap(dataMap);

      final response = await ApiClient.sendMultipartRequest(
        url,
        data: formData,
        method: 'POST',
      );

      debugPrint('✅ [CreateRoute] Response Status: ${response.statusCode}');
      debugPrint('📄 [CreateRoute] Response Data: ${response.data}');

      final body =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'id': body['route']?['id'],
          'name': body['route']?['name'] ?? name,
          'message': body['message'],
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message':
              body['message'] ?? body['detail'] ?? 'Failed to create route',
        };
      }
    } catch (e) {
      debugPrint('❌ [CreateRoute] Error: $e');
      if (e is DioException) {
        final errBody = e.response?.data;
        return {
          'success': false,
          'statusCode': e.response?.statusCode,
          'message': _parseDioError(errBody),
        };
      }
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> updateRouteName({
    required int routeId,
    required String newName,
  }) async {
    try {
      final url = Uri.parse(
        '${HomeApiConstant.baseUrl}${HomeApiConstant.updateRouteName}$routeId/update-name/',
      );

      debugPrint('🚀 [UpdateRouteName] Requesting: $url');

      FormData formData = FormData.fromMap({
        'name': newName,
      });

      final response = await ApiClient.sendMultipartRequest(
        url,
        data: formData,
        method: 'PATCH',
      );

      debugPrint('✅ [UpdateRouteName] Response Status: ${response.statusCode}');
      debugPrint('📄 [UpdateRouteName] Response Data: ${response.data}');

      final body =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': body['message'] ?? 'Route name updated successfully.',
        };
      } else {
        return {
          'success': false,
          'statusCode': response.statusCode,
          'message': body['message'] ??
              body['detail'] ??
              'Failed to update route name',
        };
      }
    } catch (e) {
      debugPrint('❌ [UpdateRouteName] Error: $e');
      if (e is DioException) {
        final errBody = e.response?.data;
        return {
          'success': false,
          'statusCode': e.response?.statusCode,
          'message': _parseDioError(errBody),
        };
      }
      return {'success': false, 'message': 'Network error. Please try again.'};
    }
  }

  static Future<Map<String, dynamic>> fetchPermitStartingPoint(
      String routeId) async {
    try {
      final url = Uri.parse(
          '${HomeApiConstant.baseUrl}${HomeApiConstant.routePost}$routeId${HomeApiConstant.permitStartingPoint}');
      final response = await ApiClient.get(url);
      if (response.statusCode == 200 && response.data['status'] == true) {
        return {
          'success': true,
          'data': response.data['data'],
        };
      }
      return {'success': false, 'message': 'Failed to fetch starting point'};
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> createSubsequentPermit({
    required String routeId,
    required String startLocation,
    required String startLatitude,
    required String startLongitude,
    required String endLocation,
    required String endLatitude,
    required String endLongitude,
    required String permitText,
    File? permitFile,
  }) async {
    try {
      final url = Uri.parse(
          '${HomeApiConstant.baseUrl}${HomeApiConstant.routePost}$routeId${HomeApiConstant.routePermit}');

      Map<String, dynamic> dataMap = {
        'start_location': startLocation,
        'start_latitude': startLatitude,
        'start_longitude': startLongitude,
        'end_location': endLocation,
        'end_latitude': endLatitude,
        'end_longitude': endLongitude,
        'permit_text': permitText,
      };

      if (permitFile != null) {
        dataMap['permit_file'] = await MultipartFile.fromFile(
          permitFile.path,
          filename: permitFile.path.split('/').last,
        );
      }

      FormData formData = FormData.fromMap(dataMap);

      final response = await ApiClient.sendMultipartRequest(
        url,
        data: formData,
        method: 'POST',
      );

      final body =
          response.data is String ? jsonDecode(response.data) : response.data;

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': body['message'] ?? 'Permit created successfully',
        };
      } else {
        return {
          'success': false,
          'message': body['message'] ?? 'Failed to create permit',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }
}

// ─── Controller ──────────────────────────────────────────────────────────────
class HomeController extends GetxController {
  final RxInt currentPermitIndex = 1.obs;
  final RxBool isCreating = false.obs;
  final RxString errorMsg = ''.obs;

  // New State Variables
  final routeNameController = TextEditingController();
  final endPointController = TextEditingController();
  final RxString routeName = ''.obs;
  final RxString startLocation = ''.obs;
  final RxString startLat = ''.obs;
  final RxString startLng = ''.obs;

  final RxString endLocation = ''.obs;
  final RxString endLat = ''.obs;
  final RxString endLng = ''.obs;

  final RxString permitText = ''.obs;
  final Rx<File?> permitFile = Rx<File?>(null);
  final RxString activeAction = ''.obs;

  final RxList<DraftRouteModel> draftRoutes = <DraftRouteModel>[
    const DraftRouteModel(
        name: 'Downtown Loop', date: 'Apr 28, 2026', stops: 12),
    const DraftRouteModel(
        name: 'Warehouse District', date: 'Apr 25, 2026', stops: 8),
    const DraftRouteModel(
        name: 'North Side Delivery', date: 'Apr 22, 2026', stops: 15),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _loadDraft();
    routeName.value = routeNameController.text; // sync initial value
    _setupAutoSave();
  }

  void _setupAutoSave() {
    routeNameController.addListener(() {
      routeName.value = routeNameController.text;
      _saveDraft();
    });
    ever(startLocation, (_) => _saveDraft());
    ever(startLat, (_) => _saveDraft());
    ever(startLng, (_) => _saveDraft());
    ever(endLocation, (_) => _saveDraft());
    ever(endLat, (_) => _saveDraft());
    ever(endLng, (_) => _saveDraft());
    ever(permitText, (_) => _saveDraft());
    ever(permitFile, (_) => _saveDraft());
  }

  bool get isFormValid {
    final rName = routeName.value;
    final sLat = startLat.value;
    final sLng = startLng.value;
    final eLat = endLat.value;
    final eLng = endLng.value;
    final pText = permitText.value;
    final pFile = permitFile.value;

    return sLat.isNotEmpty &&
        sLng.isNotEmpty &&
        eLat.isNotEmpty &&
        eLng.isNotEmpty &&
        (pText.isNotEmpty || pFile != null);
  }

  void _saveDraft() {
    AuthService.saveDraftRouteData('home', {
      'routeName': routeNameController.text,
      'startLocation': startLocation.value,
      'startLat': startLat.value,
      'startLng': startLng.value,
      'endLocation': endLocation.value,
      'endLat': endLat.value,
      'endLng': endLng.value,
      'permitText': permitText.value,
      'permitFilePath': permitFile.value?.path,
    });
  }

  void _loadDraft() {
    final draft = AuthService.getDraftRouteData('home');
    if (draft != null) {
      routeNameController.text = draft['routeName'] ?? '';
      startLocation.value = draft['startLocation'] ?? '';
      startLat.value = draft['startLat'] ?? '';
      startLng.value = draft['startLng'] ?? '';
      endLocation.value = draft['endLocation'] ?? '';
      endLat.value = draft['endLat'] ?? '';
      endLng.value = draft['endLng'] ?? '';
      permitText.value = draft['permitText'] ?? '';

      final filePath = draft['permitFilePath'];
      if (filePath != null && filePath.toString().isNotEmpty) {
        final file = File(filePath.toString());
        if (file.existsSync()) {
          permitFile.value = file;
          activeAction.value = 'import';
        }
      }
    }
  }

  @override
  void onClose() {
    routeNameController.removeListener(_saveDraft);
    routeNameController.dispose();
    super.onClose();
  }

  void resetError() {
    errorMsg.value = '';
    isCreating.value = false;
  }

  void resetNewRouteData() {
    routeNameController.clear();
    startLocation.value = '';
    startLat.value = '';
    startLng.value = '';
    endLocation.value = '';
    endLat.value = '';
    endLng.value = '';
    permitText.value = '';
    permitFile.value = null;
    errorMsg.value = '';
    isCreating.value = false;
  }

  Future<void> submitCreateRoute() async {
    String name = routeNameController.text.trim();
    if (name.isEmpty) {
      int count = 0;
      if (Get.isRegistered<HistoryController>() && Get.find<HistoryController>().routes.isNotEmpty) {
        count = Get.find<HistoryController>().routes.length;
      } else {
        try {
          final url = Uri.parse('${HomeApiConstant.baseUrl}${HomeApiConstant.routePost}');
          final response = await ApiClient.get(url);
          if (response.statusCode == 200 || response.statusCode == 201) {
            count = response.data['count'] ?? (response.data['data'] as List?)?.length ?? 0;
          }
        } catch (_) {}
      }
      name = (count + 1).toString().padLeft(3, '0');
    }
    if (startLat.value.isEmpty || startLng.value.isEmpty) {
      errorMsg.value = 'Start location is required';
      Get.snackbar('Error', errorMsg.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1));
      return;
    }
    if (endLat.value.isEmpty || endLng.value.isEmpty) {
      errorMsg.value = 'End location is required';
      Get.snackbar('Error', errorMsg.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1));
      return;
    }
    if (permitText.value.isEmpty && permitFile.value == null) {
      errorMsg.value = 'Document is required';
      Get.snackbar('Error', errorMsg.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1));
      return;
    }

    isCreating.value = true;
    errorMsg.value = '';

    debugPrint('🔘 [HomeController] Submitting Create Route: $name');
    final result = await CreateRouteService.createRoute(
      name: name,
      startLocation:
          startLocation.value.isEmpty ? 'Unknown Start' : startLocation.value,
      startLatitude: startLat.value,
      startLongitude: startLng.value,
      endLocation:
          endLocation.value.isEmpty ? 'Unknown End' : endLocation.value,
      endLatitude: endLat.value,
      endLongitude: endLng.value,
      permitText: permitText.value,
      permitFile: permitFile.value,
    );

    isCreating.value = false;

    if (result['success'] == true) {
      final sLat = startLat.value;
      final sLng = startLng.value;
      
      AuthService.clearDraftRouteData('home');
      resetNewRouteData();
      Get.snackbar('Success', result['message'] ?? 'Route created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1));
      Get.toNamed(
        AppRoutes.confirmYourRoutes,
        arguments: {
          'routeName': result['name'],
          'routeId': result['id'],
          'startLat': sLat,
          'startLng': sLng,
        },
      );
    } else {
      String msg = result['message'] ?? 'Failed to create route';
      if (result['statusCode'] != null) {
        msg = 'Error ${result['statusCode']}: $msg';
      }
      errorMsg.value = msg;
      Get.snackbar('Error', msg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2));
    }
  }

  // Method to update route name
  Future<void> updateRouteName(int routeId, String newName) async {
    if (newName.trim().isEmpty) return;

    final result = await CreateRouteService.updateRouteName(
        routeId: routeId, newName: newName.trim());

    if (result['success'] == true) {
      Get.snackbar('Success', result['message'] ?? 'Route name updated',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP);
    } else {
      String msg = result['message'] ?? 'Failed to update route name';
      if (result['statusCode'] != null) {
        msg = 'Error ${result['statusCode']}: $msg';
      }
      Get.snackbar('Error', msg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4));
    }
  }
}
