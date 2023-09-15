import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:drumm_app/custom/ai_summary.dart';
import 'package:drumm_app/custom/helper/firebase_db_operations.dart';
import 'package:drumm_app/custom/rounded_button.dart';
import 'package:drumm_app/model/article.dart';
import 'package:drumm_app/theme/theme_constants.dart';

class BottomSheetContent extends StatefulWidget {
  Article article;
  Color bgColor;
  BottomSheetContent({
    Key? key,
    required this.bgColor,
    required this.article,
  }) : super(key: key);

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  String currentSummary = "Summarizing this article using AI...";
  bool available = false;
  double sheetHeight = 175;
  double textOpacity = 0.5;

  @override
  void initState() {
    super.initState();
    fetchSummary(); // Fetch the initial summary
  }


  Future<void> fetchSummary() async {
    // Code to fetch the summary from API
    // Assign the fetched summary to currentSummary
    String currentSummary = widget.article.summary ?? "";
    if (currentSummary != null && currentSummary.length > 0)
      enableSheet(currentSummary);
    else
      AISummary.getNewsSummary(widget.article.url).then((value) {
        enableSheet(value);
        FirebaseDBOperations.updateSummary(widget.article.articleId, value);
      });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24, top: 12),
      color: widget.bgColor,//Colors.transparent,//Color(0xff002c4f),
      height: sheetHeight,
      duration: Duration(milliseconds: 300),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!available)
              RoundedButton(
                padding: 12,
                height: 58,
                color: Colors.white,
                bgColor: Colors.transparent,
                onPressed: () {
                  // fetchSummary(); // Fetch the updated summary
                },
                assetPath: 'images/sparkles.png',
              ),
            if (!available)
              Container(
                width: 50,
                padding: const EdgeInsets.only(bottom: 8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: LinearProgressIndicator(
                    color: Colors.white,
                    backgroundColor: Colors.white12,
                    minHeight: 10,
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 24),
              child: Text(
                currentSummary,
                style: TextStyle(
                    fontSize: 16, color: Colors.white.withOpacity(textOpacity)),
              ),
            ),
          ],
        ),
      ),
    ).frosted(
      blur: 25,
      frostColor:Colors.grey.shade900.withOpacity(0.15),
    );
  }


  void enableSheet(String value) {
    setState(() {
      currentSummary = value;
      available = true;
      sheetHeight = 300;
      textOpacity = 1.0;
    });
  }
}
