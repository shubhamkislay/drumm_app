import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:flutter/material.dart';

class StartDrummButton extends StatelessWidget {
  ArticleEntity article;
  VoidCallback onPressed;
  double ? size;
  String ? buttonText;
  Color ? background;
  StartDrummButton({super.key, required this.article, this.background, required this.onPressed, this.buttonText, this.size});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: (size!=null)?size:84,
            width: (size!=null)?size:84,
            padding: EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: (background!=null)?background:DrummTheme.drummPrimaryColor,
              borderRadius: BorderRadius.circular((size!=null)?size??84:84)
            ),
            child: Image.asset('images/audio-waves.png',
                color: Colors.white,
                fit: BoxFit.contain),
          ),
          if(buttonText!=null)Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("$buttonText",style: TextStyle(color: Colors.white,fontFamily: DRUMM_FONT_FAMILY,fontWeight: FontWeight.bold),),
          )
        ],
      ),
    );
  }
}
