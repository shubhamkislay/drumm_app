import 'package:flutter/material.dart';
import 'package:drumm_app/theme/theme_constants.dart';

class DrummQuestionButton extends StatelessWidget {
  VoidCallback onPressed;
  String imageAsset;
  String label;
  double? height = 100;
  DrummQuestionButton({Key? key, required this.imageAsset, required this.label, required this.onPressed,this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Wrap(
        children: [
          Container(
            child: Container(
              alignment: Alignment.center,
              height: height,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(vertical: 12,horizontal: 12),
              decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    Colors.indigo,
                    Colors.blue.shade700,
                    Colors.lightBlue,
                  ]),
                  borderRadius: BorderRadius.circular(24)
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.asset(
                    color: Colors.white,
                    width: 16,
                    imageAsset,
                    height: 16,
                  ),
                  const SizedBox(width: 8,),
                  Text(label,style: const TextStyle(color: Colors.white,fontFamily: APP_FONT_BOLD),softWrap: true,overflow: TextOverflow.ellipsis,)
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
