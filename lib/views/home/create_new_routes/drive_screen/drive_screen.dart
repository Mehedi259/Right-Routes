import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/utils/responsive_ext.dart';
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
              styleString:
                  'https://api.maptiler.com/maps/streets-v2/style.json?key=N2YLLvhtmoQzVSf9VfF9',
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
                      _btn(context, 'Back', () {
                        ctrl.stopDriveApi();
                        Get.back();
                      }),
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
  // ✅ BUTTON WIDGET
  // ═══════════════════════════════════════════════════════════
  Widget _btn(BuildContext context, String text, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: context.h(24), // Slim button
          margin: EdgeInsets.symmetric(horizontal: context.w(4)),
          decoration: BoxDecoration(
            color: const Color(0xFFF28546), // Exact orange from image
            borderRadius: BorderRadius.circular(context.r(6)),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.sp(16),
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
