import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/theme_constants.dart';

class RandomColorBackground extends StatefulWidget {
  @override
  _RandomColorBackgroundState createState() => _RandomColorBackgroundState();

  final Color setColor;

  RandomColorBackground({required this.setColor});

  static Color generateRandomVibrantColor() {
    final Random random = Random();

    // Generate a random hue between 0 and 360
    final double hue = random.nextDouble() * 360;

    final Color darkerVibrantColor = HSLColor.fromAHSL(1.0, hue, 1.0, 0.2).toColor();

    return darkerVibrantColor;
  }

}

class _RandomColorBackgroundState extends State<RandomColorBackground> {
  //Color color = RandomColorBackground.generateRandomVibrantColor();

  @override
  void initState() {
    super.initState();
    //generateRandomVibrantColor();
  }



  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

