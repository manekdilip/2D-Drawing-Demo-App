import 'package:countertop_drawer/utils/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CanvasWidget extends StatelessWidget {
  final List<CustomRect> rectangles;
  final String selectedOption;
  final CanvasController controller = Get.put(CanvasController());

  CanvasWidget(
      {super.key, required this.rectangles, required this.selectedOption}) {
    controller.rectangles.value = rectangles;
    controller.updateFixedWidth(selectedOption);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        controller.onPanStart(details);
      },
      onTapDown: (details) {
        controller.onTapDown(details);
      },
      onTapUp: (details) {
        controller.onTapUp(details);
      },
      onPanUpdate: (details) {
        controller.onPanUpdate(details);
      },
      onPanEnd: (details) {
        controller.onPanEnd(details);
      },
      onLongPress: () {
        controller.onLongPress();
      },
      child: Obx(
        () => CustomPaint(
          painter: CanvasPainter(
            controller.rectangles,
            controller.currentRectangle.value,
            controller.movingRectangle.value,
          ),
          child: Container(),
        ),
      ),
    );
  }
}

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

class CustomRect {
  double left;
  double top;
  double width;
  double height;

  static double fixedWidth = 25.5;

  CustomRect.fromLTWH(this.left, this.top, this.width, this.height);

  factory CustomRect.fromRect(Rect rect) {
    return CustomRect.fromLTWH(rect.left, rect.top, rect.width, rect.height);
  }

  Rect toRect() {
    return Rect.fromLTWH(left, top, width, height);
  }

  bool contains(Offset point) {
    return point.dx >= left &&
        point.dx <= left + width &&
        point.dy >= top &&
        point.dy <= top + height;
  }

  bool overlaps(CustomRect other) {
    return left < other.left + other.width &&
        left + width > other.left &&
        top < other.top + other.height &&
        top + height > other.top;
  }

  CustomRect translate(double dx, double dy) {
    return CustomRect.fromLTWH(left + dx, top + dy, width, height);
  }
}

class CanvasController extends GetxController {
  var rectangles = <CustomRect>[].obs;
  var movingRectangle = Rx<CustomRect?>(null);
  var currentRectangle = Rx<CustomRect?>(null);
  var moveStartPoint = Rx<Offset?>(null);
  var resizeStartPoint = Rx<Offset?>(null);
  var startPoint = Rx<Offset?>(null);
  var isResizing = false.obs;

  void updateFixedWidth(String selectedOption) {
    if (selectedOption == AppString.newIsland) {
      CustomRect.fixedWidth = 100.0;
    } else if (selectedOption == AppString.newKitchenCounterTop) {
      CustomRect.fixedWidth = 200.0;
    }
  }

  bool isOverlapping(CustomRect rect, List<CustomRect> reacts) {
    for (var r in reacts) {
      if (r != rect && r.overlaps(rect)) {
        return true;
      }
    }
    return false;
  }

  void onPanStart(DragStartDetails details) {
    for (var rect in rectangles) {
      if (rect.contains(details.localPosition)) {
        movingRectangle.value = rect;
        moveStartPoint.value = details.localPosition;
        return;
      }
    }

    if (movingRectangle.value == null) {
      startPoint.value = details.localPosition;
      currentRectangle.value = CustomRect.fromLTWH(
        startPoint.value!.dx,
        startPoint.value!.dy,
        CustomRect.fixedWidth,
        0,
      );
    }
  }

  void onTapDown(TapDownDetails details) {
    for (var rect in rectangles) {
      if (rect.contains(details.localPosition)) {
        if (details.localPosition.dx - rect.left < 5 ||
            details.localPosition.dx - rect.left - rect.width > -5 ||
            details.localPosition.dy - rect.top < 5 ||
            details.localPosition.dy - rect.top - rect.height > -5) {
          showEditDialog(rect, () {});
        }
      }
    }
  }

