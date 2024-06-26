import 'package:flutter/material.dart';

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
