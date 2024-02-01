
import 'package:flutter/material.dart';

class ShareWidget extends StatelessWidget {
  double? iconHeight;



  ShareWidget(
      {Key? key,
        this.iconHeight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    double iconH = iconHeight??24;
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.grey.shade900.withOpacity(0.35),
            ),
            child: Image.asset(
              'images/share-btn.png',
              height: iconH,
              color: Colors.white,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}