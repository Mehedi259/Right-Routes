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
      'The green S (Start) point default position is your current location.',
      'Tap the full-screen mode button at the top right in the map to expand your view if desired.',
      'Move the map to reposition where the S point will be set. It should be near your permit\'s starting point.',
      'Tap CONFIRM START to set it.',
      'The red E (End) point will appear.',
      'Move the map to position the E point near the end of this permit\'s route.',
      'Tap CONFIRM END to set it.',
      'Tap CONTINUE when done.',
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
