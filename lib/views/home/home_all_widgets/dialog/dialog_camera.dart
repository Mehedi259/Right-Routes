import 'package:flutter/material.dart';

import 'package:right_routes/global_widgets/custom_info_dialog.dart';

void dialogCamera(BuildContext context) {
  showCustomInfoDialog(
    context: context,
    texts: [
      "You can take a photo of your permit and we will extract the directions from it..",
      "Saving the photo to this device will make it available to this app.",
    ],
  );
}
