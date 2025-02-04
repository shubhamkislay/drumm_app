import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/get%20bands/domain/entities/band.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:drumm_app/features/read%20article/presentation/widgets/start_drumm_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

class BottomStartConversationWidget extends StatelessWidget {
  final ArticleEntity article;
  final List<BandEntity> bands;

  const BottomStartConversationWidget(
      {super.key, required this.article, required this.bands});
  @override
  Widget build(BuildContext context) {
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
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    "${article.question}",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontFamily: DRUMM_FONT_FAMILY
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(height: 32),
                SizedBox(height: 32),
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
