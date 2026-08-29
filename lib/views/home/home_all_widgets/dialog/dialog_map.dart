import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:right_routes/global_widgets/custom_info_dialog.dart';

void dialogMap(BuildContext context) {
  showCustomInfoDialog(
    context: context,
    icon: Icon(
      Icons.location_on,
      color: Colors.white,
      size: 24.sp,
    ),
    texts: [
      'The green "S" (Start) point is your current location.',
      'The red "E" (End) point is your ending location for this permit.',
      'You will first see the S point. You can confirm it\'s location or move it closer to where you will be starting your permitted route.',
      'When tapping Confirm Start the E pin will appear. You can either type in, speak in or manually place this point at or near the end of your route for this permit.',
      'Pinch the map with two fingers to zoom out. Spread two fingers to zoom in. Move the map with one finger.',
      'Tap the full screen icon at top right to see a larger view of the map.',
      'The "S" and "E" points form the boundary into which the waypoints from your permit will fit between.',
    ],
  );
}

void dialogMapForSubsequentPermit(BuildContext context) {
  showCustomInfoDialog(
    context: context,
    icon: Icon(
      Icons.location_on,
      color: Colors.white,
      size: 24.sp,
    ),
    texts: [
      'The green "S" point is location of the previous permit\'s end point. DO NOT MOVE THIS POINT.',
      'Move the red "E" point near the ending location for this permit.',
    ],
  );
}
