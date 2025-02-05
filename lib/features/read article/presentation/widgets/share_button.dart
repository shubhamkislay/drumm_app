import 'package:drumm_app/config/theme/drumm_theme.dart';
import 'package:drumm_app/core/features/user%20activity/domain/entities/user_activity_entity.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_bloc.dart';
import 'package:drumm_app/core/features/user%20activity/presentation/bloc/user_activity_event.dart';
import 'package:drumm_app/custom/constants/Constants.dart';
import 'package:drumm_app/features/news%20feed/domain/entities/article.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
        context
            .read<UserActivityBloc>()
            .add(RecordUserActivity(UserActivityEntity(
          type: INTERACTION_SHARED,
          weight: WEIGHT_SHARED,
          articleId: article.articleId!,
          embedding: article.embedding!,
        )));
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
