import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import 'custom/constants/Constants.dart';

class ExploreNewsButton extends StatelessWidget {
  CardSwiperController? controller;
  ExploreNewsButton({Key? key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Vibrate.feedback(FeedbackType.selection);
        controller?.swipeLeft();
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42),
            border: Border.all(
                color: Colors.grey.shade900,
                width: 2.5)),
        child: Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade900,
                  spreadRadius: 2,
                  blurRadius: 4),
            ],
            gradient:  LinearGradient(
              colors: EXPLORE_COLOR,
            ),
          ),
          child: Image.asset(
            'images/google-earth.png',
            height: 42,
            color: Colors.white,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
