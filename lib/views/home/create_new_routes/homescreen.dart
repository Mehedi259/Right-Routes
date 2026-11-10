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

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  late final HomeController _ctrl;

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() {
              if (_ctrl.isMapFullScreen.value) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: context.s(15)),
                  _buildTitle(context),
                  SizedBox(height: context.h(6)),
                  _buildPermitTitle(context),
                  SizedBox(height: context.h(12)),
                ],
              );
            }),

            // ── STEP 1: Choose one ──────────────────────────
            Obx(() {
              if (_ctrl.showMapSection.value) return const SizedBox.shrink();
              if (_ctrl.choiceMode.value == '') return _buildChooseSection(context);
              if (_ctrl.choiceMode.value == 'import') return _buildImportSection(context);
              if (_ctrl.choiceMode.value == 'build') return _buildBuildRouteSection(context);
              return const SizedBox.shrink();
            }),

            // ── Map section (after permit imported or NEXT pressed) ─
            Obx(() {
              if (!_ctrl.showMapSection.value) return const SizedBox.shrink();
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_ctrl.isMapFullScreen.value) ...[
                    _buildBackButton(context),
                    SizedBox(height: context.h(8)),
                    _buildStep1Label(context),
                    SizedBox(height: context.h(8)),
                    _buildEndPointField(context),
                    SizedBox(height: context.h(12)),
                  ],
                  const HomeScreenMap(),
                  if (!_ctrl.isMapFullScreen.value) ...[
                    SizedBox(height: context.h(20)),
                    _buildContinueButton(context),
                  ],
                ],
              );
            }),

            SizedBox(height: context.h(50)),
          ],
        ),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── LEFT COLUMN ────────────────────────────────
            Obx(() {
              if (_ctrl.isMapFullScreen.value && _ctrl.showMapSection.value) {
                return const SizedBox.shrink();
              }
              return SizedBox(
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
              );
            }),

            SizedBox(width: context.w(10)),

            // ── RIGHT COLUMN — Map ─────────────────────────
            Obx(() {
              if (!_ctrl.showMapSection.value) return const SizedBox.shrink();
              return Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(context.r(12)),
                  child: const SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: HomeScreenMap(),
                  ),
                ),
              );
            }),
          ],
        ),
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
      child: Obx(() => Text(
            'Permit ${_ctrl.currentPermitIndex.value}',
            style: TextStyle(
              color: const Color(0xFFF58842), // #F58842 orange per client request
              fontSize: context.sp(20),
              fontFamily: 'Lato',
              fontWeight: FontWeight.w700,
            ),
          )),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SECTION 1: "Choose one" with Import Permit + Build Your Route
  // ─────────────────────────────────────────────────────────────
  Widget _buildChooseHeaderRow(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
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
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            _ctrl.permitText.value = '';
            _ctrl.permitFile.value = null;
            _ctrl.activeAction.value = 'skip';
            _ctrl.showMapSection.value = true;
          },
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(4),
              vertical: context.h(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Skip',
                  style: TextStyle(
                    color: const Color(0xFFF58842),
                    fontSize: context.sp(16),
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: context.w(2)),
                Icon(
                  Icons.chevron_right,
                  color: const Color(0xFFF58842),
                  size: context.sp(18),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChoiceButtonsRow(BuildContext context, {String selectedMode = ''}) {
    final bool importActive = selectedMode == '' || selectedMode == 'import';
    final bool buildActive = selectedMode == '' || selectedMode == 'build';
    return Row(
      children: [
        Expanded(
          child: _buildChoiceButton(
            context,
            svgPath: SvgManager.createRouteImportWhite,
            iconSize: context.sp(25),
            label: 'IMPORT PERMIT',
            isActive: importActive,
            onTap: () {
              // Immediately switch out of Build Your Route so text area & NEXT disappear
              _ctrl.choiceMode.value = 'import';
              _showImportOptions(context);
            },
          ),
        ),
        SizedBox(width: context.w(12)),
        Expanded(
          child: _buildChoiceButton(
            context,
            svgPath: SvgManager.createRoutePencilWhite,
            iconSize: context.sp(22),
            label: 'BUILD YOUR ROUTE',
            isActive: buildActive,
            onTap: () {
              _ctrl.choiceMode.value = 'build';
            },
          ),
        ),
      ],
    );
  }

  Widget _buildChooseSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChooseHeaderRow(context),
        SizedBox(height: context.h(14)),
        _buildChoiceButtonsRow(context),
        SizedBox(height: context.h(20)),
      ],
    );
  }

  Widget _buildChoiceButton(
    BuildContext context, {
    required String svgPath,
    required double iconSize,
    required String label,
    bool isActive = true,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: context.h(48),
        padding: EdgeInsets.symmetric(horizontal: context.w(8)),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.orange
              : AppColors.orange.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(context.r(10)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgPath,
              width: iconSize,
              height: iconSize,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            SizedBox(width: context.w(6)),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label.toUpperCase(),
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.sp(24),
                    fontFamily: 'League Gothic',
                    fontWeight: FontWeight.w400,
                    letterSpacing: 1.2,
                  ),
                ),
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
        _buildChooseHeaderRow(context),
        SizedBox(height: context.h(14)),
        _buildChoiceButtonsRow(context, selectedMode: 'import'),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SECTION: Build Your Route (text field + NEXT)
  // ─────────────────────────────────────────────────────────────
  Widget _buildBuildRouteSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildChooseHeaderRow(context),
        SizedBox(height: context.h(14)),
        _buildChoiceButtonsRow(context, selectedMode: 'build'),
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

        // NEXT button (+1 pt font size)
        Center(
          child: Obx(() {
            final hasText = _ctrl.buildRouteText.value.trim().isNotEmpty;
            return CustomButton(
              text: 'NEXT',
              width: context.w(150),
              height: context.h(44),
              fontSize: context.sp(21),
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
            Obx(() => Text(
                  _ctrl.currentPermitIndex.value > 1
                      ? 'Set End Point for Permit ${_ctrl.currentPermitIndex.value}:'
                      : 'Set your Start & End Points:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.sp(17),
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.w700,
                  ),
                )),
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
            child: Obx(() {
              final bool pickingEnd =
                  _ctrl.currentPermitIndex.value > 1 ||
                  _ctrl.startLat.value.isNotEmpty;
              return TextField(
                controller: _ctrl.endPointController,
                decoration: InputDecoration(
                  hintText: pickingEnd
                      ? 'Type End point or move pin on map'
                      : 'Type Starting point or move pin on map',
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
              );
            }),
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
                  if (_ctrl.subsequentRouteId != null &&
                      _ctrl.currentPermitIndex.value > 1) {
                    _ctrl.submitCreateSubsequentPermit();
                  } else {
                    _ctrl.submitCreateRoute();
                  }
                },
        );
      }),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // STEP 2 LABEL & ACTION BUTTONS (Import section)
  // ─────────────────────────────────────────────────────────────
  // Action buttons and Step 2 label removed as requested.

  Future<void> _handleSelectedFile(File file) async {
    _ctrl.permitFile.value = file;
    _ctrl.permitText.value = '';
    _ctrl.activeAction.value = 'import';
    // After file picked, show the map section
    _ctrl.showMapSection.value = true;

    final fileName = file.path.split('/').last;
    final fileSizeBytes = file.existsSync() ? file.lengthSync() : 0;
    debugPrint('═══════════════════════════════════════════════════════════════');
    debugPrint('📎 [Permit File Attached] $fileName');
    debugPrint('📍 Local Path: ${file.path}');
    debugPrint('📊 File Size: ${(fileSizeBytes / 1024).toStringAsFixed(1)} KB');
    debugPrint('ℹ️ [Next Step] Confirm Start & End points on the map, then tap "CONTINUE" to upload to backend OCR.');
    debugPrint('═══════════════════════════════════════════════════════════════');

    Get.snackbar(
      'Permit Attached',
      'Attached $fileName. Set your Start & End points, then tap CONTINUE to process OCR.',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      );
      if (result != null && result.files.single.path != null) {
        await _handleSelectedFile(File(result.files.single.path!));
      }
    } catch (e) {
      debugPrint('File picker error: $e');
    }
  }

  Future<void> _pickFromCloud() async {
    try {
      // Allows browsing cloud services (Google Drive, iCloud Drive, etc.)
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );
      if (result != null && result.files.single.path != null) {
        await _handleSelectedFile(File(result.files.single.path!));
      }
    } catch (e) {
      debugPrint('Cloud picker error: $e');
    }
  }

  Future<void> _pickFromPhotos() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _handleSelectedFile(File(image.path));
      }
    } catch (e) {
      debugPrint('Photo picker error: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? photo = await picker.pickImage(source: ImageSource.camera);
      if (photo != null) {
        await _handleSelectedFile(File(photo.path));
      }
    } catch (e) {
      debugPrint('Camera picker error: $e');
    }
  }

  void _showImportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF333333),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(context.r(16))),
      ),
      builder: (ctx) {
        const brandOrange = Color(0xFFF58842);
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.w(16),
              vertical: context.h(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: context.w(40),
                    height: context.h(4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: context.h(16)),
                Text(
                  'Import Permit Location',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.sp(18),
                    fontFamily: 'Lato',
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: context.h(4)),
                Text(
                  'Select where your permit document is stored:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.sp(13),
                    fontFamily: 'Lato',
                  ),
                ),
                SizedBox(height: context.h(16)),
                _importOptionTile(
                  context: ctx,
                  icon: Icons.folder_open,
                  iconColor: brandOrange,
                  title: 'Browse Files',
                  subtitle: 'PDFs, Documents & Device Storage',
                  onTap: () {
                    Navigator.pop(ctx);
                    _ctrl.choiceMode.value = 'import';
                    _pickFile();
                  },
                ),
                _importOptionTile(
                  context: ctx,
                  icon: Icons.photo_library_outlined,
                  iconColor: brandOrange,
                  title: 'Browse Photos',
                  subtitle: 'Camera Roll & Photo Gallery',
                  onTap: () {
                    Navigator.pop(ctx);
                    _ctrl.choiceMode.value = 'import';
                    _pickFromPhotos();
                  },
                ),
                _importOptionTile(
                  context: ctx,
                  icon: Icons.cloud_outlined,
                  iconColor: brandOrange,
                  title: 'Google Drive / iCloud Drive',
                  subtitle: 'Cloud Storage & Shared Drives',
                  onTap: () {
                    Navigator.pop(ctx);
                    _ctrl.choiceMode.value = 'import';
                    _pickFromCloud();
                  },
                ),
                _importOptionTile(
                  context: ctx,
                  icon: Icons.camera_alt_outlined,
                  iconColor: brandOrange,
                  title: 'Scan with Camera',
                  subtitle: 'Take a photo of physical permit paper',
                  onTap: () {
                    Navigator.pop(ctx);
                    _ctrl.choiceMode.value = 'import';
                    _pickFromCamera();
                  },
                ),
                SizedBox(height: context.h(8)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _importOptionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: context.h(8)),
      decoration: BoxDecoration(
        color: const Color(0xFF606060),
        borderRadius: BorderRadius.circular(context.r(10)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: EdgeInsets.all(context.s(8)),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(context.r(8)),
          ),
          child: Icon(icon, color: iconColor, size: context.sp(24)),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(15),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white,
            fontSize: context.sp(12),
            fontFamily: 'Lato',
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.white70,
          size: context.sp(20),
        ),
      ),
    );
  }

}
