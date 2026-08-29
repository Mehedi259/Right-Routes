import 'package:flutter/material.dart';

/// ============================================================
/// Responsive Extension on BuildContext
/// ============================================================
/// shortestSide use kore — portrait & landscape a same size
///
/// USAGE:
///   context.sp(16)  → font
///   context.s(24)   → icon / square
///   context.w(200)  → width
///   context.h(32)   → height
///   context.r(8)    → radius
///   context.isLandscape → bool
/// ============================================================

extension ResponsiveExt on BuildContext {
  // base design width (Figma canvas)
  static const double _base = 375.0;

  double get _scale =>
      (MediaQuery.of(this).size.shortestSide / _base).clamp(0.75, 1.4);

  double sp(double size) => size * _scale; // font
  double s(double size) => size * _scale;  // square / icon
  double w(double size) => size * _scale;  // width
  double h(double size) => size * _scale;  // height
  double r(double size) => size * _scale;  // radius

  bool get landscape {
    final size = MediaQuery.of(this).size;
    return size.width > size.height;
  }
}
