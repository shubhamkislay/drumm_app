import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

class StartDrummButton extends StatelessWidget {
  ArticleEntity article;
  VoidCallback onPressed;
  String ? buttonText;
  Color ? background;
  StartDrummButton({super.key, required this.article, this.background, required this.onPressed, this.buttonText});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 84,
            width: 84,
            padding: EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: (background!=null)?background:DrummTheme.drummPrimaryColor,
              borderRadius: BorderRadius.circular(84)
            ),
            child: Image.asset('images/audio-waves.png',
                color: Colors.white,
                fit: BoxFit.contain),
          ),
          if(buttonText!=null)Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("$buttonText"),
          )
        ],
      ),
    );
  }
}
