import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onPressed;
  Color? color;
  final Color bgColor;
  Color? shadowColor;
  Color? hoverColor = Colors.blueGrey;
  double? height = 60;
  double? padding = 8;
   RoundedButton({
    Key? key,
    required this.assetPath,
     this.color,
    required this.bgColor,
    required this.onPressed,
     this.hoverColor,
     this.shadowColor,
     this.padding,
     this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color shadow = shadowColor??Colors.transparent;
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(color: shadow,spreadRadius: 2,blurRadius: 4),
        ],
      ),
      child: Center(
        child: SizedBox(
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              foregroundColor: hoverColor,
              shadowColor: Colors.transparent,
              padding: EdgeInsets.all(padding??8),
              shape: const CircleBorder(),
              backgroundColor: bgColor,//Colors.grey.shade900
            ),
            child:(color!=null)? Image.asset(assetPath,color: color,fit: BoxFit.fill )
            : Image.asset(assetPath,fit: BoxFit.fill ),
          ),
        ),
      ),
    );
  }
}