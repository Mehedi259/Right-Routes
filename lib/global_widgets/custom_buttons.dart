import 'package:flutter/material.dart';
import 'package:right_routes/utils/colors.dart';
import 'package:right_routes/utils/responsive_ext.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Color? textColor;
  final double? fontSize;
  final double? borderRadius;
  final Widget? icon;
  final bool isLoading;
  final bool showSpinner;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height,
    this.fontSize,
    this.backgroundColor = AppColors.orange,
    this.textColor = Colors.white,
    this.borderRadius = 10,
    this.icon,
    this.isLoading = false,
    this.showSpinner = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        constraints: BoxConstraints(
          minWidth: context.w(160),
          maxWidth: context.w(500),
          minHeight: context.h(45),
          maxHeight: context.h(90),
        ),
        width: width ?? double.infinity,
        height: height ?? context.h(57),
        padding: EdgeInsets.symmetric(
          horizontal: context.w(18),
          vertical: context.h(10),
        ),
        decoration: BoxDecoration(
          color: (isLoading && onPressed == null)
              ? (backgroundColor ?? AppColors.orange).withValues(alpha: 0.5)
              : (backgroundColor ?? AppColors.orange),
          borderRadius:
              BorderRadius.circular(context.r(borderRadius ?? 10)),
        ),
        child: Center(
          child: (isLoading && showSpinner)
              ? CircularProgressIndicator(
                  color: textColor ?? Colors.white,
                  strokeWidth: 2.5,
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      SizedBox(width: context.w(8)),
                    ],
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          text,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: TextStyle(
                            color: textColor ?? Colors.white,
                            fontSize: context.sp(fontSize ?? 24),
                            fontFamily: 'League Gothic',
                            height: 1.17,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
