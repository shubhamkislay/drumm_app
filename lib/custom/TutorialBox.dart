import 'package:drumm_app/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'constants/Constants.dart';

class TutorialBox extends StatelessWidget {
  String tutorialMessage;
  String tutorialMessageTitle;
  String tutorialImageAsset;
  String sharedPreferenceKey;
  String boxType;
  VoidCallback? onConfirm;
  TutorialBox(
      {Key? key,
      required this.tutorialMessage,
        required this.tutorialMessageTitle,
      required this.tutorialImageAsset,
      required this.sharedPreferenceKey,
      required this.boxType,
      this.onConfirm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: COLOR_PRIMARY_DARK,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)
      ),
      icon: Image.asset(
        tutorialImageAsset,
        height: 32,
        color: Colors.white,
      ),
      title: Text(
        tutorialMessageTitle,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      contentPadding: EdgeInsets.all(24),
      content: Text(
        tutorialMessage,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsPadding: EdgeInsets.symmetric(vertical: 16,horizontal: 8),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12)),
            child: const Text(
              "Not now",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () {
            updateSharedPreference();
            onConfirm!();
            Navigator.pop(context);
          },
          child: Container(
            padding:
            const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(12)),
            child: const Text(
              "Let's Go",
              style: TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void updateSharedPreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(sharedPreferenceKey, false);
  }
}
