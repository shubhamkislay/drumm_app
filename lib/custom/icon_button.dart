import 'package:flutter/material.dart';
import 'package:drumm_app/theme/theme_constants.dart';

class IconLabelButton extends StatelessWidget {
  VoidCallback onPressed;
  String imageAsset;
  String label;
  double? height = 100;
  Color? assetColor;
  Color? textColor;
  Color? backgroundColor;
  IconLabelButton({Key? key, required this.imageAsset,this.assetColor,this.textColor,this.backgroundColor, required this.label, required this.onPressed,this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: onPressed,
      child: Wrap(
        children: [
          Container(
            alignment: Alignment.center,
            height: height,
            margin: const EdgeInsets.symmetric(horizontal: 0),
            padding: const EdgeInsets.symmetric(vertical: 4,horizontal: 24),
            decoration: BoxDecoration(
                color: backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular(24)
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  color: assetColor ?? const Color(COLOR_PRIMARY_VAL),
                  width: 24,
                  imageAsset,
                  height: 24,
                ),
                const SizedBox(width: 12,),
                Text(label,style: TextStyle(color: textColor??Colors.black,fontWeight: FontWeight.bold,fontFamily: APP_FONT_BOLD),)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
