import 'package:flutter/material.dart';
import 'package:right_routes/utils/responsive_ext.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:right_routes/utils/colors.dart';

void showCustomInfoDialog({
  required BuildContext context,
  Widget? icon,
  List<String>? texts,
  List<Widget>? customWidgets,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.only(left: context.w(20), right: context.w(20)),
        child: Container(
          padding: EdgeInsets.only(left: context.w(15), right: context.w(15), top: context.w(12), bottom: context.w(12)),
          decoration: BoxDecoration(
            color: AppColors.medGray,
            borderRadius: BorderRadius.circular(context.r(12)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: icon != null
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                children: [
                  /// Left Icon (passed dynamically)
                  if (icon != null) icon,

                  /// Close button
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: SvgPicture.asset(
                      "assets/icons/Close-X-Circle.svg",
                      height: context.h(24),
                      width: context.w(24),
                    ),
                  ),
                ],
              ),
              if (icon != null)
                SizedBox(height: context.h(16))
              else
                SizedBox(height: context.h(8)),

              /// -------- DYNAMIC TEXT CONTENT --------
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: customWidgets ??
                        (texts ?? []).map((text) {
                          return Padding(
                            padding: EdgeInsets.only(bottom: context.h(12)),
                            child: Text(
                              text,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: context.sp(17),
                                fontFamily: 'Lato',
                                height: 1.55,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
