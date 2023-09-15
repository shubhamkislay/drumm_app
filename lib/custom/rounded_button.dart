import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  final String assetPath;
  final VoidCallback onPressed;
  final Color color;
  final Color bgColor;
  Color? hoverColor = Colors.blueGrey;
  double? height = 60;
  double? padding = 8;
   RoundedButton({
    Key? key,
    required this.assetPath,
    required this.color,
    required this.bgColor,
    required this.onPressed,
     this.hoverColor,
     this.padding,
     this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
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
            child: Image.asset(assetPath,color: color,fit: BoxFit.fill ),
          ),
        ),
      ),
    );
  }
}