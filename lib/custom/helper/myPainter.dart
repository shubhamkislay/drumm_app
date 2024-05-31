import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
class MyPainter extends CustomPainter {
  MyPainter(this.svg, this.size);

  final SvgPicture? svg;
  final Size size;
  @override
  void paint(Canvas canvas, Size size) async {
    // svg.scaleCanvasToViewBox(canvas, Size(180.0, 180.0));
    // svg.clipCanvasToViewBox(canvas);
    // svg.draw(canvas, Rect.zero);

    PictureInfo pictureInfo =  await vg.loadPicture(SvgStringLoader(svg.toString()), null);

// You can draw the picture to a canvas:
    canvas.drawPicture(pictureInfo.picture);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}