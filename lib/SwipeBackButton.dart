import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class SwipeBackButton extends StatelessWidget {
  CardSwiperController? controller;
  SwipeBackButton({Key? key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Vibrate.feedback(FeedbackType.warning);
        controller?.undo();
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42),
            border: Border.all(
                color: Colors.grey.shade800,
                width: 2.25)),
        child: Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42),
            color: Colors.black.withOpacity(0.5),
          ),
          child: Image.asset(
            'images/turn-back.png',
            height: 16,
            color: Colors.white,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
