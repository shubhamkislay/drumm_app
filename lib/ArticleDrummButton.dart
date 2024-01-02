import 'package:drumm_app/model/article.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

import 'article_jam_page.dart';
import 'custom/rounded_button.dart';

class ArticleDrummButton extends StatelessWidget {
  Article articleOnScreen;
  ArticleDrummButton({Key? key,required this.articleOnScreen}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RoundedButton(
      padding: 10,
      height: 52,
      color: Colors.white,
      bgColor: Colors.transparent,
      onPressed: () {
        Vibrate.feedback(FeedbackType.selection);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.grey.shade900,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
                top: Radius.circular(0.0)),
          ),
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context)
                      .viewInsets
                      .bottom),
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(
                    top: Radius.circular(0.0)),
                child: ArticleJamPage(
                  article: articleOnScreen,
                ),
              ),
            );
          },
        );
      },
      assetPath: 'images/drumm_logo.png',
    );
  }
}
