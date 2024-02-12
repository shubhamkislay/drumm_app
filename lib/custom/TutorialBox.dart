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
  bool? autoUpdate = false;
  String? confirmMessage;
  Color? confirmColor;
  VoidCallback? onConfirm;
  VoidCallback? onCancel;
  TutorialBox(
      {Key? key,
      required this.tutorialMessage,
        required this.tutorialMessageTitle,
      required this.tutorialImageAsset,
      required this.sharedPreferenceKey,
      required this.boxType,
        this.autoUpdate,
        this.confirmMessage,
        this.confirmColor,
        this.onCancel,
      this.onConfirm})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    String confirmMsg = confirmMessage ??"Let's Go";
    Color confirmClr= confirmColor??Colors.blue.shade800;
    if(autoUpdate??false) {
      print("AutoUpdating share preference");
      updateSharedPreference();
    }
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
      contentPadding: const EdgeInsets.all(32),
      iconPadding: const EdgeInsets.all(32),
      content: Text(
        tutorialMessage,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
      actionsAlignment: MainAxisAlignment.spaceEvenly,
      actionsPadding: const EdgeInsets.all(24),
      actions: [
        if(boxType == BOX_TYPE_CONFIRM) GestureDetector(
          onTap: () {
            try {
              onCancel!();
            }catch(e){

            }
            Navigator.pop(context);
          },
          child: Container(
            padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
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
            try {
              onConfirm!();
            }catch(e){
              print("You've not set onConfirm callback");
            }
            Navigator.pop(context);
          },
          child: Container(
            padding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            decoration: BoxDecoration(
                color: confirmClr,
                //gradient: LinearGradient(colors: JOIN_COLOR),
                borderRadius: BorderRadius.circular(24)),
            child:  Text(confirmMsg,
              style: const TextStyle(
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
