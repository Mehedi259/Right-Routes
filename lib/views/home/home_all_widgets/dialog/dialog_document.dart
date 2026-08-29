import 'package:flutter/material.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:right_routes/global_widgets/custom_info_dialog.dart';

void showPermitDialog(BuildContext context) {
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
                height: 1.55,
              ),
            ),
            TextSpan(
              text: normalPart,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.sp(17),
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }

  showCustomInfoDialog(
    context: context,
    customWidgets: [
      buildRichText('Permit Import Options:', ''),
      buildRichText('Document icon: ', 'Tap to import a PDF of your permit. It needs to be on your device or cloud drive.'),
      buildRichText('Pencil icon: ', 'Tap to manually type in the waypoints from your permit. Each waypoint needs to be separated by a comma (,).'),
      buildRichText('Mic icon: ', 'Tap to read in your permit directions.'),
      buildRichText('Camera icon: ', 'Tap to take and import a photo of the directions page in your permit.'),
      buildRichText('When your Start/End points and placed and permit is imported, tap Continue.', ''),
    ],
  );
}
