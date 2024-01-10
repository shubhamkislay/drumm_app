
import 'package:flutter/material.dart';

class ShareWidget extends StatelessWidget {
  const ShareWidget();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Colors.grey.shade900.withOpacity(0.5),
            ),
            child: Image.asset(
              'images/share-btn.png',
              height: 20,
              color: Colors.white,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}