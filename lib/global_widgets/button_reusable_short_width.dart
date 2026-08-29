import 'package:flutter/material.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';

class ButtonReusable extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  final double? width;
  final double? height;
  final double padding;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final double borderRadius;

  const ButtonReusable({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.padding = 10,
    this.backgroundColor = AppColors.orange,
    this.textColor = Colors.white,
    this.fontSize = 24,
    this.borderRadius = 10,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Opacity(
        opacity: onPressed == null ? 0.5 : 1.0,
        child: Container(
          width: width ?? context.w(234),
          constraints: BoxConstraints(
            minHeight: height ?? context.h(58),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: context.w(padding),
            vertical: context.h(padding * 0.6),
          ),
          decoration: ShapeDecoration(
            color: backgroundColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(context.r(borderRadius)),
            ),
          ),
          child: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                text,
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                  color: textColor,
                  fontSize: context.sp(fontSize),
                  fontFamily: 'League Gothic',
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