  void onTapUp(TapUpDetails details) {
    for (var rect in rectangles) {
      if (rect.contains(details.localPosition)) {
        if (details.localPosition.dx - rect.left < 5 ||
            details.localPosition.dx - rect.left - rect.width > -5 ||
            details.localPosition.dy - rect.top < 5 ||
            details.localPosition.dy - rect.top - rect.height > -5) {
          showEditDialog(rect, () {});
        }
      }
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    if (movingRectangle.value != null) {
      if (isResizing.value) {
        double dx = details.localPosition.dx - resizeStartPoint.value!.dx;
        double dy = details.localPosition.dy - resizeStartPoint.value!.dy;

        if (resizeStartPoint.value!.dx <
            movingRectangle.value!.left + movingRectangle.value!.width / 2) {
          movingRectangle.value!.width += dx;
        } else {
          movingRectangle.value!.left += dx;
          movingRectangle.value!.width -= dx;
        }

        if (resizeStartPoint.value!.dy <
            movingRectangle.value!.top + movingRectangle.value!.height / 2) {
          movingRectangle.value!.height += dy;
        } else {
          movingRectangle.value!.top += dy;
          movingRectangle.value!.height -= dy;
        }

        resizeStartPoint.value = details.localPosition;
      } else {
        double dx = details.localPosition.dx - moveStartPoint.value!.dx;
        double dy = details.localPosition.dy - moveStartPoint.value!.dy;

        movingRectangle.value!.left += dx;
        movingRectangle.value!.top += dy;
        moveStartPoint.value = details.localPosition;

        if (isOverlapping(movingRectangle.value!, rectangles)) {
          movingRectangle.value!.left -= dx;
          movingRectangle.value!.top -= dy;
        }
      }
    } else {
      double width = CustomRect.fixedWidth;
      double height = details.localPosition.dy - startPoint.value!.dy;

      if (height < 0) {
        height = -height;
        currentRectangle.value = CustomRect.fromLTWH(
          startPoint.value!.dx,
          startPoint.value!.dy - height,
          width,
          height,
        );
      } else {
        currentRectangle.value = CustomRect.fromLTWH(
          startPoint.value!.dx,
          startPoint.value!.dy,
          width,
          height,
        );
      }

      if (isOverlapping(currentRectangle.value!, rectangles)) {
        currentRectangle.value = null;
      }
    }
  }

  void onPanEnd(DragEndDetails details) {
    if (movingRectangle.value == null) {
      if (currentRectangle.value != null) {
        rectangles.add(currentRectangle.value!);
      }

      currentRectangle.value = null;
      startPoint.value = null;
    }

    movingRectangle.value = null;
    isResizing.value = false;
  }

  void onLongPress() {
    for (var rect in rectangles) {
      if (rect.contains(Offset(
        movingRectangle.value!.left + movingRectangle.value!.width / 2,
        movingRectangle.value!.top + movingRectangle.value!.height / 2,
      ))) {
        movingRectangle.value = rect;
        resizeStartPoint.value = Offset(
          movingRectangle.value!.left + movingRectangle.value!.width / 2,
          movingRectangle.value!.top + movingRectangle.value!.height / 2,
        );
        isResizing.value = true;
      }
    }
  }

  void showEditDialog(CustomRect rect, VoidCallback onSave) {
    Get.dialog(
      AlertDialog(
        title: const Text(''),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: TextEditingController(text: rect.width.toString()),
              decoration: const InputDecoration(labelText: AppString.editRectangle),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                rect.width = double.parse(value);
              },
            ),
            TextField(
              controller: TextEditingController(text: rect.height.toString()),
              decoration: const InputDecoration(labelText: AppString.height),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                rect.height = double.parse(value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
            },
            child: const Text(AppString.cancel),
          ),
          TextButton(
            onPressed: () {
              onSave();
              Get.back();
            },
            child: const Text(AppString.save),
          ),
        ],
      ),
    );
  }
}
