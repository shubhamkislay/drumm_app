import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ArticleDrummButton extends StatelessWidget {
  ArticleDrummButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Vibrate.feedback(FeedbackType.success);
      },
      child: Container(
        height: 32,
        width: 32,
        padding: EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: DrummTheme.primarySelectedItemColor(context).withAlpha(5),
          borderRadius: BorderRadius.circular(24)
        ),
        child: Image.asset('images/audio-waves.png',
            color: DrummTheme.primaryTextColor(context),
            fit: BoxFit.contain),
      ),
    );
  }
}


class ArticleDrummButtonLoading extends StatelessWidget {

  ArticleDrummButtonLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 32,
      width: 32,
      decoration: BoxDecoration(
          color: DrummTheme.primaryItemBackground(context),
          borderRadius: BorderRadius.circular(24)
      ),
    );
  }
}
