import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class MapIconUtil {
  static Future<Uint8List> createMarkerImage(String text, Color bgColor, Color strokeColor) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    const double size = 50.0;
    const double strokeWidth = 4.0;

    // Draw stroke
    final Paint strokePaint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(const Offset(size / 2, size / 2), (size / 2) - (strokeWidth / 2), strokePaint);

    // Draw background
    final Paint bgPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(const Offset(size / 2, size / 2), (size / 2) - strokeWidth, bgPaint);

    // Draw text
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    textPainter.text = TextSpan(
      text: text,
      style: const TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.w900,
        color: Colors.white,
        fontFamily: 'Lato',
      ),
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size - textPainter.width) / 2,
        (size - textPainter.height) / 2,
      ),
    );

    final ui.Image image = await pictureRecorder.endRecording().toImage(size.toInt(), size.toInt());
    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return byteData!.buffer.asUint8List();
  }

  static Future<void> loadStartEndIcons(dynamic mapController) async {
    if (mapController == null) return;
    try {
      final startIcon = await createMarkerImage('S', const Color(0xFF1BA345), const Color(0xFFFFFFFF));
      await mapController.addImage('start-icon', startIcon);

      final endIcon = await createMarkerImage('E', const Color(0xFFFF0000), const Color(0xFFFFFFFF));
      await mapController.addImage('end-icon', endIcon);
    } catch (e) {
      debugPrint('Error loading start/end icons: $e');
    }
  }
}
