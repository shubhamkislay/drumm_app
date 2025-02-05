import 'package:auto_size_text/auto_size_text.dart';
import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/read%20article/presentation/widgets/start_drumm_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class BottomStartConversationWidget extends StatelessWidget {
  final ArticleEntity article;
  final List<BandEntity> bands;

  const BottomStartConversationWidget(
      {super.key, required this.article, required this.bands});
  @override
  Widget build(BuildContext context) {
    const textStyle = TextStyle(
      fontSize: 32.0,
      height: 1.5,
    );
    return Material(
      color: Colors.transparent, // Transparent background
      child: Align(
        alignment: Alignment.bottomCenter, // Bottom Sheet Position
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: double.infinity,
          decoration: BoxDecoration(
            color: DrummTheme.drummPrimaryColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Align(
            alignment: Alignment.bottomCenter, // B
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      color: Colors.white,
                      width: 32,
                      "images/team_active.png",
                      height: 32,
                    ),
                    SizedBox(
                      height: 75,
                      width: 150,
                      child: CupertinoPicker(
                        itemExtent: textStyle.fontSize!,
                        diameterRatio: 5,
                        magnification: 1.15,
                        selectionOverlay: CupertinoPickerDefaultSelectionOverlay(
                          background: Colors.black.withAlpha(25),
                        ),
                        onSelectedItemChanged: (index) {
                          print("Band Name ${bands[index].name}");
                        },
                        children: List.generate(
                          bands.length,
                              (index) {
                            return Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.all(8.0),
                              child: Text(
                                '${bands[index].name}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontFamily: DRUMM_FONT_FAMILY),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 32,),

                  ],
                ),
                SizedBox(height: 32),
                Container(
                  height: 135,
                  padding: const EdgeInsets.all(16.0),
                  child: AutoSizeText(
                    "${article.question}",
                    maxFontSize: 32,
                    minFontSize: 12,
                    style: TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontFamily: DRUMM_FONT_FAMILY),
                    textAlign: TextAlign.center,
                  ),
                ),

                Container(
                  margin: EdgeInsets.only(bottom: 28),
                  child: StartDrummButton(
                    article: ArticleEntity(articleId: ""),
                    size: 92,
                    buttonText: "Tap to start a conversation",
                    onPressed: () {
                      Vibrate.feedback(FeedbackType.impact);
                      Navigator.pop(context);
                    },
                    background: Colors.black.withAlpha(25),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
