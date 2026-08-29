import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:flutter_svg/svg.dart';

class SubscriberAgreement extends StatelessWidget {
  const SubscriberAgreement({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Material(
        color: AppColors.darkGray,

        // Fullscreen Grey Overlay
        child: Stack(
          children: [
            SizedBox(height: 80.h),

            Positioned(
              right: 12.w,
              top: 40.h,
              child: GestureDetector(
                onTap: () => Get.back(),
                child: IconButton(
                  padding: EdgeInsets.zero, // removes extra padding
                  onPressed: () => Get.back(),

                  icon: SvgPicture.asset(
                    "assets/icons/Close-X-Circle.svg",
                    width: 30.w,
                    height: 30.h,
                  ),
                ),
              ),
            ),

            /// FOREGROUND CONTENT (LEFT SIDE)
            Positioned(
              left: 0.w,
              right: 0.w,
              top: 72.h,
              bottom: 0.h,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Title
                    Text(
                      "Subscriber Agreement",
                      style: TextStyle(
                        fontSize: 21.sp,
                        fontFamily: 'Lato',
                        fontWeight: FontWeight.w700,
                        height: 1.17.h,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10.h),

                    /// Divider
                    Divider(thickness: 1, color: AppColors.dividerColor),

                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 12.h),

                            /// Static Terms Content (Pixel-Perfect)
                            Text(
                              "Real content coming later. Lorem ipsum fervidus solaria nunc et varius pellentesque auctor. "
                              "Quisque narium vibora set ultricies finibus larentum quisque dronelis. Pellentesque habitant "
                              "morbi tristique senectus et netus et malesuada fames ac turpis egestas. Curabitur flaminia set "
                              "vero donis quavara et ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae.\n\n"
                              "Sed ornare quistum valeris ligula faucibus venenatis veli set amet. Integer pluvina morkal sapien "
                              "vitae justo bibendum, id iaculis urna semper. Mauris dignissim tortor ac vespara fringilla, in porta "
                              "leo mattis. Proin gladius urna non massa aliquet, sit amet gravida arcu tempor. Nam convallis tortor "
                              "a lorem mattis blandit in id leo.\n\n"
                              "Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; vivamus "
                              "quastra enim at felis cursus, eget tristique nulla posuere. Fusce lorem gristum dapibus semper orci, "
                              "non ornare nisl pulvinar sit amet. Aenean sed purus quis arcu sodales fermentum nantris vehicula. "
                              "Cras dictum velora sapien, quis aliquet nulla tempor ut.",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18.sp,
                                fontFamily: 'Lato',
                                fontWeight: FontWeight.w500,
                                height: 1.44.h,
                              ),
                            ),

                            SizedBox(height: 40.h),

                            /// =========== (Optional Dynamic Version - commented out) ===========
                            ///
                            /// EXAMPLE dynamic title:
                            /// Obx(() => Text(controller.dialogTitle.value, style: ...))
                            ///
                            /// EXAMPLE dynamic content:
                            /// Obx(() => Text(controller.dialogContent.value, style: ...))
                            ///
                            /// ================================================================
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
