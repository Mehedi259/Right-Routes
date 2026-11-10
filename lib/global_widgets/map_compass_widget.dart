import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:right_routes/utils/responsive_ext.dart';

/// Compact top-left map compass showing cardinal N/E/S/W orientation
/// matching the size of the top-right fullscreen enlarge button.
class MapCompassWidget extends StatelessWidget {
  final double bearingDegrees;
  final VoidCallback? onTap;

  const MapCompassWidget({
    super.key,
    required this.bearingDegrees,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double boxSize = context.r(42);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(context.r(4)),
      child: Container(
        width: boxSize,
        height: boxSize,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(context.r(4)),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
            ),
          ],
        ),
        child: Transform.rotate(
          angle: -bearingDegrees * math.pi / 180.0,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Cardinal letters N / S / E / W
              Positioned(
                top: 1,
                child: Text(
                  'N',
                  style: TextStyle(
                    color: const Color(0xFFF58842),
                    fontSize: context.sp(8.5),
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
              ),
              Positioned(
                bottom: 1,
                child: Text(
                  'S',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: context.sp(7.5),
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ),
              Positioned(
                right: 2.5,
                child: Text(
                  'E',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: context.sp(7.5),
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ),
              Positioned(
                left: 2,
                child: Text(
                  'W',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: context.sp(7.5),
                    fontWeight: FontWeight.w700,
                    height: 1.0,
                  ),
                ),
              ),
              // Center two-tone compass needle
              CustomPaint(
                size: Size(boxSize * 0.42, boxSize * 0.42),
                painter: _CompassNeedlePainter(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompassNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double cx = size.width / 2;
    final double cy = size.height / 2;
    final double halfW = size.width * 0.24;

    final Path northPath = Path()
      ..moveTo(cx, 0)
      ..lineTo(cx + halfW, cy)
      ..lineTo(cx - halfW, cy)
      ..close();

    final Path southPath = Path()
      ..moveTo(cx, size.height)
      ..lineTo(cx + halfW, cy)
      ..lineTo(cx - halfW, cy)
      ..close();

    canvas.drawPath(
      northPath,
      Paint()
        ..color = const Color(0xFFF58842)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      southPath,
      Paint()
        ..color = Colors.black45
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

