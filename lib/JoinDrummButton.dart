import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import 'custom/constants/Constants.dart';

class JoinDrummButton extends StatelessWidget {
  CardSwiperController? controller;
  double? height;
  double? btnPadding;
  VoidCallback? onTap;
  JoinDrummButton({Key? key,  this.controller, this.height, this.btnPadding, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconHeight = height??38;
    double buttonPd = btnPadding??18;
    return GestureDetector(
      onTap: () {
        //Vibrate.feedback(FeedbackType.impact);
        controller?.swipeRight();
        try{
          onTap!();
        }catch(e){

        }
      },
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42),
            border: Border.all(
                color: Colors.grey.shade900,
                width: 2.5)),
        child: Container(
          padding:  EdgeInsets.all(buttonPd),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(42),
            boxShadow: [
              BoxShadow(
                  color: Colors.grey.shade900,
                  spreadRadius: 2,
                  blurRadius: 4),
            ],
            gradient: LinearGradient(colors: JOIN_COLOR
            ),
          ),
          child: Image.asset(
            'images/audio-waves.png',
            height: iconHeight,
            color: Colors.white,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
