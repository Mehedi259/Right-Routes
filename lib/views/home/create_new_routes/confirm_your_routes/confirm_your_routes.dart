import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:right_routes/global_widgets/custom_buttons.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/assets_manager.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/views/home/create_new_routes/confirm_your_routes/confirm_controller.dart';
import 'package:right_routes/core/constants/api_config/home_api_constant/home_api_constant.dart';
import 'package:right_routes/views/home/create_new_routes/confirm_your_routes/create_route_after_confirm_route/after_confirm_controller.dart';
import 'package:right_routes/views/home/create_new_routes/home_controller.dart';
import 'package:right_routes/global_widgets/custom_info_dialog.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../drive_screen/drive_screen.dart';

// ─── Map Style ────────────────────────────────────────────────────────────────
const _kMapTilerKey = 'N2YLLvhtmoQzVSf9VfF9';
const _kMapStyle =
    // 'https://api.maptiler.com/maps/openstreetmap/style.json?key=$_kMapTilerKey';
    'https://api.maptiler.com/maps/streets-v2/style.json?key=$_kMapTilerKey';

class _C {
  static const darkBg = Color(0xFF0D1B2A);
  static const green = Color(0xFF2E7D32);
  static const actionGreen = Color(0xFF2E5D2E);
  static const blueBadge = Color(0xFF2C4A7A);
  static const borderSubtle = Color(0xFF2C3E50);
  static const wpGreen = Color(0xFF2E7D32);
  static const wpRed = Color(0xFFCC2222);
}

class EditConfirmStartYourRoute extends StatefulWidget {
  const EditConfirmStartYourRoute({super.key});

  @override
  State<EditConfirmStartYourRoute> createState() => _EditConfirmStartYourRouteState();
}

class _EditConfirmStartYourRouteState extends State<EditConfirmStartYourRoute> {
  final stt.SpeechToText _speech = stt.SpeechToText();

