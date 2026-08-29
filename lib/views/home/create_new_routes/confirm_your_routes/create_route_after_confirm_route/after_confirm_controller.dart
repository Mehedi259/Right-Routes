import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:right_routes/views/home/create_new_routes/home_controller.dart';
import 'package:right_routes/core/constants/services/auth_service.dart';

class AfterConfirmController extends GetxController {
  final RxBool isCreating = false.obs;
  final RxBool isFetchingLocation = false.obs;
  final RxString errorMsg = ''.obs;

  final RxString startLocation = ''.obs;
  final RxString startLat = ''.obs;
  final RxString startLng = ''.obs;

  final RxString endLocation = ''.obs;
  final RxString endLat = ''.obs;
  final RxString endLng = ''.obs;

  final RxString permitText = ''.obs;
  final Rx<File?> permitFile = Rx<File?>(null);
  final RxString activeAction = ''.obs;

  void resetError() {
    errorMsg.value = '';
    isCreating.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    _loadDraft();
    _setupAutoSave();
  }

  void _setupAutoSave() {
    ever(startLocation, (_) => _saveDraft());
    ever(startLat, (_) => _saveDraft());
    ever(startLng, (_) => _saveDraft());
    ever(endLocation, (_) => _saveDraft());
    ever(endLat, (_) => _saveDraft());
    ever(endLng, (_) => _saveDraft());
    ever(permitText, (_) => _saveDraft());
    ever(permitFile, (_) => _saveDraft());
  }

  void _saveDraft() {
    AuthService.saveDraftRouteData('after_confirm', {
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
    final draft = AuthService.getDraftRouteData('after_confirm');
    if (draft != null) {
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

  bool get isFormValid {
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

  Future<void> initSubsequentPermit(String routeId) async {
    endLocation.value = '';
    endLat.value = '';
    endLng.value = '';
    permitText.value = '';
    permitFile.value = null;
    activeAction.value = '';

    isFetchingLocation.value = true;
    final res = await CreateRouteService.fetchPermitStartingPoint(routeId);
    if (res['success']) {
      final data = res['data'];
      startLocation.value = data['start_location_name'] ?? '';
      startLat.value = data['start_latitude']?.toString() ?? '';
      startLng.value = data['start_longitude']?.toString() ?? '';
    }
    isFetchingLocation.value = false;
  }

  Future<bool> submitCreateSubsequentPermit(String routeId) async {
    if (endLat.value.isEmpty || endLng.value.isEmpty) {
      errorMsg.value = 'End location is required';
      Get.snackbar('Error', errorMsg.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1));
      return false;
    }
    if (permitText.value.isEmpty && permitFile.value == null) {
      errorMsg.value = 'Document is required';
      Get.snackbar('Error', errorMsg.value,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1));
      return false;
    }

    isCreating.value = true;
    errorMsg.value = '';

    final result = await CreateRouteService.createSubsequentPermit(
      routeId: routeId,
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
      AuthService.clearDraftRouteData('after_confirm');
      Get.snackbar(
          'Success', result['message'] ?? 'Permit created successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1));
      return true;
    } else {
      String msg = result['message'] ?? 'Failed to create permit';
      errorMsg.value = msg;
      Get.snackbar('Error', msg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 2));
      return false;
    }
  }
}
