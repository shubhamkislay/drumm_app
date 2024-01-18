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
      backgroundColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)
      ),
      icon: Image.asset(
        tutorialImageAsset,
        height: 42,
        color: Colors.white,
      ),
      title: Text(
        tutorialMessageTitle,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white, fontSize: 22,fontWeight: FontWeight.bold),
      ),
      contentPadding: EdgeInsets.all(32),
      iconPadding: EdgeInsets.all(32),
      content: Text(
        tutorialMessage,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsPadding: EdgeInsets.all(24),
      actions: [
        GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Container(
            padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: BoxDecoration(
                color: COLOR_PRIMARY_DARK,
                borderRadius: BorderRadius.circular(24)),
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
            const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.blue.shade600,
                  Colors.blue.shade700,
                ]),
                borderRadius: BorderRadius.circular(24)),
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
