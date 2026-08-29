import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:right_routes/utils/responsive_ext.dart';

// ✅ FIX: File renamed mentally to custom_toggle_button.dart (typo: troggle → toggle)
// ✅ FIX: Example/test classes removed — শুধু production widget রাখা হয়েছে

// ============================================================
// RESPONSIVE RULES (context-based, see responsive_ext.dart)
// ============================================================
// context.w(n)   → horizontal dimension (width, horizontal padding/margin)
// context.h(n)   → vertical dimension (height, vertical padding/margin)
// context.sp(n)  → font size ONLY
// context.r(n)   → border radius ONLY
// context.s(n)   → icon / square / generic scale
// Note: `width`/`height` are still accepted as explicit overrides from the
// caller (already scaled by the caller via context.w/h) — the fallback
// defaults and all internal spacing/icon sizes below are scaled here so the
// thumb, padding, shadow, and icons stay proportional to whatever size is
// ultimately used.
// ============================================================

class CustomToggleSwitchAdvanced extends StatelessWidget {
  final RxBool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? thumbColor;
  final double? width;
  final double? height;
  final Duration? duration;
  final Widget? activeIcon;
  final Widget? inactiveIcon;
  final String? activeSvgPath;
  final String? inactiveSvgPath;
  final Color? svgColor;
  final bool showShadow;

  const CustomToggleSwitchAdvanced({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.width,
    this.height,
    this.duration,
    this.activeIcon,
    this.inactiveIcon,
    this.activeSvgPath,
    this.inactiveSvgPath,
    this.svgColor,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        final double trackWidth = width ?? context.w(60);
        final double trackHeight = height ?? context.h(32);
        final double thumbInsetH = context.w(2);
        final double thumbInsetV = context.h(2);
        final double thumbSize = trackHeight - context.h(4);

        return GestureDetector(
          onTap: () {
            if (onChanged != null) {
              value.value = !value.value;
              onChanged!(value.value);
            }
          },
          child: AnimatedContainer(
            duration: duration ?? const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: trackWidth,
            height: trackHeight,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(trackHeight / 2),
              color: value.value
                  ? (activeColor ?? const Color(0xFFFF8C42))
                  : (inactiveColor ?? Colors.grey.withValues(alpha: 0.3)),
            ),
            child: Stack(
              children: [
                AnimatedPositioned(
                  duration: duration ?? const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  left: value.value
                      ? trackWidth - trackHeight + thumbInsetH
                      : thumbInsetH,
                  top: thumbInsetV,
                  child: Container(
                    width: thumbSize,
                    height: thumbSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: thumbColor ?? Colors.white,
                      boxShadow: showShadow
                          ? [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: context.r(4),
                                offset: Offset(0, context.h(2)),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) =>
                            ScaleTransition(scale: animation, child: child),
                        child: _buildIcon(context),
                      ),
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

  Widget _buildIcon(BuildContext context) {
    if (value.value && activeSvgPath != null) {
      return SvgPicture.asset(
        activeSvgPath!,
        key: const ValueKey('active_svg'),
        width: context.w(20),
        height: context.h(20),
        colorFilter: ColorFilter.mode(
          svgColor ?? const Color(0xFFFF8C42),
          BlendMode.srcIn,
        ),
      );
    }

    if (!value.value && inactiveSvgPath != null) {
      return SvgPicture.asset(
        inactiveSvgPath!,
        key: const ValueKey('inactive_svg'),
        width: context.w(16),
        height: context.h(16),
        colorFilter: ColorFilter.mode(
          svgColor ?? Colors.grey,
          BlendMode.srcIn,
        ),
      );
    }

    if (value.value && activeIcon != null) return activeIcon!;
    if (!value.value && inactiveIcon != null) return inactiveIcon!;

    return const SizedBox.shrink();
  }
}

// ════════════════════════════════════════════════════════════════
// ToggleController — reusable across screens
// ════════════════════════════════════════════════════════════════
class ToggleController extends GetxController {
  var isEnabled = false.obs;
  var useTouchId = false.obs;
}
