import 'package:flutter/material.dart';

import 'package:right_routes/global_widgets/custom_info_dialog.dart';

void dialogDirection(BuildContext context) {
  showCustomInfoDialog(
    context: context,
    texts: [
      "This option allows you to type in the directions from your permit using your device's keyboard.",
    ],
  );
}
