import 'package:countertop_drawer/feat_canvas/widgets/canvas_painter.dart';
import 'package:countertop_drawer/feat_canvas/widgets/custom_rect.dart';
import 'package:countertop_drawer/utils/app_strings.dart';
import 'package:flutter/material.dart';

class CanvasWidget extends StatefulWidget {
  final List<CustomRect> rectangles;
  final String selectedOption;

  const CanvasWidget(
      {super.key, required this.rectangles, required this.selectedOption});

  @override
  CanvasWidgetState createState() => CanvasWidgetState();
}

class CanvasWidgetState extends State<CanvasWidget> {
  CustomRect? movingRectangle;
  CustomRect? currentRectangle;
  Offset? moveStartPoint;
  Offset? resizeStartPoint;
  Offset? startPoint;
  bool isResizing = false;

  @override
  void initState() {
    super.initState();
    _updateFixedWidth();
  }

  @override
  void didUpdateWidget(CanvasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateFixedWidth();
  }

  void _updateFixedWidth() {
    if (widget.selectedOption == AppString.newIsland) {
      CustomRect.fixedWidth = 100.0;
    } else if (widget.selectedOption == AppString.newKitchenCounterTop) {
      CustomRect.fixedWidth = 200.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (details) {
        setState(() {
          for (var rect in widget.rectangles) {
            if (rect.contains(details.localPosition)) {
              movingRectangle = rect;
              moveStartPoint = details.localPosition;
              break;
            }
          }
          if (movingRectangle == null) {
            startPoint = details.localPosition;
            currentRectangle = CustomRect.fromLTWH(
              startPoint!.dx,
              startPoint!.dy,
              CustomRect.fixedWidth,
              0,
            );
          }
        });
      },
      onTapDown: (details) {
        setState(() {
          for (var rect in widget.rectangles) {
            if (rect.contains(details.localPosition)) {
              if (details.localPosition.dx - rect.left < 5 ||
                  details.localPosition.dx - rect.left - rect.width > -5 ||
                  details.localPosition.dy - rect.top < 5 ||
                  details.localPosition.dy - rect.top - rect.height > -5) {
                _showEditDialog(rect);
              }
            }
          }
        });
      },
      onTapUp: (details) {
        setState(() {
          for (var rect in widget.rectangles) {
            if (rect.contains(details.localPosition)) {
              if (details.localPosition.dx - rect.left < 5 ||
                  details.localPosition.dx - rect.left - rect.width > -5 ||
                  details.localPosition.dy - rect.top < 5 ||
                  details.localPosition.dy - rect.top - rect.height > -5) {
                _showEditDialog(rect);
              }
            }
          }
        });
      },
      onPanUpdate: (details) {
        setState(() {
          if (movingRectangle != null) {
            if (isResizing) {
              double dx = details.localPosition.dx - resizeStartPoint!.dx;
              double dy = details.localPosition.dy - resizeStartPoint!.dy;
              if (resizeStartPoint!.dx <
                  movingRectangle!.left + movingRectangle!.width / 2) {
                movingRectangle!.width += dx;
              } else {
                movingRectangle!.left += dx;
                movingRectangle!.width -= dx;
              }
              if (resizeStartPoint!.dy <
                  movingRectangle!.top + movingRectangle!.height / 2) {
                movingRectangle!.height += dy;
              } else {
                movingRectangle!.top += dy;
                movingRectangle!.height -= dy;
              }
              resizeStartPoint = details.localPosition;
            } else {
              double dx = details.localPosition.dx - moveStartPoint!.dx;
              double dy = details.localPosition.dy - moveStartPoint!.dy;
              movingRectangle!.left += dx;
              movingRectangle!.top += dy;
              moveStartPoint = details.localPosition;
              if (_isOverlapping(movingRectangle!, widget.rectangles)) {
                movingRectangle!.left -= dx;
                movingRectangle!.top -= dy;
              }
            }
          } else {
            double width = CustomRect.fixedWidth;
            double height = details.localPosition.dy - startPoint!.dy;
            if (height < 0) {
              height = -height;
              currentRectangle = CustomRect.fromLTWH(
                startPoint!.dx,
                startPoint!.dy - height,
                width,
                height,
              );
            } else {
              currentRectangle = CustomRect.fromLTWH(
                startPoint!.dx,
                startPoint!.dy,
                width,
                height,
              );
            }
            if (_isOverlapping(currentRectangle!, widget.rectangles)) {
              currentRectangle = null;
            }
          }
        });
      },
      onPanEnd: (details) {
        setState(() {
          if (movingRectangle == null) {
            if (currentRectangle != null) {
              widget.rectangles.add(currentRectangle!);
            }
            currentRectangle = null;
            startPoint = null;
          }
          movingRectangle = null;
          isResizing = false;
        });
      },
      onLongPress: () {
        setState(() {
          for (var rect in widget.rectangles) {
            if (rect.contains(Offset(
                movingRectangle!.left + movingRectangle!.width / 2,
                movingRectangle!.top + movingRectangle!.height / 2))) {
              movingRectangle = rect;
              resizeStartPoint = Offset(
                  movingRectangle!.left + movingRectangle!.width / 2,
                  movingRectangle!.top + movingRectangle!.height / 2);
              isResizing = true;
              break;
            }
          }
        });
      },
      child: CustomPaint(
        painter:
            CanvasPainter(widget.rectangles, currentRectangle, movingRectangle),
        child: Container(),
      ),
    );
  }

  bool _isOverlapping(CustomRect rect, List<CustomRect> reacts) {
    for (var r in reacts) {
      if (r != rect && r.overlaps(rect)) {
        return true;
      }
    }
    return false;
  }

  void _showEditDialog(CustomRect rect) {
    TextEditingController widthController =
        TextEditingController(text: rect.width.toString());
    TextEditingController heightController =
        TextEditingController(text: rect.height.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(AppString.editRectangleDimensions),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: widthController,
                decoration: const InputDecoration(labelText: AppString.width),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: heightController,
                decoration: const InputDecoration(labelText: AppString.height),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  rect.width = double.parse(widthController.text);
                  rect.height = double.parse(heightController.text);
                });
                Navigator.of(context).pop();
              },
              child: const Text(AppString.submit),
            ),
          ],
        );
      },
    );
  }
}
