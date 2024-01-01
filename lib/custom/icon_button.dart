import 'package:flutter/material.dart';
import 'package:drumm_app/theme/theme_constants.dart';

class IconLabelButton extends StatelessWidget {
  VoidCallback onPressed;
  String imageAsset;
  String label;
  double? height = 100;
  IconLabelButton({Key? key, required this.imageAsset, required this.label, required this.onPressed,this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Wrap(
        children: [
          Container(
            alignment: Alignment.center,
            height: height,
            margin: EdgeInsets.symmetric(horizontal: 0),
            padding: EdgeInsets.symmetric(vertical: 4,horizontal: 24),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  color: Color(COLOR_PRIMARY_VAL),
                  width: 24,
                  imageAsset,
                  height: 24,
                ),
                SizedBox(width: 12,),
                Text(label,style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold,fontFamily: APP_FONT_BOLD),)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
