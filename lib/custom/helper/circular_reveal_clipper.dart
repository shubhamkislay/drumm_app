import 'dart:math';

import 'package:flutter/material.dart';

class CircleRevealClipper extends CustomClipper<Path> {
  final double fraction;

  CircleRevealClipper({this.fraction = 0.0});

  @override
  Path getClip(Size size) {
    var path = Path();
    path.addOval(
      Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 1.1),
          radius: fraction * size.height),
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    // TODO: implement shouldReclip
    return true;
  }
}