  final ConfirmRouteController controller = Get.put(ConfirmRouteController());
  final HomeController homeCtrl = Get.isRegistered<HomeController>()
      ? Get.find<HomeController>()
      : Get.put<HomeController>(HomeController(), permanent: true);

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = context.landscape;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(ImageManager.mapBackground),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: isLandscape
                ? _buildLandscapeLayout(context)
                : _buildPortraitLayout(context),
          ),
          bottomNavigationBar: const CustomNavbar(),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // PORTRAIT LAYOUT
  // ─────────────────────────────────────────────────────────────
  Widget _buildPortraitLayout(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: context.h(16)),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              if (controller.currentRouteId != null) {
                await controller.fetchRouteDetails(controller.currentRouteId!);
              }
            },
            color: AppColors.orange,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: context.w(20)),
                      child: _buildTitle(context),
                    ),
                  ),
                  SizedBox(height: context.h(14)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(15)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel(context, 'Route Name'),
                        SizedBox(height: context.h(6)),
                        _buildRouteNameField(context),
                        SizedBox(height: context.h(14)),
                      ],
                    ),
                  ),
                  _buildMapSection(context, height: context.h(260)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.w(15)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: context.h(12)),
                        _buildActionButtonsRow(context),
                        SizedBox(height: context.h(16)),
                        _buildWaypointsSectionHeader(context),
                        SizedBox(height: context.h(8)),
                        _buildPermitRow(context),
                        SizedBox(height: context.h(14)),
                        _buildAddPermitButton(context),
                        SizedBox(height: context.h(14)),
                        _buildTotalMilesText(context),
                        SizedBox(height: context.h(18)),
                        _buildBottomButtons(context),
                        SizedBox(height: context.h(24)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildLandscapeLayout(BuildContext context) {
    final double padding = context.s(12);
    final double availableHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        MediaQuery.of(context).padding.bottom -
        (padding * 2);

    return Padding(
      padding: EdgeInsets.all(padding),
      child: SizedBox(
        height: availableHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.42,
              child: RefreshIndicator(
                onRefresh: () async {
                  if (controller.currentRouteId != null) {
                    await controller
                        .fetchRouteDetails(controller.currentRouteId!);
                  }
                },
                color: AppColors.orange,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics()),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(child: _buildTitle(context)),
                      SizedBox(height: context.h(14)),
                      _sectionLabel(context, 'Route Name'),
                      SizedBox(height: context.h(6)),
                      _buildRouteNameField(context),
                      SizedBox(height: context.h(16)),
                      _buildActionButtonsRow(context),
                      SizedBox(height: context.h(16)),
                      _buildWaypointsSectionHeader(context),
                      SizedBox(height: context.h(8)),
                      _buildPermitRow(context),
                      SizedBox(height: context.h(14)),
                      _buildAddPermitButton(context),
                      SizedBox(height: context.h(14)),
                      _buildTotalMilesText(context),
                      SizedBox(height: context.h(18)),
                      _buildBottomButtons(context),
                      SizedBox(height: context.h(20)),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: context.w(10)),

            // ── RIGHT COLUMN — Map fills ALL remaining height ────
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(context.r(12)),
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: _buildMapSection(context, height: double.infinity),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SHARED WIDGETS
  // ─────────────────────────────────────────────────────────────

  Widget _buildTitle(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        'EDIT, SAVE, DRIVE ROUTE',
        style: TextStyle(
          color: AppColors.white,
          fontSize: context.sp(32),
          fontFamily: 'League Gothic',
          fontWeight: FontWeight.w400,
          letterSpacing: 1.50,
        ),
      ),
    );
  }

  Widget _buildPermitRow(BuildContext context) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(controller.editablePermits.length, (pIdx) {
          int permitNum = pIdx + 1;
          bool isLast = pIdx == controller.editablePermits.length - 1;
          final permit = controller.editablePermits[pIdx];

          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : context.h(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Permit $permitNum',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: context.sp(16),
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: context.w(8)),
                    GestureDetector(
                      onTap: () {
                        permit.isExpanded.value = !permit.isExpanded.value;
                      },
                      child: Container(
                        width: context.w(22),
                        height: context.h(22),
                        decoration: BoxDecoration(
                          color: AppColors.orange,
                          borderRadius: BorderRadius.circular(context.r(5)),
                        ),
                        child: Obx(() {
                          return Icon(
                              permit.isExpanded.value
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: context.sp(18));
                        }),
                      ),
                    ),
                  ],
                ),
                Obx(() {
                  if (permit.isExpanded.value) {
                    return Padding(
                      padding: EdgeInsets.only(top: context.h(10)),
                      child: _buildWaypointList(context, pIdx),
                    );
                  }
                  return const SizedBox.shrink();
                }),
              ],
            ),
          );
        }),
      );
    });
  }

  Widget _buildAddPermitButton(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () async {
          if (controller.currentRouteId != null) {
            Get.put(AfterConfirmController())
                .initSubsequentPermit(controller.currentRouteId!);
          }
          await Get.toNamed(
            AppRoutes.createRouteAfterConfirmRoute,
            arguments: {'routeId': controller.currentRouteId},
          );
          if (controller.currentRouteId != null) {
            controller.fetchRouteDetails(controller.currentRouteId!);
          }
        },
        child: Obx(() => Container(
              padding: EdgeInsets.symmetric(
                  horizontal: context.w(8), vertical: context.h(3)),
              decoration: BoxDecoration(
                color: AppColors.orange,
                borderRadius: BorderRadius.circular(context.r(7)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.black.withValues(alpha: 0.25),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                'Add Permit ${homeCtrl.currentPermitIndex.value + 1}',
                style: TextStyle(
                    color: AppColors.white,
                    fontSize: context.sp(14),
                    fontFamily: 'Lato',
                    letterSpacing: 0.5,
                    fontWeight: FontWeight.w900),
              ),
            )),
      ),
    );
  }

  Widget _buildTotalMilesText(BuildContext context) {
    return Obx(() => Text(
          'Total miles: ${controller.distance.value.replaceAll(' miles', '')}',
          style: TextStyle(
            color: AppColors.white,
            fontSize: context.sp(13),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w500,
          ),
        ));
  }

  Widget _buildMapSection(BuildContext context, {required double height}) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        children: [
          MapLibreMap(
            styleString: _kMapStyle,
            initialCameraPosition: CameraPosition(
              target: controller.currentLocation,
              zoom: controller.currentLocation.latitude == 39.8283 ? 4.0 : 11.0,
            ),
            onMapCreated: controller.onMapCreated,
            onStyleLoadedCallback: controller.onStyleLoaded,
            onCameraMove: controller.onCameraMove,
            onMapClick: (point, latLng) => controller.onMapClick(latLng),
            onMapLongClick: (point, latLng) =>
                controller.onMapLongClick(latLng),
            gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
            myLocationEnabled: true,
            myLocationTrackingMode: MyLocationTrackingMode.none,
            compassEnabled: true,
            rotateGesturesEnabled: true,
            scrollGesturesEnabled: true,
            tiltGesturesEnabled: true,
            zoomGesturesEnabled: true,
            doubleClickZoomEnabled: false,
            minMaxZoomPreference: const MinMaxZoomPreference(1, 20),
          ),
          Positioned(
            top: context.h(10),
            right: context.w(10),
            child: InkWell(
              onTap: () async {
                final originalController = controller.mapController;
                final currentCam = controller.mapController?.cameraPosition;
                
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FullScreenMap(
                      controller: controller,
                      initialCameraPosition: currentCam,
                    ),
                  ),
                );
                
                controller.mapController = originalController;
                await controller.onStyleLoaded();
              },
              child: Container(
                padding: EdgeInsets.all(context.r(8)),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(context.r(4)),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                    )
                  ],
                ),
                child: Icon(
                  Icons.fullscreen,
                  color: Colors.black87,
                  size: context.sp(26),
                ),
              ),
            ),
          ),
          Obx(() {
            if (!controller.isRouteLoading.value)
              return const SizedBox.shrink();
            return Positioned(
              bottom: context.h(10),
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: context.w(14), vertical: context.h(7)),
                  decoration: BoxDecoration(
                    color: AppColors.black.withValues(alpha: 0.54),
                    borderRadius: BorderRadius.circular(context.r(20)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: context.w(14),
                        height: context.h(14),
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.orange),
                      ),
                      SizedBox(width: context.w(8)),
                      Text(
                        'Calculating route…',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: context.sp(12),
                            fontFamily: 'Lato'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          Obx(() {
            if (!controller.isAddingPinMode.value)
              return const SizedBox.shrink();
            return Positioned(
              top: context.h(10),
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: context.w(14), vertical: context.h(6)),
                  decoration: BoxDecoration(
                    color: AppColors.orange.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(context.r(20)),
                  ),
                  child: Text(
                    'Tap anywhere on map to add pin',
                    style: TextStyle(
                        color: AppColors.white,
                        fontSize: context.sp(12),
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            );
          }),
          Obx(() {
            if (!controller.isDragging.value) return const SizedBox.shrink();
            return Positioned(
              top: context.h(10),
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: context.w(14), vertical: context.h(6)),
                  decoration: BoxDecoration(
                      color: AppColors.black.withValues(alpha: 0.54),
                      borderRadius: BorderRadius.circular(context.r(20))),
                  child: Text('Drag pin to reposition',
                      style: TextStyle(
                          color: AppColors.white,
                          fontSize: context.sp(12),
                          fontFamily: 'Lato')),
                ),
              ),
            );
          }),

        ],
      ),
    );
  }

  Widget _buildActionButtonsRow(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() => _actionBtn(
                  context,
                  controller.isAddingPinMode.value ? 'Tap Map' : 'Add Pin',
                  color: AppColors.orange,
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    controller.toggleAddPinMode();
                  },
                )),
            _actionBtn(
              context,
              'Update',
              color: _C.green,
              onTap: () {
                FocusScope.of(context).unfocus();
                controller.updateRoute();
              },
            ),
          ],
        ),
        _actionBtn(
          context,
          'Delete Pin',
          color: AppColors.orange,
          onTap: () {
            FocusScope.of(context).unfocus();
            controller.deleteSelectedMapPin();
          },
        ),
      ],
    );
  }

  Widget _buildWaypointsSectionHeader(BuildContext context) {
    return Row(
      children: [
        Text(
          'Add/Edit Waypoints',
          style: TextStyle(
            color: AppColors.white,
            fontSize: context.sp(15),
            fontFamily: 'Lato',
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(width: context.w(8)),
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            showWaypointsInfoDialog(context);
          },
          child: Padding(
            padding: EdgeInsets.only(top: context.h(2)),
            child: SvgPicture.asset(
              'assets/icons/Question-Box-gray.svg',
              width: context.w(24),
              height: context.h(24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaypointList(BuildContext context, int permitIndex) {
    return Obx(() {
      final permit = controller.editablePermits[permitIndex];
      if (permit.waypoints.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: context.h(12)),
          child: Text('No waypoints added',
              style: TextStyle(
                  color: AppColors.white.withValues(alpha: 0.4),
                  fontSize: context.sp(14),
                  fontFamily: 'Lato')),
        );
      }
      return Column(
        children: List.generate(permit.waypoints.length, (wpIdx) {
          if (wpIdx >= permit.waypointControllers.length) {
            return const SizedBox.shrink();
          }
          return Column(
            children: [
              _buildWaypointRow(controller, permitIndex, wpIdx, context),
              if (wpIdx < permit.waypoints.length - 1)
                _buildAddButton(controller, permitIndex, wpIdx, context),
            ],
          );
        }),
      );
    });
  }

  // Waypoint input fields match home_screen.dart's route name field styling:
  // height 33, radius 4, font 16, white background — for visual consistency.
  Widget _buildWaypointRow(
      ConfirmRouteController ctrl, int permitIndex, int wpIdx, BuildContext context) {
    return Obx(() {
      final permit = ctrl.editablePermits[permitIndex];
      if (wpIdx >= permit.waypoints.length ||
          wpIdx >= permit.waypointControllers.length) {
        return const SizedBox.shrink();
      }

      final isFirst = wpIdx == 0;
      final isSelected = ctrl.selectedPermitIndex.value == permitIndex && ctrl.selectedWaypointIndex.value == wpIdx;
      final isLast =
          wpIdx == permit.waypoints.length - 1 && permit.waypoints.length > 1;

      final Color bg =
          (isFirst || isLast) ? const Color(0xFF808080) : AppColors.white;
      final Color borderColor = isFirst
          ? _C.wpGreen
          : isLast
              ? _C.wpRed
              : Colors.transparent;
      final double borderWidth = borderColor == Colors.transparent ? 0 : 2.0;
      final Color textColor = isLast ? AppColors.white : AppColors.darkGray;

      return GestureDetector(
        onTap: () => ctrl.selectWaypoint(permitIndex, wpIdx),
        child: Padding(
          padding: EdgeInsets.only(bottom: context.h(2)),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(width: context.w(32)),
              Expanded(
                child: Container(
                  height: context.h(33),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(context.r(4)),
                    border: Border.all(color: borderColor, width: borderWidth),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: permit.waypointControllers[wpIdx],
                          onChanged: (v) => ctrl.updateWaypoint(permitIndex, wpIdx, v),
                          textAlignVertical: TextAlignVertical.center,
                          style: TextStyle(
                              color: textColor,
                              fontSize: context.sp(16),
                              fontFamily: 'Lato',
                              fontWeight: FontWeight.w400),
                          cursorColor:
                              isLast ? AppColors.white : AppColors.darkGray,
                          cursorHeight: context.h(16),
                          textInputAction: TextInputAction.done,
                          maxLines: 1,
                          onSubmitted: (_) => FocusScope.of(context).unfocus(),
                          decoration: InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: context.w(12), vertical: 0)),
                        ),
                      ),
                      if (!isFirst && !isLast) ...[
                        GestureDetector(
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            _showMicDialog(
                              context,
                              title: 'Speak Waypoint',
                              onDone: (text) {
                                ctrl.updateWaypoint(permitIndex, wpIdx, text);
                                permit.waypointControllers[wpIdx].text = text;
                              },
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.only(right: context.w(6)),
                            child: Container(
                              width: context.w(20),
                              height: context.h(20),
                              decoration: BoxDecoration(
                                  color: AppColors.orange,
                                  borderRadius:
                                      BorderRadius.circular(context.r(6))),
                              child: Icon(Icons.mic_none,
                                  color: AppColors.white, size: context.sp(18)),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (!isFirst && !isLast)
                Padding(
                  padding: EdgeInsets.only(left: context.w(8)),
                  child: GestureDetector(
                    onTap: () {
                      FocusScope.of(context).unfocus();
                      ctrl.deleteWaypointAt(permitIndex, wpIdx);
                    },
                    child: Icon(Icons.close,
                        color: AppColors.white, size: context.sp(24)),
                  ),
                )
              else
                SizedBox(width: context.w(32)),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAddButton(
      ConfirmRouteController ctrl, int permitIndex, int wpIdx, BuildContext context) {
    return Container(
      child: Row(
        children: [
          SizedBox(width: context.w(8)),
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              ctrl.addWaypointAt(permitIndex, wpIdx);
            },
            child: Container(
              width: context.w(18),
              height: context.w(18),
              decoration: BoxDecoration(
                color: const Color(0xFF6E6E6E),
                borderRadius: BorderRadius.circular(context.r(4)),
              ),
              child:
                  Icon(Icons.add, color: AppColors.white, size: context.sp(14)),
            ),
          ),
          SizedBox(width: context.w(6)),
          Container(
              width: context.w(27),
              height: context.h(1),
              color: const Color(0xFF6E6E6E)),
          SizedBox(width: context.w(32)),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'SAVE',
            backgroundColor: _C.green,
            textColor: AppColors.white,
            height: context.h(57),
            borderRadius: 10,
            onPressed: () {
              FocusScope.of(context).unfocus();
              // TODO: save action
            },
          ),
        ),
        SizedBox(width: context.w(12)),
        Expanded(
          child: CustomButton(
            text: 'DRIVE',
            backgroundColor: AppColors.orange,
            textColor: AppColors.white,
            height: context.h(57),
            borderRadius: 10,
            onPressed: () {
              FocusScope.of(context).unfocus();
              Get.to(
                () => const DriveRouteMap(),
                arguments: {
                  'routeId': controller.currentRouteId,
                  'routePoints': controller.waypointPositions,
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _sectionLabel(BuildContext context, String text) => Text(text,
      style: TextStyle(
          color: AppColors.white,
          fontSize: context.sp(18),
          fontFamily: 'Lato',
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1));

  // Matches home_screen.dart's _buildRouteNameField exactly:
  // height 33, radius 4, font 16, padding 12 horizontal, white bg,
  // mic button 20x20 with radius 6 and icon size 18.
  Widget _buildRouteNameField(BuildContext context) {
    return Container(
      width: double.infinity,
      height: context.h(33),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(context.r(4)),
        border: Border.all(color: _C.borderSubtle, width: context.s(1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.routeNameController,
              onChanged: controller.updateRouteName,
              textAlign: TextAlign.left,
              textAlignVertical: TextAlignVertical.center,
              style: TextStyle(
                  color: AppColors.darkGray,
                  fontSize: context.sp(16),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w500),
              cursorColor: AppColors.darkGray,
              cursorHeight: context.h(18),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => FocusScope.of(context).unfocus(),
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: context.w(12), vertical: 0),
                  hintText: 'Iowa Wind Tower',
                  hintStyle: TextStyle(
                      color: const Color(0xFF9AA8B2),
                      fontSize: context.sp(16),
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.w400),
                  isDense: true),
            ),
          ),
          GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              _showMicDialog(
                context,
                title: 'Speak Route Name',
                onDone: (text) {
                  controller.updateRouteName(text);
                },
              );
            },
            child: Padding(
              padding: EdgeInsets.only(right: context.w(6)),
              child: Container(
                width: context.w(20),
                height: context.h(20),
                decoration: BoxDecoration(
                    color: AppColors.orange,
                    borderRadius: BorderRadius.circular(context.r(6))),
                child: Icon(Icons.mic_none,
                    color: AppColors.white, size: context.sp(18)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _zoomBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: context.w(36),
        height: context.h(36),
        decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(context.r(5)),
            boxShadow: [
              BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.26),
                  blurRadius: 4,
                  offset: const Offset(0, 2))
            ]),
        child: Icon(icon,
            color: AppColors.black.withValues(alpha: 0.87),
            size: context.sp(22)),
      ),
    );
  }

  Widget _actionBtn(BuildContext context, String label,
      {required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: context.w(6), vertical: context.h(4)),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(context.r(7)),
            boxShadow: [
              BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.25),
                  blurRadius: 3,
                  offset: const Offset(0, 1))
            ]),
        child: Text(label,
            style: TextStyle(
                color: AppColors.white,
                fontSize: context.sp(14),
                fontWeight: FontWeight.w900,
                fontFamily: 'Lato',
                letterSpacing: 0.5)),
      ),
    );
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
                            Get.snackbar('Speech Error', errorNotification.errorMsg,
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

                      // Delay slightly to prevent error_client on some devices
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
                  child: Icon(isListening.value ? Icons.mic : Icons.mic_none,
                      color: Colors.white, size: 30),
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
            child: const Text('Cancel', style: TextStyle(color: Colors.white))),
        TextButton(
            onPressed: () {
              _speech.stop();
              Get.back();
              onDone(spokenText.value);
            },
            child:
                const Text('Done', style: TextStyle(color: AppColors.orange))),
      ],
    ));
  }
}

void showConfirmRouteInfoDialog(BuildContext context) {
  Widget buildRichText(String boldPart, String normalPart) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(12)),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: boldPart,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.sp(17),
                fontFamily: 'Lato',
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: normalPart,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.sp(17),
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  showCustomInfoDialog(
    context: context,
    icon: SvgPicture.asset('assets/icons/Vector-hand.svg',
        width: context.w(24), height: context.h(24)),
    customWidgets: [
      buildRichText('Adding new pins: ',
          'Tap the Add Pin button then tap anywhere on the map.'),
      buildRichText('Selecting pins: ',
          'Tap any pin on the map to select it. It will enlarge.'),
      buildRichText('Moving pins: ',
          'Press and hold a pin, then drag it to a new location.'),
      buildRichText(
          'Deleting pins: ', 'Select a pin, then tap the Delete Pin button.'),
      buildRichText('Manipulating the map: ',
          'Drag with one finger to pan. Pinch to zoom in/out.'),
      buildRichText(
          'Tap Update to refresh waypoints. Tap GO to start your route.', ''),
    ],
  );
}

void showWaypointsInfoDialog(BuildContext context) {
  showCustomInfoDialog(
    context: context,
    icon: Icon(Icons.location_on, color: AppColors.white, size: context.sp(24)),
    texts: const [
      'Tap inside a field to select a waypoint.',
      'Tap the "+" icon to add a field.',
      'Tap the "X" icon to remove that waypoint.',
      'Tap pins on map to select, then use Delete Pin button.',
      'Drag pins on the map to reposition them.',
      'Tap Update to refresh your route before clicking GO.',
    ],
  );
}

class FullScreenMap extends StatelessWidget {
  final ConfirmRouteController controller;
  final CameraPosition? initialCameraPosition;

  const FullScreenMap({
    super.key,
    required this.controller,
    this.initialCameraPosition,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Stack(
            children: [
              MapLibreMap(
                styleString: _kMapStyle,
                initialCameraPosition: initialCameraPosition ??
                    CameraPosition(
                      target: controller.currentLocation,
                      zoom: 11.0,
                    ),
                onMapCreated: controller.onMapCreated,
                onStyleLoadedCallback: controller.onStyleLoaded,
                onCameraMove: controller.onCameraMove,
                onMapClick: (point, latLng) => controller.onMapClick(latLng),
                onMapLongClick: (point, latLng) =>
                    controller.onMapLongClick(latLng),
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                  ),
                },
                myLocationEnabled: true,
                myLocationTrackingMode: MyLocationTrackingMode.none,
                compassEnabled: true,
                rotateGesturesEnabled: true,
                scrollGesturesEnabled: true,
                tiltGesturesEnabled: true,
                zoomGesturesEnabled: true,
                doubleClickZoomEnabled: false,
                minMaxZoomPreference: const MinMaxZoomPreference(1, 20),
              ),
              Positioned(
                top: context.h(10),
                right: context.w(10),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: EdgeInsets.all(context.r(8)),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(context.r(4)),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.fullscreen_exit,
                      color: Colors.black87,
                      size: context.sp(26),
                    ),
                  ),
                ),
              ),
              Obx(() {
                if (!controller.isRouteLoading.value) {
                  return const SizedBox.shrink();
                }
                return Positioned(
                  bottom: context.h(10),
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: context.w(14), vertical: context.h(7)),
                      decoration: BoxDecoration(
                        color: AppColors.black.withValues(alpha: 0.54),
                        borderRadius: BorderRadius.circular(context.r(20)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: context.w(14),
                            height: context.h(14),
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.orange),
                          ),
                          SizedBox(width: context.w(8)),
                          Text(
                            'Calculating route…',
                            style: TextStyle(
                                color: AppColors.white,
                                fontSize: context.sp(12),
                                fontFamily: 'Lato'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
              Obx(() {
                if (!controller.isAddingPinMode.value)
                  return const SizedBox.shrink();
                return Positioned(
                  top: context.h(10),
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: context.w(14), vertical: context.h(6)),
                      decoration: BoxDecoration(
                        color: AppColors.orange.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(context.r(20)),
                      ),
                      child: Text(
                        'Tap anywhere on map to add pin',
                        style: TextStyle(
                            color: AppColors.white,
                            fontSize: context.sp(12),
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              }),
              Obx(() {
                if (!controller.isDragging.value)
                  return const SizedBox.shrink();
                return Positioned(
                  top: context.h(10),
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: context.w(14), vertical: context.h(6)),
                      decoration: BoxDecoration(
                          color: AppColors.black.withValues(alpha: 0.54),
                          borderRadius: BorderRadius.circular(context.r(20))),
                      child: Text('Drag pin to reposition',
                          style: TextStyle(
                              color: AppColors.white,
                              fontSize: context.sp(12),
                              fontFamily: 'Lato')),
                    ),
                  ),
                );
              }),
              Positioned(
                bottom: context.h(60),
                left: context.w(15),
                right: context.w(15),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Obx(() =>
                            _actionBtn(
                              context,
                              controller.isAddingPinMode.value
                                  ? 'Tap Map'
                                  : 'Add Pin',
                              color: AppColors.orange,
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                controller.toggleAddPinMode();
                              },
                            )),
                        _actionBtn(
                          context,
                          'Update',
                          color: _C.green,
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            controller.updateRoute();
                            Navigator.pop(
                                context); // Optional: Pop when updating
                          },
                        ),
                      ],
                    ),
                    _actionBtn(
                      context,
                      'Delete Pin',
                      color: AppColors.orange,
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        controller.deleteSelectedMapPin();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(BuildContext context, String label,
      {required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: context.w(6), vertical: context.h(4)),
        decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(context.r(7)),
            boxShadow: [
              BoxShadow(
                  color: AppColors.black.withValues(alpha: 0.25),
                  blurRadius: 3,
                  offset: const Offset(0, 1))
            ]),
        child: Text(label,
            style: TextStyle(
                color: AppColors.white,
                fontSize: context.sp(14),
                fontWeight: FontWeight.w900,
                fontFamily: 'Lato',
                letterSpacing: 0.5)),
      ),
    );
  }
}
