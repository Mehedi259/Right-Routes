import 'package:flutter/material.dart';

import 'package:right_routes/global_widgets/custom_info_dialog.dart';

void showRouteNameDialog(BuildContext context) {
  showCustomInfoDialog(
    context: context,
    texts: [
      "Tap inside the text field and type in a name for your route or tap the mic icon to speak it in. This name will appear in your Route History for future use.",
    ],
  );
}
