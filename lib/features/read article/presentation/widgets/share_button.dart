import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:share_plus/share_plus.dart';

class ArticleShareButton extends StatelessWidget {
  ArticleEntity article;
  ArticleShareButton({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Vibrate.feedback(FeedbackType.selection);
        Share.share(article.url!);
      },
      child: Container(
        height: 36,
        width: 36,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: DrummTheme.primaryDarkItemColor.withAlpha(150),
          borderRadius: BorderRadius.circular(24)
        ),
        child: Image.asset('images/share-btn.png',
            color: DrummTheme.primaryTextColorDark,
            fit: BoxFit.contain),
      ),
    );
  }
}
