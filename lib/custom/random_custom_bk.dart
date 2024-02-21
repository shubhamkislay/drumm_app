import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/theme_constants.dart';

class RandomColorBackground extends StatefulWidget {
  @override
  _RandomColorBackgroundState createState() => _RandomColorBackgroundState();

  final Color setColor;

  RandomColorBackground({required this.setColor});

  static Color generateRandomVibrantColor(
      {double blueHueMin = 200,
        double blueHueMax = 250,
        double greenHueMin = 120,
        double greenHueMax = 180,
        double redHueMin = 0,
        double redHueMax = 30}) {
    final Random random = Random();
    double blueHue =
        blueHueMin + random.nextDouble() * (blueHueMax - blueHueMin);
    double greenHue =
        greenHueMin + random.nextDouble() * (greenHueMax - greenHueMin);
    double redHue =
        redHueMin + random.nextDouble() * (redHueMax - redHueMin);

    final Color blueColor = HSLColor.fromAHSL(1.0, blueHue, 1.0, 0.5).toColor();
    final Color greenColor =
    HSLColor.fromAHSL(1.0, greenHue, 1.0, 0.5).toColor();
    final Color redColor =
    HSLColor.fromAHSL(1.0, redHue, 1.0, 0.5).toColor();

    // Randomly choose between blue, green, and red
    int randomIndex = random.nextInt(3);
    if (randomIndex == 0)
      return blueColor;
    else if (randomIndex == 1)
      return greenColor;
    else
      return redColor;
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

