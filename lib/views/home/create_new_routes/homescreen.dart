import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:right_routes/views/home/home_all_widgets/dialog/dialog_map.dart';
import 'package:right_routes/views/home/home_all_widgets/dialog/dialog_document.dart';
import '../../../../global_widgets/custom_navbar.dart';
import '../../../../utils/assets_manager.dart';
import 'package:right_routes/views/home/create_new_routes/home_controller.dart';
import 'home_screen_map.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  late final HomeController _ctrl;
  final stt.SpeechToText _speech = stt.SpeechToText();

  @override
  void initState() {
    super.initState();
    _ctrl = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController(), permanent: true);
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = context.landscape;

    return Scaffold(
      backgroundColor: const Color(0xFF0B1129),
      extendBody: true,
      extendBodyBehindAppBar: true,
      bottomNavigationBar: const CustomNavbar(),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ImageManager.mapBackground),
                fit: BoxFit.cover,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: isLandscape
                  ? _buildLandscapeLayout(context)
                  : _buildPortraitLayout(context),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PORTRAIT LAYOUT
  // ─────────────────────────────────────────────────────────────
  Widget _buildPortraitLayout(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(
          top: context.h(20),
          left: context.w(20),
          right: context.w(20),
          bottom: context.h(20),
        ),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.s(15)),
                _buildTitle(context),
                SizedBox(height: context.h(6)),
                _buildPermitTitle(context),
                SizedBox(height: context.h(12)),

                // ── STEP 1: Choose one ──────────────────────────
                if (_ctrl.choiceMode.value == '' && !_ctrl.showMapSection.value)
                  _buildChooseSection(context),

                // ── Import Permit selected → show import actions ─
                if (_ctrl.choiceMode.value == 'import' && !_ctrl.showMapSection.value)
                  _buildImportSection(context),

                // ── Build Your Route selected → text field + NEXT ─
                if (_ctrl.choiceMode.value == 'build' && !_ctrl.showMapSection.value)
                  _buildBuildRouteSection(context),

                // ── Map section (after permit imported or NEXT pressed) ─
                if (_ctrl.showMapSection.value) ...[
                  _buildBackButton(context),
                  SizedBox(height: context.h(8)),
                  _buildStep1Label(context),
                  SizedBox(height: context.h(8)),
                  _buildEndPointField(context),
                  SizedBox(height: context.h(12)),
                  const HomeScreenMap(),
                  SizedBox(height: context.h(20)),
                  _buildContinueButton(context),
                ],

                SizedBox(height: context.h(50)),
              ],
            )),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // LANDSCAPE LAYOUT
  // ─────────────────────────────────────────────────────────────
  Widget _buildLandscapeLayout(BuildContext context) {
    final double padding = context.s(12);
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    final double availableHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        bottomInset -
        (padding * 2);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        padding,
        padding,
        padding,
        padding + bottomInset,
      ),
      child: SizedBox(
        height: availableHeight,
        child: Obx(() => Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── LEFT COLUMN ────────────────────────────────
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.40,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: context.s(10)),
                        _buildTitle(context),
                        SizedBox(height: context.s(6)),
                        _buildPermitTitle(context),
                        SizedBox(height: context.s(12)),

                        if (_ctrl.choiceMode.value == '' && !_ctrl.showMapSection.value)
                          _buildChooseSection(context),
                        if (_ctrl.choiceMode.value == 'import' && !_ctrl.showMapSection.value)
                          _buildImportSection(context),
                        if (_ctrl.choiceMode.value == 'build' && !_ctrl.showMapSection.value)
                          _buildBuildRouteSection(context),
                        if (_ctrl.showMapSection.value) ...[
                          _buildBackButton(context),
                          SizedBox(height: context.s(8)),
                          _buildStep1Label(context),
                          SizedBox(height: context.s(8)),
                          _buildEndPointField(context),
                          SizedBox(height: context.s(16)),
                          _buildContinueButton(context),
                        ],
                        SizedBox(height: context.s(80)),
                      ],
                    ),
                  ),
                ),

                SizedBox(width: context.w(10)),

                // ── RIGHT COLUMN — Map ─────────────────────────
                if (_ctrl.showMapSection.value)
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(context.r(12)),
                      child: const SizedBox(
                        width: double.infinity,
                        height: double.infinity,
                        child: HomeScreenMap(),
                      ),
                    ),
                  ),
              ],
            )),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // TITLE & PERMIT
  // ─────────────────────────────────────────────────────────────
  Widget _buildTitle(BuildContext context) {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          'CREATE ROUTE',
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(36),
            fontFamily: 'League Gothic',
            fontWeight: FontWeight.w400,
            letterSpacing: 2.0,
          ),
        ),
      ),
    );
  }

  Widget _buildPermitTitle(BuildContext context) {
    return Center(
      child: Text(
        'Permit 1',
        style: TextStyle(
          color: Colors.white,
          fontSize: context.sp(20),
          fontFamily: 'Lato',
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SECTION 1: "Choose one" with Import Permit + Build Your Route
  // ─────────────────────────────────────────────────────────────
  Widget _buildChooseSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Choose one:',
              style: TextStyle(
                color: Colors.white,
                fontSize: context.sp(17),
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: context.w(6)),
            GestureDetector(
              onTap: () => showPermitDialog(context),
              child: SvgPicture.asset(
                'assets/icons/Question-Box-gray.svg',
                width: context.w(22),
                height: context.h(22),
              ),
            ),
          ],
        ),
        SizedBox(height: context.h(14)),
        Row(
          children: [
            // Import Permit button
            Expanded(
              child: _buildChoiceButton(
                context,
                icon: Icons.file_download_outlined,
                label: 'Import\nPermit',
                onTap: () {
                  _ctrl.choiceMode.value = 'import';
                  _pickFile(); // directly open document picker
                },
              ),
            ),
            SizedBox(width: context.w(12)),
            // Build Your Route button
            Expanded(
              child: _buildChoiceButton(
                context,
                icon: Icons.edit_outlined,
                label: 'Build Your\nRoute',
                onTap: () {
                  _ctrl.choiceMode.value = 'build';
                },
              ),
            ),
          ],
        ),
        SizedBox(height: context.h(20)),
        // Map shown behind (dark background placeholder)
      ],
    );
  }

  Widget _buildChoiceButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: context.h(50),
        decoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: BorderRadius.circular(context.r(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: context.sp(20)),
            SizedBox(width: context.w(6)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.sp(13),
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }


  // ─────────────────────────────────────────────────────────────
  // SECTION: Import Permit (file picker)
  // ─────────────────────────────────────────────────────────────
  Widget _buildImportSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Choose one:',
              style: TextStyle(
                color: Colors.white,
                fontSize: context.sp(17),
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: context.w(6)),
            GestureDetector(
              onTap: () => showPermitDialog(context),
              child: SvgPicture.asset(
                'assets/icons/Question-Box-gray.svg',
                width: context.w(22),
                height: context.h(22),
              ),
            ),
          ],
        ),
        SizedBox(height: context.h(14)),
        Row(
          children: [
            Expanded(
              child: _buildChoiceButtonActive(
                context,
                icon: Icons.file_download_outlined,
                label: 'Import\nPermit',
                isActive: true,
                onTap: _pickFile, // allow re-triggering file picker
              ),
            ),
            SizedBox(width: context.w(12)),
            Expanded(
              child: _buildChoiceButtonActive(
                context,
                icon: Icons.edit_outlined,
                label: 'Build Your\nRoute',
                isActive: false,
                onTap: () => _ctrl.choiceMode.value = 'build',
              ),
            ),
          ],
        ),
        // Map placeholder removed
      ],
    );
  }

  Widget _buildChoiceButtonActive(BuildContext context,
      {required IconData icon,
      required String label,
      required bool isActive,
      VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: context.h(50),
        decoration: BoxDecoration(
          color: isActive ? AppColors.orange : AppColors.orange.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(context.r(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: context.sp(20)),
            SizedBox(width: context.w(6)),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.sp(13),
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SECTION: Build Your Route (text field + NEXT)
  // ─────────────────────────────────────────────────────────────
  Widget _buildBuildRouteSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Choose one:',
              style: TextStyle(
                color: Colors.white,
                fontSize: context.sp(17),
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: context.w(6)),
            GestureDetector(
              onTap: () => showPermitDialog(context),
              child: SvgPicture.asset(
                'assets/icons/Question-Box-gray.svg',
                width: context.w(22),
                height: context.h(22),
              ),
            ),
          ],
        ),
        SizedBox(height: context.h(14)),
        Row(
          children: [
            Expanded(
              child: _buildChoiceButtonActive(
                context,
                icon: Icons.file_download_outlined,
                label: 'Import\nPermit',
                isActive: false,
                onTap: () => _ctrl.choiceMode.value = 'import',
              ),
            ),
            SizedBox(width: context.w(12)),
            Expanded(
              child: _buildChoiceButtonActive(
                context,
                icon: Icons.edit_outlined,
                label: 'Build Your\nRoute',
                isActive: true,
              ),
            ),
          ],
        ),
        SizedBox(height: context.h(16)),

        // Directions text area
        Container(
          constraints: BoxConstraints(minHeight: context.h(160)),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(context.r(8)),
          ),
          child: TextField(
            controller: _ctrl.buildRouteTextController,
            onChanged: (v) => _ctrl.buildRouteText.value = v,
            maxLines: null,
            minLines: 7,
            decoration: InputDecoration(
              hintText:
                  'Example:\nIA-9 EB\nUS-18 SB\nIA-4 SB\nIA-3 EB\nUS-69 NB\nB62 at Quail Ave',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: context.sp(14),
                fontFamily: 'Lato',
                height: 1.6,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(context.s(14)),
            ),
            style: TextStyle(
              fontSize: context.sp(14),
              fontFamily: 'Lato',
              color: Colors.black,
              height: 1.6,
            ),
          ),
        ),
        SizedBox(height: context.h(16)),

        // NEXT button
        Center(
          child: Obx(() {
            final hasText = _ctrl.buildRouteText.value.trim().isNotEmpty;
            return CustomButton(
              text: 'NEXT',
              width: context.w(150),
              height: context.h(44),
              fontSize: context.sp(20),
              backgroundColor: hasText ? AppColors.orange : AppColors.medGray,
              borderRadius: 10,
              onPressed: hasText
                  ? () {
                      _ctrl.permitText.value =
                          _ctrl.buildRouteTextController.text.trim();
                      _ctrl.activeAction.value = 'edit';
                      _ctrl.showMapSection.value = true;
                    }
                  : null,
            );
          }),
        ),
        SizedBox(height: context.h(16)),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MAP SECTION WIDGETS
  // ─────────────────────────────────────────────────────────────
  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _ctrl.showMapSection.value = false;
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chevron_left, color: AppColors.orange, size: context.sp(20)),
          Text(
            'Back',
            style: TextStyle(
              color: AppColors.orange,
              fontSize: context.sp(15),
              fontFamily: 'Lato',
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1Label(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Set your Start & End Points:',
              style: TextStyle(
                color: Colors.white,
                fontSize: context.sp(17),
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(width: context.w(6)),
            Padding(
              padding: EdgeInsets.only(top: context.h(2)),
              child: GestureDetector(
                onTap: () => dialogMap(context),
                child: SvgPicture.asset(
                  'assets/icons/Question-Box-gray.svg',
                  width: context.w(22),
                  height: context.h(22),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEndPointField(BuildContext context) {
    return Container(
      height: context.h(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(context.r(6)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _ctrl.endPointController,
              decoration: InputDecoration(
                hintText: 'Type Starting point or move pin on map',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: context.sp(13),
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: context.w(12),
                  vertical: 0,
                ),
                isDense: true,
              ),
              style: TextStyle(
                fontSize: context.sp(14),
                fontFamily: 'Lato',
                color: Colors.black,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: context.w(6)),
            child: GestureDetector(
              onTap: () {
                _showMicDialog(context, title: 'Start Point (Voice)',
                    onDone: (text) {
                  if (text.isNotEmpty) {
                    _ctrl.endPointController.text = text;
                    Get.snackbar('Success', 'Start point updated from voice',
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                        snackPosition: SnackPosition.TOP,
                        duration: const Duration(seconds: 1));
                  }
                });
              },
              child: Container(
                width: context.w(26),
                height: context.h(26),
                decoration: BoxDecoration(
                  color: AppColors.orange,
                  borderRadius: BorderRadius.circular(context.r(6)),
                ),
                child: Icon(
                  Icons.mic_none,
                  color: AppColors.white,
                  size: context.sp(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    return Center(
      child: Obx(() {
        final bool isValid = _ctrl.isFormValid;
        return CustomButton(
          text: _ctrl.isCreating.value ? 'LOADING...' : 'CONTINUE',
          width: _ctrl.isCreating.value ? context.w(160) : context.w(150),
          height: context.h(50),
          fontSize: _ctrl.isCreating.value ? context.sp(22) : context.sp(26),
          backgroundColor: isValid ? AppColors.orange : AppColors.medGray,
          borderRadius: 13,
          onPressed: (_ctrl.isCreating.value || !isValid)
              ? null
              : () {
                  _ctrl.submitCreateRoute();
                },
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 2 LABEL & ACTION BUTTONS (Import section)
  // ─────────────────────────────────────────────────────────────
  // Action buttons and Step 2 label removed as requested.

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result != null && result.files.single.path != null) {
      _ctrl.permitFile.value = File(result.files.single.path!);
      _ctrl.permitText.value = '';
      _ctrl.activeAction.value = 'import';
      // After file picked, show the map section
      _ctrl.showMapSection.value = true;
      Get.snackbar('Success', 'File attached successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 1));
    }
  }



  void _showMicDialog(BuildContext context,
      {required String title, required Function(String) onDone}) {
    RxBool isListening = false.obs;
    RxString spokenText = ''.obs;

    Get.dialog(AlertDialog(
      backgroundColor: AppColors.darkGray,
      title: Text(title, style: const TextStyle(color: Colors.white)),
      content: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  spokenText.value.isEmpty
                      ? 'Tap mic and speak...'
                      : spokenText.value,
                  style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  if (!isListening.value) {
                    bool available = false;
                    try {
                      available = await _speech.initialize(
                        onStatus: (status) {
                          if (status == 'done' || status == 'notListening') {
                            isListening.value = false;
                          }
                        },
                        onError: (errorNotification) {
                          isListening.value = false;
                          if (errorNotification.errorMsg != 'error_no_match') {
                            Get.snackbar(
                                'Speech Error', errorNotification.errorMsg,
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                                duration: const Duration(seconds: 2));
                          }
                        },
                      );
                    } catch (e) {
                      debugPrint('Speech initialization error: $e');
                      Get.snackbar('Not Supported',
                          'Speech recognition is not available on this device.',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 2));
                      return;
                    }

                    if (available) {
                      isListening.value = true;
                      String baseText = spokenText.value;
                      if (baseText.isNotEmpty && !baseText.endsWith(' ')) {
                        baseText += ' ';
                      }
                      await Future.delayed(const Duration(milliseconds: 200));
                      _speech.listen(
                        onResult: (val) {
                          spokenText.value = baseText + val.recognizedWords;
                        },
                        listenFor: const Duration(seconds: 30),
                        pauseFor: const Duration(seconds: 3),
                      );
                    } else {
                      Get.snackbar('Error', 'Microphone permission denied',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                          duration: const Duration(seconds: 1));
                    }
                  } else {
                    isListening.value = false;
                    _speech.stop();
                  }
                },
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor:
                      isListening.value ? Colors.red : AppColors.orange,
                  child: Icon(
                      isListening.value ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 30),
                ),
              )
            ],
          )),
      actions: [
        TextButton(
            onPressed: () {
              _speech.stop();
              Get.back();
            },
            child:
                const Text('Cancel', style: TextStyle(color: Colors.white))),
        TextButton(
            onPressed: () {
              _speech.stop();
              Get.back();
              onDone(spokenText.value);
            },
            child: const Text('Done',
                style: TextStyle(color: AppColors.orange))),
      ],
    ));
  }

}
