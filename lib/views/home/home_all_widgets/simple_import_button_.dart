import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:right_routes/utils/colors.dart';

class SimpleImportButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final VoidCallback? onTab;

  final String leftIcon; // SVG or PNG
  final String? rightIcon; // SVG only

  const SimpleImportButton({
    super.key,
    required this.text,
    required this.onTap,
    required this.leftIcon,
    this.rightIcon,
    this.onTab,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // BUTTON
          Container(
            height: 64.h,
            width: 296.w,
            decoration: BoxDecoration(
              color: AppColors.orange,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Padding(
              padding: EdgeInsets.only(left:25.w), //  Left padding
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start, // Left aligned
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // LEFT ICON - Fixed width for alignment
                  SizedBox(
                    width: 40.w, // Fixed width
                    child: Center(
                      child: _buildLeftIcon(),
                    ),
                  ),

                  SizedBox(width: 5.w), // Icon-text spacing

                  // TEXT
                  Text(
                    text,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24.sp,
                      fontFamily: 'Bebas Neue',
                      fontWeight: FontWeight.w400,
                      height: 1.17.h,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // TOP-RIGHT QUESTION ICON (optional)
          if (rightIcon != null || onTab != null)
            Positioned(
              top: 7.h,
              right: 7.w,
              child: GestureDetector(
                onTap: onTab,
                child: Center(
                  child: SvgPicture.asset("assets/icons/Question-Box-gray.svg"),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLeftIcon() {
    if (leftIcon.endsWith(".svg")) {
      return SvgPicture.asset(
        leftIcon,
        height: 40.h,
        width: 40.w,
        colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
      );
    } else {
      return Image.asset(leftIcon, height: 40.h, width: 40.w);
    }
  }
}




