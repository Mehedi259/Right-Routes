import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/core/constants/services/api_client.dart';
import 'package:right_routes/core/constants/api_config/home_api_constant/home_api_constant.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'team_manager.dart';

class TeamManagerColors {
  static const Color primaryOrange = Color(0xffF58842);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF1E1E1E);
  static const Color darkerBackground = Color(0xFF0F0F0F);
  static const Color borderColor = Color(0xFF3A3A3A);
}

class TeamManagerController extends GetxController {
  final searchController = TextEditingController();
  final emailInputController = TextEditingController();
  final emailInputFocusNode = FocusNode();

  var userList = <UserModel>[].obs;
  var filteredUserList = <UserModel>[].obs;
  var isAllSelected = false.obs;
  var isLoading = false.obs;
  var enrolledFilter = 'All'.obs;
  UserModel? editingUser;

  final userListScrollController = ScrollController();
  final emailInputScrollController = ScrollController();

  RxInt userLimit = 0.obs;
  RxInt currentUsers = 0.obs;
  RxInt remainingSlots = 0.obs;

  RxString planName = 'Loading...'.obs;
  RxString renewalDate = 'Loading...'.obs;
  RxString subscriptionId = 'Loading...'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSubscriptionPlan();
    fetchTeamMembers();



    emailInputController.addListener(() {
      _updateUserCount();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (emailInputScrollController.hasClients) {
        final maxScroll = emailInputScrollController.position.maxScrollExtent;
        if (maxScroll > 0) {
          emailInputScrollController.jumpTo(maxScroll * 0.2);
        }
      }
    });
  }

  Future<void> fetchSubscriptionPlan() async {
    try {
      final url = Uri.parse(HomeApiConstant.baseUrl + HomeApiConstant.currentPlan);
      final response = await ApiClient.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final responseData = response.data is String ? jsonDecode(response.data) : response.data;
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'];
          
          userLimit.value = data['team_limit'] ?? 0;
          planName.value = data['plan_name'] ?? 'Unknown Plan';
          subscriptionId.value = data['stripe_subscription_id'] ?? 'N/A';
          
          if (data['expires_at'] != null) {
            DateTime date = DateTime.parse(data['expires_at']);
            renewalDate.value = '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
          } else {
            renewalDate.value = 'N/A';
          }
          
          _updateUserCount();
        }
      }
    } catch (e) {
      debugPrint("Fetch subscription plan error: $e");
    }
  }

  Future<void> fetchTeamMembers() async {
    isLoading.value = true;
    try {
      String baseUrl = HomeApiConstant.baseUrl + HomeApiConstant.teamMembers;
      final url = Uri.parse(baseUrl);
      final response = await ApiClient.get(url, headers: {'Content-Type': 'application/json'});
      if (response.statusCode == 200) {
        final responseData = response.data is String ? jsonDecode(response.data) : response.data;
        if (responseData['success'] == true) {
          final List<dynamic> data = responseData['data'] ?? [];
          userList.value = data.map((e) {
            bool statusBool = e['status'] ?? false;
            return UserModel(
              id: e['id'],
              name: e['email'].toString().split('@')[0], 
              email: e['email'],
              status: statusBool ? UserStatus.active : UserStatus.pending,
              isSelected: false,
              isEnrolled: statusBool,
            );
          }).toList();
        }
      }
    } catch (e) {
      debugPrint("Fetch team members error: $e");
    } finally {
      filterUsers(searchController.text);
      _updateUserCount();
      isLoading.value = false;
    }
  }

  void filterUsers(String query) {
    var tempList = userList.toList();
    if (query.isNotEmpty) {
      tempList = tempList
          .where((user) =>
              user.name.toLowerCase().contains(query.toLowerCase()) ||
              user.email.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    if (enrolledFilter.value != 'All') {
      bool isTargetEnrolled = enrolledFilter.value == 'Yes';
      tempList = tempList
          .where((user) => user.isEnrolled == isTargetEnrolled)
          .toList();
    }
    filteredUserList.value = tempList;
    _updateSelectAllState();
  }

  void toggleUserSelection(int index) {
    filteredUserList[index].isSelected = !filteredUserList[index].isSelected;
    filteredUserList.refresh();
    _updateSelectAllState();
  }

  void toggleAllSelection() {
    isAllSelected.value = !isAllSelected.value;
    for (var user in filteredUserList) {
      user.isSelected = isAllSelected.value;
    }
    filteredUserList.refresh();
  }

  void _updateSelectAllState() {
    if (filteredUserList.isEmpty) {
      isAllSelected.value = false;
      return;
    }
    isAllSelected.value = filteredUserList.every((user) => user.isSelected);
  }

  void editUser(UserModel user) {
    editingUser = user;
    emailInputController.text = '${user.name}, ${user.email}';
    update(['add_button']);
    Get.snackbar('Edit Mode', 'User loaded in ADD/EDIT USERS box.',
        backgroundColor: TeamManagerColors.primaryOrange,
        colorText: Colors.white);
  }

  UserModel? parseSingleEntry(String entry) {
    try {
      final parts = entry.split(',').map((e) => e.trim()).toList();
      String name = '';
      String email = '';
      if (parts.length >= 2) {
        name = parts[0];
        email = parts[1];
      } else {
        email = parts[0];
        name = email.split('@')[0];
      }
      if (email.isEmpty || !email.contains('@')) return null;
      return UserModel(
          name: name,
          email: email,
          status: UserStatus.pending,
          isSelected: false);
    } catch (e) {
      return null;
    }
  }

  List<UserModel> parseMultipleEntries(String csvData) {
    try {
      final normalizedCsv = csvData.replaceAll('\r\n', '\n');
      final csvTable = const CsvToListConverter(eol: '\n').convert(normalizedCsv);
      final users = <UserModel>[];
      for (var row in csvTable) {
        if (row.isEmpty) continue;
        String name = '';
        String email = '';
        if (row.length >= 2) {
          name = row[0].toString().trim();
          email = row[1].toString().trim();
        } else if (row.length == 1) {
          email = row[0].toString().trim();
          name = email.split('@').first;
        }
        
        if (email.isNotEmpty && email.contains('@')) {
           users.add(UserModel(
               name: name, 
               email: email, 
               status: UserStatus.pending, 
               isSelected: false));
        }
      }
      return users;
    } catch (e) {
      return [];
    }
  }

  Future<void> addUserEmail() async {
    if (isLoading.value) return;
    
    final input = emailInputController.text.trim();
    if (input.isEmpty) {
      Get.snackbar('Error', 'Please enter user information',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (editingUser != null) {
      final updatedUser = parseSingleEntry(input);
      if (updatedUser == null) {
        Get.snackbar('Invalid Format', 'Use format: name, email@email.com',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      isLoading.value = true;
      try {
        final url = Uri.parse('${HomeApiConstant.baseUrl}${HomeApiConstant.teamMemberDetails}${editingUser!.id}/');
        final response = await ApiClient.patch(url,
          body: {
            'username': updatedUser.name.isNotEmpty ? updatedUser.name : updatedUser.email.split('@')[0],
            'email': updatedUser.email,
            'status': true
          },
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          Get.snackbar('Success', 'User updated and invited successfully',
              backgroundColor: Colors.green, colorText: Colors.white);
          fetchTeamMembers();
        } else {
          Get.snackbar('Error', 'Failed to update user',
              backgroundColor: Colors.red, colorText: Colors.white);
        }
      } catch (e) {
        debugPrint("Update user error: $e");
        Get.snackbar('Error', 'An error occurred while updating',
            backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        isLoading.value = false;
        emailInputController.clear();
        editingUser = null;
        update(['add_button']);
      }
      return;
    }

    final usersToAdd = parseMultipleEntries(input);
    if (usersToAdd.isEmpty) {
      final single = parseSingleEntry(input);
      if (single != null) usersToAdd.add(single);
    }

    if (usersToAdd.isEmpty) {
      Get.snackbar('Invalid Format', 'Use format: email@email.com',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (usersToAdd.length > remainingSlots.value) {
      Get.snackbar('Cannot Add', 'You only have ${remainingSlots.value} slots remaining.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    try {
      final url = Uri.parse(HomeApiConstant.baseUrl + HomeApiConstant.teamMultipleMembersAdd);
      List<Map<String, String>> inviteList = usersToAdd.map((u) => {
        'username': u.name.isNotEmpty ? u.name : u.email.split('@')[0],
        'email': u.email
      }).toList();

      final response = await ApiClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'invite_user': inviteList
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', '${usersToAdd.length} user(s) invited successfully',
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchTeamMembers();
      } else {
        Get.snackbar('Error', 'Failed to add users',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("Add user error: $e");
      Get.snackbar('Error', 'An error occurred',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
      emailInputController.clear();
    }
  }

  void importUsers() async {
    if (isLoading.value) return;

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      String? filePath = result.files.single.path;
      if (filePath == null) {
        Get.snackbar('Error', 'Could not access file',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      File file = File(filePath);
      String csvString = await file.readAsString();
      
      final users = parseMultipleEntries(csvString);
      if (users.isEmpty) {
        Get.snackbar('Error', 'No valid users found in CSV.',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }

      if (users.length > remainingSlots.value) {
        Get.snackbar('Cannot Import', 'You only have ${remainingSlots.value} slots remaining, but the CSV has ${users.length} users.',
            backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      
      isLoading.value = true;
      final url = Uri.parse(HomeApiConstant.baseUrl + HomeApiConstant.teamMultipleMembersAdd);
      List<Map<String, String>> inviteList = users.map((u) => {
        'username': u.name.isNotEmpty ? u.name : u.email.split('@')[0],
        'email': u.email
      }).toList();

      final response = await ApiClient.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'invite_user': inviteList
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', '${users.length} user(s) imported from CSV',
            backgroundColor: Colors.green, colorText: Colors.white);
        fetchTeamMembers();
      } else {
        Get.snackbar('Error', 'Failed to import users',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to parse CSV file.',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void _updateUserCount() {
    currentUsers.value = userList.length;
    remainingSlots.value = userLimit.value - currentUsers.value;
    update(['add_button']);
  }

  bool canAddUsers() {
    return remainingSlots.value > 0;
  }

  Color addButtonColor() {
    return canAddUsers() ? TeamManagerColors.primaryOrange : Colors.grey;
  }

  String get limitText {
    return '+${remainingSlots.value}';
  }

  Color get limitColor {
    return remainingSlots.value > 0 ? const Color(0xFF12A900) : Colors.red;
  }

  void cancelInput() {
    emailInputController.clear();
    editingUser = null;
    update(['add_button']);
  }

  void downloadSelected() {
    if (isLoading.value) return;
    
    final selected = filteredUserList.where((u) => u.isSelected).toList();
    if (selected.isEmpty) {
      Get.snackbar('Warning', 'Please select at least one user to download',
          backgroundColor: TeamManagerColors.primaryOrange,
          colorText: Colors.white);
      return;
    }

    try {
      List<List<dynamic>> csvData = [
        ['Name', 'Email', 'Status']
      ];
      for (var user in selected) {
        csvData.add([user.name, user.email, getStatusText(user.status)]);
      }

      String csvString = const ListToCsvConverter().convert(csvData);

      debugPrint('--- GENERATED CSV FOR EMAIL ---');
      debugPrint(csvString);
      debugPrint('-------------------------------');

      CustomDialogs.showDownloadSuccess();
    } catch (e) {
      Get.snackbar('Error', 'Failed to generate CSV: $e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void cancelSelected() {
    searchController.clear();
    enrolledFilter.value = 'All';
    emailInputController.clear();
    editingUser = null;

    for (var user in userList) {
      user.isSelected = false;
    }
    isAllSelected.value = false;

    filterUsers('');
  }

  void resendSelected() {
    if (isLoading.value) return;

    final selected = filteredUserList.where((u) => u.isSelected).toList();
    if (selected.isEmpty) {
      Get.snackbar('Warning', 'Please select at least one user',
          backgroundColor: TeamManagerColors.primaryOrange,
          colorText: Colors.white);
      return;
    }
    final resendUsers =
        selected.where((u) => u.status == UserStatus.resend).toList();
    if (resendUsers.isEmpty) {
      Get.snackbar('Warning', 'Selected users do not have "Resend" status',
          backgroundColor: TeamManagerColors.primaryOrange,
          colorText: Colors.white);
      return;
    }
    for (var user in resendUsers) {
      CustomDialogs.showResendConfirmation(
        userName: user.name,
        userEmail: user.email,
        onConfirm: () {
          user.status = UserStatus.pending;
          user.isSelected = false;
          Get.back();
        },
      );
    }
    filteredUserList.refresh();
    _updateSelectAllState();
  }

  void removeSelected() {
    if (isLoading.value) return;

    final selected = filteredUserList.where((u) => u.isSelected).toList();
    if (selected.isEmpty) {
      Get.snackbar('Warning', 'Please select at least one user to remove',
          backgroundColor: TeamManagerColors.primaryOrange,
          colorText: Colors.white);
      return;
    }
    CustomDialogs.showRemoveConfirmation(onConfirm: () async {
      Get.back();
      isLoading.value = true;
      try {
        List<int> memberIds = [];
        for (var user in selected) {
          if (user.id != null) {
            memberIds.add(user.id!);
          }
        }

        if (memberIds.isNotEmpty) {
          final url = Uri.parse('${HomeApiConstant.baseUrl}${HomeApiConstant.removeTeamMember}');
          final response = await ApiClient.post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'team_member_ids': memberIds,
            }),
          );

          if (response.statusCode == 200 || response.statusCode == 201) {
            Get.snackbar('Success', 'Selected members removed successfully',
                backgroundColor: Colors.green, colorText: Colors.white);
          } else {
            Get.snackbar('Error', 'Failed to remove members',
                backgroundColor: Colors.red, colorText: Colors.white);
          }
        }
      } catch (e) {
        debugPrint("Remove member error: $e");
        Get.snackbar('Error', 'Failed to remove some members',
            backgroundColor: Colors.red, colorText: Colors.white);
      } finally {
        isLoading.value = false;
        fetchTeamMembers();
      }
    });
  }

  String getStatusText(UserStatus status) {
    switch (status) {
      case UserStatus.active:
        return 'Active';
      case UserStatus.pending:
        return 'Pending';
      case UserStatus.resend:
        return 'Resend';
      case UserStatus.remove:
        return 'Remove';
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    emailInputController.dispose();
    emailInputFocusNode.dispose();
    userListScrollController.dispose();
    emailInputScrollController.dispose();
    super.onClose();
  }
}

class UserModel {
  final int? id;
  final String name;
  final String email;
  UserStatus status;
  bool isSelected;
  bool isEnrolled;

  UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.status,
    this.isSelected = false,
    this.isEnrolled = false,
  });
}

enum UserStatus { active, pending, resend, remove }
