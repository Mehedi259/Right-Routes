import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:right_routes/core/constants/api_config/map_config.dart';
import 'package:right_routes/utils/colors.dart';
import 'drive_controller.dart';

class DriveRouteMap extends StatelessWidget {
  const DriveRouteMap({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final ctrl = Get.put(DriveController());

    return Scaffold(
      body: Stack(
        children: [
          // ═══════════════════════════════════════════════════════════
          // MAP
          // ═══════════════════════════════════════════════════════════
          Listener(
            onPointerDown: (_) {
              if (ctrl.isTracking.value) ctrl.isTracking.value = false;
            },
            child: MapLibreMap(
              styleString: MapConfig.mapStyle,
              initialCameraPosition: CameraPosition(
                target: LatLng(ctrl.vehicleLat.value, ctrl.vehicleLng.value),
                zoom: 14.0,
                tilt: 45.0,
              ),
              onMapCreated: (controller) async {
                ctrl.mapController = controller;
              },
              onStyleLoadedCallback: () async {
                final carImage = await ctrl.loadCarImage();
                await ctrl.mapController?.addImage('car-icon', carImage);

                await ctrl.loadWaypointIcon();
                await ctrl.addWaypointMarkers();
                await ctrl.drawRoute();
                await ctrl.ensureVehicleSymbol();
              },
              myLocationEnabled: false,
              compassEnabled: false,
              rotateGesturesEnabled: true,
              scrollGesturesEnabled: true,
              tiltGesturesEnabled: true,
              zoomGesturesEnabled: true,
            ),
          ),

          // ═══════════════════════════════════════════════════════════
          // ✅ FIXED GUIDANCE MESSAGE BAR
          // ═══════════════════════════════════════════════════════════
          Positioned(
            bottom: context.h(50),
            left: context.w(12),
            right: context.w(12),
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: context.w(360)),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: context.w(14),
                      vertical: context.h(10),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF606060), // Exact background color requested
                      borderRadius: BorderRadius.circular(context.r(8)),
                    ),
                    child: Obx(() => Text(
                          ctrl.currentGuidanceText.value,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: context.sp(17), // Same size as pop down messages
                            fontFamily: 'Lato',
                            fontWeight: FontWeight.bold,
                          ),
                        )),
                  ),
                ),
              ),
            ),
          ),

          // ═══════════════════════════════════════════════════════════
          // ✅ BOTTOM BUTTONS
          // ═══════════════════════════════════════════════════════════
          Positioned(
            bottom: context.h(15),
            left: context.w(12),
            right: context.w(12),
            child: SafeArea(
              top: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: context.w(360)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _voiceToggleBtn(context, ctrl),
                      Obx(() => _btn(
                            context,
                            ctrl.isDownloading.value
                                ? '${(ctrl.downloadProgress.value * 100).toInt()}%'
                                : 'Download',
                            ctrl.isDownloading.value ? () {} : ctrl.downloadOfflineMap,
                          )),
                      _btn(context, 'Recenter', ctrl.recenter),
                      _btn(context, 'Cancel', () {
                        ctrl.cancelDriveApi();
                        Get.back();
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomNavbar(),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ VOICE TOGGLE BUTTON (REPLACED BACK BUTTON)
  // ═══════════════════════════════════════════════════════════
  Widget _voiceToggleBtn(BuildContext context, DriveController ctrl) {
    return Expanded(
      child: GestureDetector(
        onTap: ctrl.toggleVoiceMute,
        child: Container(
          height: context.h(26),
          margin: EdgeInsets.symmetric(horizontal: context.w(3)),
          padding: EdgeInsets.symmetric(horizontal: context.w(4)),
          decoration: BoxDecoration(
            color: const Color(0xFFF28546), // Exact orange from image
            borderRadius: BorderRadius.circular(context.r(6)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Voice',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(13),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(width: context.w(4)),
              Obx(() {
                final bool isOn = !ctrl.isVoiceMuted.value;
                return Container(
                  width: context.w(26),
                  height: context.h(14),
                  decoration: BoxDecoration(
                    color: isOn ? const Color(0xFF4CAF50) : const Color(0xFF757575),
                    borderRadius: BorderRadius.circular(context.r(10)),
                  ),
                  padding: const EdgeInsets.all(1.5),
                  alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    width: context.w(11),
                    height: context.h(11),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 1,
                          offset: Offset(0, 1),
                        )
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════
  // ✅ BUTTON WIDGET
  // ═══════════════════════════════════════════════════════════
  Widget _btn(BuildContext context, String text, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: context.h(26), // Slim button matching Voice
          margin: EdgeInsets.symmetric(horizontal: context.w(3)),
          decoration: BoxDecoration(
            color: const Color(0xFFF28546), // Exact orange from image
            borderRadius: BorderRadius.circular(context.r(6)),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.sp(14),
                fontFamily: 'Lato',
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
