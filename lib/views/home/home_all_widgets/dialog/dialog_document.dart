import 'package:flutter/material.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:right_routes/global_widgets/custom_info_dialog.dart';

void showPermitDialog(BuildContext context) {
  Widget buildParagraph(String text, {String? boldPrefix}) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.h(12)),
      child: Text.rich(
        TextSpan(
          children: [
            if (boldPrefix != null)
              TextSpan(
                text: boldPrefix,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: context.sp(16),
                  fontFamily: 'Lato',
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                ),
              ),
            TextSpan(
              text: text,
              style: TextStyle(
                color: Colors.white,
                fontSize: context.sp(16),
                fontFamily: 'Lato',
                fontWeight: FontWeight.w400,
                height: 1.5,
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
      buildParagraph(
        "There are two ways to input directions: Import a PDF of the permit or type in directions. You can type in your own route independent of what's shown on the permit.",
      ),
      buildParagraph(
        " Tap IMPORT PERMIT to pop up an import dialog. Browse to the PDF of the permit and tap to import. A success message will appear indicating the permit has been imported. Tap NEXT to continue.",
        boldPrefix: "Import:",
      ),
      buildParagraph(
        " Tap BUILD YOUR ROUTE to pop up a text field. Tap inside the field to open you device's keyboard. Type in your directions or copy and paste from the permit. Make sure each waypoint is on its own line or separated by a comma.",
        boldPrefix: "Type:",
      ),
      buildParagraph(
        "Typing the State abbreviation with highway number and compass direction (such as SB) should be enough for the app to process.",
      ),
      buildParagraph(
        "If you just want to place your own waypoint pins on the map without typing in any directions, type anything in the text field and tap NEXT.",
      ),
    ],
  );
}
