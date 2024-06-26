import 'package:countertop_drawer/feat_canvas/widgets/custom_rect.dart';
import 'package:flutter/material.dart';

class CanvasPainter extends CustomPainter {
  final List<CustomRect> rectangles;
  final CustomRect? currentRectangle;
  final CustomRect? movingRectangle;

  CanvasPainter(this.rectangles, this.currentRectangle, this.movingRectangle);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0;

    for (var rect in rectangles) {
      if (rect != movingRectangle) {
        canvas.drawRect(rect.toRect(), paint);
        _drawSizeText(canvas, rect);
      }
    }

    if (currentRectangle != null) {
      canvas.drawRect(currentRectangle!.toRect(), paint);
      _drawSizeText(canvas, currentRectangle!);
    }

    if (movingRectangle != null) {
      paint.color = Colors.red.withOpacity(0.5);
      canvas.drawRect(movingRectangle!.toRect(), paint);
      _drawSizeText(canvas, movingRectangle!);
    }
  }

  void _drawSizeText(Canvas canvas, CustomRect rect) {
    final textWidth = rect.width.toStringAsFixed(2);
    final textHeight = rect.height.toStringAsFixed(2);

    final textSpanWidth = TextSpan(
      text: 'W: $textWidth',
      style: const TextStyle(
        fontSize: 12.0,
        color: Colors.black,
      ),
    );

    final textSpanHeight = TextSpan(
      text: 'H: $textHeight',
      style: const TextStyle(
        fontSize: 12.0,
        color: Colors.black,
      ),
    );

    final textPainterWidth = TextPainter(
      text: textSpanWidth,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    final textPainterHeight = TextPainter(
      text: textSpanHeight,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    );

    textPainterWidth.layout();
    textPainterHeight.layout();

    final offset = Offset(rect.left + 5, rect.top - 15);

    textPainterWidth.paint(canvas, offset);
    textPainterHeight.paint(canvas, offset + const Offset(0, 15));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}