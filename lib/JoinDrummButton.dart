import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class JoinDrummButton extends StatelessWidget {
  CardSwiperController? controller;
  JoinDrummButton({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //Vibrate.feedback(FeedbackType.impact);
        controller?.swipeRight();
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42),
            border: Border.all(
                color: Colors.grey.shade800,
                width: 2.5)),
        child: Container(
          padding: const EdgeInsets.all(18),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade900,
                  spreadRadius: 2,
                  blurRadius: 4),
            ],
            gradient: LinearGradient(colors: [
              Colors.indigo,
              Colors.blue.shade700,
              Colors.lightBlue,
            ]),
          ),
          child: Image.asset(
            'images/audio-waves.png',
            height: 38,
            color: Colors.white,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
