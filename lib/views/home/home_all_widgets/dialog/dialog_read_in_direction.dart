import 'package:flutter/material.dart';

import 'package:right_routes/global_widgets/custom_info_dialog.dart';

void dialogReadInDirection(BuildContext context) {
  showCustomInfoDialog(
    context: context,
    texts: [
      "You can use your device's microphone to read in the directions from your permit.",
    ],
  );
}
