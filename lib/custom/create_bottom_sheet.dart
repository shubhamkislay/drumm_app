import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/create_post.dart';
import 'package:drumm_app/custom/ai_summary.dart';
import 'package:drumm_app/custom/rounded_button.dart';
import 'package:drumm_app/theme/theme_constants.dart';

class CreateBottomSheet extends StatefulWidget {
  CreateBottomSheet({
    Key? key,
  }) : super(key: key);

  @override
  CreateBottomSheetState createState() => CreateBottomSheetState();
}

class CreateBottomSheetState extends State<CreateBottomSheet> {
  String currentSummary = "Summarizing this article...";
  bool available = false;
  double sheetHeight = 175;
  double textOpacity = 0.75;
  double iconPadding = 24;
  double iconHeight = 85;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 12),
      color: Colors.transparent,//Color(0xff002c4f),
      height: sheetHeight,
      child: SingleChildScrollView(
        child: Row(
          //crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RoundedButton(
                    padding: iconPadding,
                    height: iconHeight,
                    color: Colors.white,
                    bgColor: Colors.white12.withOpacity(0.075),
                    onPressed: () {
                      // fetchSummary(); // Fetch the updated summary

                      Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) => CreatePost(),
                      ),);
                    },
                    assetPath: 'images/add_post.png',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Create",
                      style: TextStyle(
                          fontSize: 14, color: Colors.white.withOpacity(textOpacity)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RoundedButton(
                    padding: iconPadding,
                    height: iconHeight,
                    color: Colors.blue,
                    bgColor: Colors.white12.withOpacity(0.075),
                    onPressed: () {
                      // fetchSummary(); // Fetch the updated summary
                    },
                    assetPath: 'images/drumm_logo.png',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Ask",
                      style: TextStyle(
                          fontSize: 14, color: Colors.white.withOpacity(textOpacity)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).frosted(
      blur: 17.5,
      frostColor:Colors.grey.shade900.withOpacity(0.15),
    );
  }
}
